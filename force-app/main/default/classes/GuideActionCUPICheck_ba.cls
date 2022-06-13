/****************************************************************************************
  * @filename      : GuideActionCUPICheck_ba
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


public with sharing class GuideActionCUPICheck_ba implements Database.Batchable<sObject>, Database.Stateful {

    public String query;


    public Database.QueryLocator start(Database.BatchableContext BC) {
        if(String.isEmpty(query)) {
            query = 'SELECT Id, OwnerId FROM Account WHERE CustomerType__c = \'대리점\'';
        }
        
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Account> scope) {
        Set<String> accIds = new Set<String>();
        for (Account a : scope) {
            accIds.add(a.Id);
        }
        List<AggregateResult> accountAggregateResult = [
                SELECT Dealer__c,count(Id) counting
                FROM Account
                WHERE Dealer__c = :accIds
                AND RecordType.developerName = 'PersonAccount'
                AND IsCUPI__pc = false
                GROUP BY Dealer__c
        ];

        Map<String, Id> taskOwnerId = Dummy_IF_BatchUtil.getDealerOwner(accIds);
        List<Task> taskList = new List<Task>();
        Task newTask;
        for(AggregateResult a : accountAggregateResult){
            newTask = new Task();
            newTask.OwnerId = taskOwnerId.get(String.valueOf(a.get('Dealer__c')));
            newTask.ActivityDate = System.today();
            newTask.Type__c = 'Guide';
            newTask.WhatId = String.valueOf(a.get('Dealer__c'));
            newTask.Subject = '[개인정보 수집 및 활용]';
            newTask.Description =   '개인정보활용동의가 누락된 고객이 총 ' + String.valueOf(a.get('counting')) + '명 있습니다. ' +
                                    '개인정보 누락된 고객은 “시승/프로모션 안내”등의 혜택에 누락될 수 있습니다. ' +
                                    '대리점 방문시, 본 내용을 일러주시고 “개인정보 활용 동의 방법”을 고객께 안내 부탁드립니다.';
            newTask.CustomAlert__c = true;

            taskList.add(newTask);
        }
        // 작업 Insert
        if(taskList.size() > 0) insert taskList;
    }

    public void finish(Database.BatchableContext param1) {
    }
}