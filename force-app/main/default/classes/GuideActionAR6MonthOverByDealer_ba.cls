/****************************************************************************************
  * @filename      : GuideActionAR6MonthOverByDealer_ba
  * @projectname   : LS
  * @author        : Park HE
  * @date          : 2020-06-17
  * @group         : 
  * @group-content : 
  * @description   : 6개월 연체 대리점에게 알림.
  * @tester        : 
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                    author          description
  * ===============================================================
    0.1     2020-06-17             Park HE         Create
****************************************************************************************/


public with sharing class GuideActionAR6MonthOverByDealer_ba implements Database.Batchable<sObject>, Database.Stateful {

    public String query;
    public Boolean isNextBatch = true;

    public Database.QueryLocator start(Database.BatchableContext BC) {
        if(String.isEmpty(query)) {
            query = 'SELECT Id, Name, OwnerId, BusinessOffice__r.Name FROM Account WHERE ( fm_OverdueMoreSixMonths__c > 0 OR fm_OverdueOneYear__c > 0 ) AND CustomerType__c = \'대리점\'';
        }
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Account> scope) {
//        System.debug('scope :: ' + scope);
        Set<String> accIds = new Set<String>();
        for (Account a : scope) {
            accIds.add(a.Id);
        }
//        System.debug('accIds :: ' + accIds);

        Map<String, Id> taskOwnerId =  Dummy_IF_BatchUtil.getDealerOwner(accIds);
//        System.debug('taskOwnerId :: ' + taskOwnerId);

        List<Task> taskList = new List<Task>();
        Task newTask;
//        System.debug('testSCope : ' + scope);
        for(Account acc : scope){
            newTask = new Task();
            newTask.OwnerId = taskOwnerId.get(acc.Id);//String.valueOf(acc.get('Id'))
            newTask.ActivityDate = System.today();
            newTask.Type__c = 'Guide';
            newTask.WhatId = acc.Id;
            newTask.Subject = '[6개월 초과 연체 채권 확인]';
            newTask.Description = '채권의 연체가 6개월 초과 상태로, 향후 주문이 제한될 수 있습니다. 자세한 사항은 영업소에 문의 바랍니다. [' + acc.BusinessOffice__r.Name + ' ' + acc.Name + ']';
            newTask.CustomAlert__c = true;
            taskList.add(newTask);
            System.debug(taskOwnerId.get(acc.Id));
            System.debug(acc.OwnerId);

            if(taskOwnerId.get(acc.Id) != acc.OwnerId) {
                newTask = new Task();
                newTask.OwnerId = acc.OwnerId;
                newTask.ActivityDate = System.today();
                newTask.Type__c = 'Guide';
                newTask.WhatId = acc.Id;
                newTask.Subject = '[6개월 초과 연체 채권 확인]';
                newTask.Description = '채권의 연체가 6개월 초과 상태로, 향후 주문이 제한될 수 있습니다. 자세한 사항은 영업소에 문의 바랍니다. [' + acc.BusinessOffice__r.Name + ' ' + acc.Name + ']';
                newTask.CustomAlert__c = true;
                taskList.add(newTask);
            }
        }

//        System.debug('taskList :: ' + taskList);
        if(taskList.size() > 0) insert taskList;
    }


    public void finish(Database.BatchableContext BC) {
        if(isNextBatch) {
            Database.executeBatch(new GuideActionARCloseOverByAsset_ba(), 200);
        }
    }

}