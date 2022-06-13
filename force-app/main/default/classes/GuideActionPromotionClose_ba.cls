/****************************************************************************************
  * @filename      : GuideActionPromotionClose_ba
  * @projectname   : LS_PS
  * @author        : Park HE
  * @date          : 2020-07-15
  * @group         :
  * @group-content :
  * @description   : 프로모션 종료 Noti 보내기(시승은 X)
  * @tester        :
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                    author          description
  * ===============================================================
    0.1     2020-07-15             Park HE         Create
****************************************************************************************/
public with sharing class GuideActionPromotionClose_ba implements Database.Batchable<sObject>, Database.Stateful {
    private String recordId;

    public GuideActionPromotionClose_ba(){
    }

    public GuideActionPromotionClose_ba(String recordId){
        this.recordId = recordId;
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        String query =  'SELECT  Id, Name, Description, OwnerId, IsActive, RecordType.DeveloperName, PublicYn__c,(Select id, Account__c from Campaign__r where Account__c != null) ' +
                        ' FROM Campaign WHERE RecordType.DeveloperName = \'Promotion\' ';
        if(String.isEmpty(recordId)) {
            query += 'AND Status = \'프로모션 완료\' ';
            query += 'AND EndDate = YESTERDAY ';
        } else {
            query += 'AND Id = \'' + recordId + '\' ';
        }
        System.debug('=========== HKC');
        System.debug('start ::: ' + query);
        System.debug('=========== HKC');
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext param1, List<Campaign> scope) {
        System.debug('=========== GuideActionPromotionClose_ba Execute : ' + recordId);
        if(scope.size() == 1) {
            Set<String> dealerAreasIds = new Set<String>();
            for (Campaign cam_temp : scope) {
                if (cam_temp.PublicYn__c) {
                    for (Account acc_temp : [select Id from Account where CustomerType__c = '대리점' AND ERPCode__c != NULL AND BusinessOffice__r.CustomerType__c = '영업소']) {
                        dealerAreasIds.add(acc_temp.Id);
                    }
                    break;
                } else {
                    // 공개범위 대리점
                    for (ShareSetting__c shareSetting_temp : cam_temp.Campaign__r) {
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
                if (cam_temp.PublicYn__c) {
                    for (String accID : dealerOwnerList.keySet()) {
                        newTask = new Task();
                        newTask.OwnerId = dealerOwnerList.get(accID);
                        newTask.WhatId = cam_temp.Id;
                        newTask.Type__c = 'Guide';
                        newTask.ActivityDate = System.today();
                        newTask.Subject = '[프로모션]' ;
                        newTask.Description = '프로모션 종료 ' + cam_temp.Name;
                        newTask.Status = 'Completed';
                        newTask.CustomAlert__c = true;

                        taskList.add(newTask);
                    }
                } else {
                    for (ShareSetting__c shareSetting_temp : cam_temp.Campaign__r) {
                        // Task 생성
                        newTask = new Task();
                        newTask.OwnerId = dealerOwnerList.get(shareSetting_temp.Account__c);
                        newTask.WhatId = cam_temp.Id;
                        newTask.Type__c = 'Guide';
                        newTask.ActivityDate = System.today();
                        newTask.Subject = '[프로모션]' ;
                        newTask.Description = '프로모션 종료 ' + cam_temp.Name;
                        newTask.Status = 'Completed';
                        newTask.CustomAlert__c = true;

                        taskList.add(newTask);
                    }
                }
            }

            if (taskList.size() > 0) insert taskList;
        }
    }

    public void finish(Database.BatchableContext param1) {
    }

}