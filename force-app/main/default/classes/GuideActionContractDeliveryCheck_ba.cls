/****************************************************************************************
  * @filename      : GuideActionContractDeliveryCheck_ba
  * @projectname   : LS
  * @author        : Park HE
  * @date          : 2020-06-08
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
    0.1     2020-06-08             Park HE         Create
****************************************************************************************/


public with sharing class GuideActionContractDeliveryCheck_ba implements Database.Batchable<sObject>, Database.Stateful {

    public String query;
    public Boolean isNextBatch = true;

    public Database.QueryLocator start(Database.BatchableContext BC) {
        if(String.isEmpty(query)) {
            query = 'SELECT Id, Opportunity__c, Customer__r.Name, OwnerId FROM Contract__c ' +
                    'WHERE CustomerExpectedDate__c = TODAY AND Opportunity__r.StageName = \'계약\' AND RecordType.developerName = \'PerFarCorp\' ' +
                    'AND Customer__r.Dealer__r.CustomerType__c = \'대리점\'';
        }
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Contract__c> scope) {
        Set<String> accIds = new Set<String>();
        for (Contract__c c : scope) {
            accIds.add(c.Customer__c);
        }

        Map<String, Id> taskOwnerId =  Dummy_IF_BatchUtil.getDealerOwner(accIds);
        List<Task> taskList = new List<Task>();
        Task newTask;
        for(Contract__c c : scope){
            newTask = new Task();
            newTask.OwnerId = taskOwnerId.get(c.Customer__c);
            newTask.ActivityDate = System.today();
            newTask.Type__c = 'Guide';
            newTask.WhatId = c.Id;
            newTask.Subject = '[제품 인도일]';
            newTask.Description = c.Customer__r.Name + '님에게 제품을 인도하는 날입니다. PDI 등록 잊지 마시기 바랍니다. ';
            newTask.CustomAlert__c = true;
            taskList.add(newTask);
        }
        // 작업 Insert
        if(taskList.size() > 0) insert taskList;
    }

    public void finish(Database.BatchableContext BC) {
        if(isNextBatch) {
            // 미상환 리스 융자 체크.
            //Database.executeBatch(new GuideActionContractLeaseCheck_ba(), 200);
        }
    }
}