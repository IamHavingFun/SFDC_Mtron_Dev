/****************************************************************************************
  * @filename      : GuideActionAR6MonthOverByAsset_ba
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

public with sharing class GuideActionAR6MonthOverByAsset_ba implements Database.Batchable<sObject>, Database.Stateful {

    public String query;
    public Boolean isNextBatch = true;

    public Database.QueryLocator start(Database.BatchableContext BC) {
        if(String.isEmpty(query)) {
            query = 'SELECT Id,AccountId__c, AccountId__r.OwnerId, fm_isAsset__c, PlanDate__c, BaseYearMonth__c, AccountId__r.Name,AccountId__r.BusinessOffice__r.Name, Asset__r.Name FROM AR__C ' +
                    'WHERE BaseYearMonth__c = THIS_MONTH AND PlanDate__c < LAST_N_DAYS:180 AND RepaymentKRW__c > 0 ' +
                    'AND fm_isAsset__c = TRUE and AccountId__c != null And AccountId__r.CustomerType__c = \'대리점\'';
        }

        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<AR__C> scope) {
        Set<String> accIds = new Set<String>();
        for (AR__C a : scope) {
            accIds.add(a.AccountId__c);
        }

        Map<String, Id> taskOwnerId =  Dummy_IF_BatchUtil.getDealerOwner(accIds);
        List<Task> taskList = new List<Task>();
        Task newTask;
        for(AR__c ar : scope){
            newTask = new Task();
            newTask.OwnerId = taskOwnerId.get(ar.AccountId__c);
            newTask.ActivityDate = System.today();
            newTask.Type__c = 'Guide';
            newTask.WhatId = ar.Id;
            newTask.Subject = '[6개월 초과 연체 채권 확인]';
            newTask.Description =  '(기대번호 : ' + ar.Asset__r.Name + ')에 관련된 채권의 연체가 6개월 초과 상태로, 향후 주문이 제한될 수 있습니다. ' +
                                '자세한 사항은 영업소에 문의바랍니다. ['+ ar.AccountId__r.BusinessOffice__r.Name + ' ' + ar.AccountId__r.Name + ']';
            newTask.CustomAlert__c = true;
            taskList.add(newTask);

            if(taskOwnerId.get(ar.AccountId__c) != ar.AccountId__r.OwnerId){
                newTask = new Task();
                newTask.OwnerId = ar.AccountId__r.OwnerId;
                newTask.ActivityDate = System.today();
                newTask.Type__c = 'Guide';
                newTask.WhatId = ar.Id;
                newTask.Subject = '[6개월 초과 연체 채권 확인]';
                newTask.Description =   '(기대번호 : ' + ar.Asset__r.Name + ')에 관련된 채권의 연체가 6개월 초과 상태로, 향후 주문이 제한될 수 있습니다. ' +
                                        '자세한 사항은 영업소에 문의바랍니다. [' + ar.AccountId__r.BusinessOffice__r.Name + ' ' + ar.AccountId__r.Name + ']';
                newTask.CustomAlert__c = true;
                taskList.add(newTask);
            }
        }

        if(taskList.size() > 0) insert taskList;
    }

    public void finish(Database.BatchableContext BC) {
        if(isNextBatch) {
            Database.executeBatch(new GuideActionAR6MonthOverByDealer_ba(), 200);
        }
    }
}