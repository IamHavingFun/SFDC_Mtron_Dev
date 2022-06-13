/****************************************************************************************
  * @filename      : GuideActionContractPDICheck_ba
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

public with sharing class GuideActionContractPDICheck_ba implements Database.Batchable<sObject>, Database.Stateful {
    public String query;
    public Boolean isNextBatch = true;

    public Database.QueryLocator start(Database.BatchableContext BC) {
        if(String.isEmpty(query)) {
            query = 'SELECT Id, OwnerId FROM Account WHERE CustomerType__c = \'대리점\'';
        }
        System.debug('start ::: ' + query);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Account> scope) {
        Set<String> accIds = new Set<String>();
        for (Account a : scope) {
            accIds.add(a.Id);
        }

        List<AggregateResult> contracts = [
                SELECT Count(Id) counting, Customer__r.Dealer__c  dealerId, Customer__r.Dealer__r.OwnerId dealerOwnerId, Customer__r.Dealer__r.Name dealerName
                FROM Contract__c
                WHERE Opportunity__r.StageName IN ('인도')
                AND RecordType.developerName = 'PerFarCorp'
                AND IsLWSRegistration__c = FALSE
                AND CustomerExpectedDate__c < LAST_N_DAYS:7
                AND Customer__r.Dealer__c = :accIds
                GROUP By Customer__r.Dealer__c, Customer__r.Dealer__r.OwnerId, Customer__r.Dealer__r.Name
        ];

        Map<String, Id> taskOwnerId =  Dummy_IF_BatchUtil.getDealerOwner(accIds);
        List<Task> taskList = new List<Task>();
        Task newTask;
        for(AggregateResult c : contracts){
            newTask = new Task();
            newTask.OwnerId = taskOwnerId.get(String.valueOf(c.get('dealerId')));
            newTask.ActivityDate = System.today();
            newTask.Type__c = 'Guide';
            newTask.WhatId = String.valueOf(c.get('dealerId'));
            newTask.Subject = '[PDI 등록]';
            newTask.Description = 'PDI 누락 건이 총 ' + String.valueOf(c.get('counting')) + '건이 있습니다. PDI를 반드시 등록하시기 바랍니다.';
            newTask.CustomAlert__c = true;
            taskList.add(newTask);

            //test해보기
            // 대리점주와 담당 영업사원에게 전송되는 메시지가 다르므로 if 조건으로 나눌 필요 없음.
            newTask = new Task();
            newTask.OwnerId = String.valueOf(c.get('dealerOwnerId'));
            newTask.ActivityDate = System.today();
            newTask.Type__c = 'Guide';
            newTask.WhatId = String.valueOf(c.get('dealerId'));
            newTask.Subject = '[PDI 등록]';
            newTask.Description = String.valueOf(c.get('dealerName')) + '에 PDI 누락 건이 총 ' + String.valueOf(c.get('counting')) + '건이 있습니다. 확인하시기 바랍니다.';
            newTask.CustomAlert__c = true;
            taskList.add(newTask);

        }
        // 작업 Insert
        if(taskList.size() > 0) insert taskList;

    }

    public void finish(Database.BatchableContext BC) {
        if(isNextBatch) {
            Database.executeBatch(new GuideActionContractSelfPayCheck_ba(), 200);
        }
    }
}