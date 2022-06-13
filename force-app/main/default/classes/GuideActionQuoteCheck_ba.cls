/****************************************************************************************
  * @filename      : GuideActionQuoteCheck_ba
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

public with sharing class GuideActionQuoteCheck_ba implements Database.Batchable<sObject>, Database.Stateful {
    public Database.QueryLocator start(Database.BatchableContext BC) {
        String query =  'SELECT Id, Opportunity__c, CustomerName__c, CustomerName__r.Name, OwnerId FROM Quote__c ' +
                        'WHERE CreatedDate = LAST_N_DAYS:8 AND CreatedDate != LAST_N_DAYS:7 AND Opportunity__r.StageName = \'견적\' ' +
                        'AND RecordType.developerName = \'PerFarCorp\' AND Opportunity__r.Account.Dealer__r.CustomerType__c = \'대리점\'';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Quote__c> scope) {
        Set<String> accIds = new Set<String>();
        for (Quote__c q : scope) {
            accIds.add(q.CustomerName__c);
        }

        Map<String, Id> taskOwnerId = Dummy_IF_BatchUtil.getDealerOwner(accIds);
        List<Task> taskList = new List<Task>();
        Task newTask;

        for(Quote__c q : scope){
            newTask = new Task();
            newTask.OwnerId = taskOwnerId.get(q.CustomerName__c);
            newTask.ActivityDate = System.today();
            newTask.Type__c = 'Guide';
            newTask.WhatId = q.Opportunity__c;
            newTask.Subject = '[영업기회]';
            newTask.Description = '1주일 전에 견적을 진행한 ' + q.CustomerName__r.Name+ '과 계약 전 단계입니다. 고객에게 계약의사를 확인해 보세요.';
            newTask.CustomAlert__c = true;
            taskList.add(newTask);
        }
        // 작업 Insert
        if(taskList.size() > 0) insert taskList;
    }

    public void finish(Database.BatchableContext BC) {
    }

}