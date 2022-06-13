/****************************************************************************************
  * @filename      : GuideActionOpportunityCloseCheck_ba
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

public with sharing class GuideActionOpportunityCloseCheck_ba implements Database.Batchable<sObject>, Database.Stateful {
    public Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, OwnerId FROM Account WHERE CustomerType__c = \'대리점\' ';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Account> scope) {
        Set<String> accIds = new Set<String>();
        for (Account a : scope) {
            accIds.add(a.Id);
        }

        List<AggregateResult> opportunityAggregateResults = [
                SELECT COUNT(Id) counting, Account.Dealer__c dealerId
                FROM Opportunity
                WHERE StageName = '상담'
                AND CreatedDate < LAST_N_DAYS:80
                //AND CloseDate < LAST_N_DAYS:80 // test용
                AND RecordType.developerName = 'PerFarCorp'
                AND ActivityCheck__c = FALSE
                AND Account.Dealer__c = :accIds
                Group BY Account.Dealer__c
        ];

        List<Task> taskList = new List<Task>();
        Task newTask;
        Map<String, Id> taskOwnerId = Dummy_IF_BatchUtil.getDealerOwner(accIds);

        for (AggregateResult o : opportunityAggregateResults) {
            newTask = new Task();
            newTask.OwnerId = taskOwnerId.get(String.valueOf(o.get('dealerId')));
            newTask.ActivityDate = System.today();
            newTask.Type__c = 'Guide';
            newTask.WhatId = String.valueOf(o.get('dealerId'));
            newTask.Subject = '[영업기회]';
            newTask.Description =   '영업기회 생성 후 마감되지 않은 건이 총 ' + String.valueOf(o.get('counting')) + '건이 있습니다. ' +
                                    '고객의 구매의사를 확인해 보세요. 영업기회 생성 후 90일 이내 미 완료 건은 자동 종료 처리됩니다.';
            newTask.CustomAlert__c = true;

            taskList.add(newTask);

        }
        // 작업 Insert
        if (taskList.size() > 0) insert taskList;

        List<Opportunity> opportunities = [
                SELECT Account.Dealer__c, StageName, LossReason__c, ActivityCheck__c, CreatedDate, CloseDate, SystemStatus__c
                FROM Opportunity
                WHERE StageName = '상담'
                //AND CloseDate < LAST_N_DAYS:80 // test용
                AND CreatedDate < LAST_N_DAYS:80
                AND RecordType.developerName = 'PerFarCorp'
        ];

        List<Opportunity> tempOpportunities = new List<Opportunity>();
        System.debug(opportunities.size());
        if(opportunities.size() > 0) {
            for (Opportunity o : opportunities) {
                if(System.today() - 90 > o.CreatedDate && o.ActivityCheck__c){
                //if (System.today() - 90 > o.CloseDate && o.ActivityCheck__c == True) { //test
                    o.StageName = '실주';
                    // 20210416 추가
                    o.SystemStatus__c = '실주';
                    o.LossReason__c = 'Other';
                } else if(! o.ActivityCheck__c ){
                    o.ActivityCheck__c = True;
                }
                tempOpportunities.add(o);
            }
            update tempOpportunities;
        }
    }

    public void finish(Database.BatchableContext BC) {

    }
}