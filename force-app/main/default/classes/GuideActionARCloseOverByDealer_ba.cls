/****************************************************************************************
  * @filename      : GuideActionARCloseOverByDealer_ba
  * @projectname   : LS
  * @author        : Park HE
  * @date          : 2020-06-17
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
    0.1     2020-06-17             Park HE         Create
****************************************************************************************/

public with sharing class GuideActionARCloseOverByDealer_ba implements Database.Batchable<sObject>, Database.Stateful {

    public String query;

    public Database.QueryLocator start(Database.BatchableContext BC) {
        if(String.isEmpty(query)) {
            query = 'SELECT Id, Name, OwnerId, OverdueBond__c, BusinessOffice__r.Name FROM Account WHERE OverdueBond__c > 0 and CustomerType__c = \'대리점\'';
        }
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Account> scope) {
        Set<String> accIds = new Set<String>();
        for (Account a : scope) {
            accIds.add(a.Id);
        }

        Map<String, Id> taskOwnerId =  Dummy_IF_BatchUtil.getDealerOwner(accIds);
        List<Task> taskList = new List<Task>();
        Task newTask;
        for(Account acc : scope){
            newTask = new Task();
            newTask.OwnerId = taskOwnerId.get(acc.Id);
            newTask.ActivityDate = System.today();
            newTask.Type__c = 'Guide';
            newTask.WhatId = acc.Id;
            newTask.Subject = '[연체채권 발생]';
            newTask.Description = '채권이 연체 초과 상태로, 연체이자 연 12%가 발생합니다. 자세한 사항은 영업소에 문의바랍니다. [' + acc.BusinessOffice__r.Name + ' ' + acc.Name + ']';
            newTask.CustomAlert__c = true;
            taskList.add(newTask);

            if(taskOwnerId.get(acc.Id) != acc.OwnerId) {
                newTask = new Task();
                newTask.OwnerId = acc.OwnerId;
                newTask.ActivityDate = System.today();
                newTask.Type__c = 'Guide';
                newTask.WhatId = acc.Id;
                newTask.Subject = '[연체채권 발생]';
                newTask.Description = '채권이 연체 초과 상태로, 연체이자 연 12%가 발생합니다. 자세한 사항은 영업소에 문의바랍니다. [' + acc.BusinessOffice__r.Name + ' ' + acc.Name + ']';
                newTask.CustomAlert__c = true;
                taskList.add(newTask);
            }
        }

        if(taskList.size() > 0) insert taskList;
    }


    public void finish(Database.BatchableContext BC) {

    }

}