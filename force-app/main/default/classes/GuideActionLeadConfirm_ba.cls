/****************************************************************************************
  * @filename      : GuideActionLeadConfirm_ba
  * @projectname   : LS_PS
  * @author        : Park HE
  * @date          : 2020-07-14
  * @group         :
  * @group-content :
  * @description   :
  * @tester        :
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                    author          description
  * ===============================================================
    0.1     2020-07-14             Park HE         Create
****************************************************************************************/
public with sharing class GuideActionLeadConfirm_ba implements Database.Batchable<sObject>, Database.Stateful {

    public String query ;
    public Boolean isNextBatch = true;

    public Database.QueryLocator start(Database.BatchableContext BC) {
        if(String.isEmpty(query)) {
            query = 'SELECT Id, Name, CreatedDate, TestDriveDate__c, Dealer__c, OwnerId, CampaignId__r.TestDriveOwner__c, ' +
                    ' fm_DealerName__c, BusinessOffice__r.Name ' +
                    'FROM Lead ' +
                    'Where isTestDriveConfirmed__c = false AND CreatedDate = LAST_N_DAYS:5 AND CreatedDate < LAST_N_DAYS:4 AND TestDriveDate__c = NULL AND RecordType.DeveloperName = \'TestDrive\'';
//        String query =  'SELECT Id, Name, CreatedDate, TestDriveDate__c, Dealer__c, OwnerId, CampaignId__r.TestDriveOwner__c FROM Lead ' +
//                        'Where isTestDriveConfirmed__c = false AND TestDriveDate__c = NULL AND RecordType.DeveloperName = \'TestDrive\'';
        }
        System.debug('start ::: ' + query);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Lead> scope) {
        Set<String> accIds = new Set<String>();
        for (Lead lead : scope) {
            accIds.add(lead.Dealer__c);
        }

        Map<String, Id> taskOwnerId = Dummy_IF_BatchUtil.getDealerOwner(accIds);
        Task newTask;
        List<Task> taskList = new List<Task>();
        for (Lead lead : scope) {
            newTask = new Task();
            newTask.OwnerId = taskOwnerId.get(lead.Dealer__c);
            newTask.ActivityDate = System.today();
            newTask.Type__c = 'Guide';
            newTask.WhoId = lead.Id;
            newTask.Subject = '[시승 확정요청]';
            newTask.Description = lead.Name + '고객의 시승이 배정되었습니다. \n' + lead.Name + '에게 연락을 취해 시승 일자를 최종 확정 바랍니다.\n' +
                    '['+lead.BusinessOffice__r.Name + ', '+ lead.fm_DealerName__c + ']';

            newTask.CustomAlert__c = true;

            taskList.add(newTask);

            if(lead.CampaignId__r.TestDriveOwner__c != null){
                newTask = new Task();
                newTask.OwnerId = lead.CampaignId__r.TestDriveOwner__c;
                newTask.ActivityDate = System.today();
                newTask.Type__c = 'Guide';
                newTask.WhoId = lead.Id;
                newTask.Subject = '[시승 확정요청]';
                newTask.Description = lead.Name + '고객의 시승이 배정되었습니다. \n' + lead.Name + '에게 연락을 취해 시승 일자를 최종 확정 바랍니다.\n' +
                        '['+lead.BusinessOffice__r.Name + ', '+ lead.fm_DealerName__c + ']';
                newTask.CustomAlert__c = true;

                taskList.add(newTask);
            }
        }

        System.debug(taskList);
        if(taskList.size() > 0) insert taskList;
    }
    
    public void finish(Database.BatchableContext BC) {
        // 제품 인도일 체크.
        if(isNextBatch) {
            Database.executeBatch(new GuideActionPromotionClose_ba(), 200);
        }
    }
}