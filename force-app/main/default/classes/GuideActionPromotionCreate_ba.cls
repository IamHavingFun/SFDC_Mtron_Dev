/****************************************************************************************
  * @filename      : GuideActionPromotionCreate_ba
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
public with sharing class GuideActionPromotionCreate_ba implements Database.Batchable<sObject>, Database.Stateful {

    public Database.QueryLocator start(Database.BatchableContext BC) {
        String query =  'SELECT Id, Name, Description, OwnerId, RecordType.DeveloperName, Status, PublicYn__c,' +
                        '(Select id, Account__c from Campaign__r where Account__c != null) ' +
                        'FROM Campaign ' +
                        'WHERE IsActive = True AND StartDate = TODAY '+
                        'AND Status NOT IN (\'프로모션 완료\', \'종료\') ';
        System.debug('start ::: ' + query);
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<Campaign> scope) {
        Set<String> dealerAreasIds = new Set<String>();
        for (Campaign cam_temp : scope) {
            if(cam_temp.PublicYn__c){
                for(Account acc_temp:[select Id from Account where CustomerType__c = '대리점' AND ERPCode__c != NULL AND BusinessOffice__r.CustomerType__c = '영업소']){
                    dealerAreasIds.add(acc_temp.Id);
                }
                break;
            }else{
                // 공개범위 대리점
                for(ShareSetting__c shareSetting_temp:cam_temp.Campaign__r){
                    dealerAreasIds.add(shareSetting_temp.Account__c);
                }
            }
        }

        Map<String, Id> dealerOwnerList = Dummy_IF_BatchUtil.getDealerOwner(dealerAreasIds);

        // Task 생성
        Task newTask;
        List<Task> taskList = new List<Task>();
        List<Campaign> camTempList = new List<Campaign>();

        for (Campaign cam_temp : scope) {
            if(cam_temp.PublicYn__c){
                for(String accID:dealerOwnerList.keySet()){
                    newTask = new Task();
                    newTask.OwnerId = dealerOwnerList.get(accID);
                    newTask.WhatId = cam_temp.Id;
                    newTask.Type__c='Guide';
                    newTask.ActivityDate = System.today();
                    newTask.Status = 'Completed';
                    newTask.Subject = cam_temp.RecordType.DeveloperName == 'TestDrive' ? '[시승]' :'[프로모션]' ;
                    newTask.Description = (cam_temp.RecordType.DeveloperName == 'TestDrive' ? '시승' +' ' :'프로모션')+' 소식 : ' + cam_temp.Name +'\n' + cam_temp.Description ;
                    newTask.CustomAlert__c = true;

                    taskList.add(newTask);

                }
            }else {
                for(ShareSetting__c shareSetting_temp:cam_temp.Campaign__r){
                    // Task 생성
                    newTask = new Task();
                    newTask.OwnerId = dealerOwnerList.get(shareSetting_temp.Account__c);
                    newTask.WhatId = cam_temp.Id;
                    newTask.Type__c='Guide';
                    newTask.ActivityDate = System.today();
                    newTask.Status = 'Completed';
                    newTask.Subject = cam_temp.RecordType.DeveloperName == 'TestDrive' ? '[시승]' :'[프로모션]' ;
                    newTask.Description = (cam_temp.RecordType.DeveloperName == 'TestDrive' ? '시승' +' ' :'')+'프로모션 소식 : ' + cam_temp.Name +'\n' + cam_temp.Description ;
                    newTask.CustomAlert__c = true;

                    taskList.add(newTask);
                }
            }

            if(cam_temp.RecordType.DeveloperName == 'Promotion' && cam_temp.Status == '프로모션 계획'){
                cam_temp.Status = '프로모션 진행 중';
                camTempList.add(cam_temp);
            }
        }

        if(taskList.size() > 0) insert taskList;
        if(camTempList.size() > 0) update camTempList;

    }

    public void finish(Database.BatchableContext BC) {
        Database.executeBatch(new GuideActionPromotionClose_ba(), 200);

    }

}