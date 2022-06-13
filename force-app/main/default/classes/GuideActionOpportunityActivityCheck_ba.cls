/****************************************************************************************
  * @filename      : GuideActionOpportunityActivityCheck_ba
  * @projectname   : LS
  * @author        : Park HE
  * @date          : 2020-06-08
  * @group         : 
  * @group-content : 
  * @description   : 영업기회 입력 후 1주일 간 견적 미 생성일 경우 : 08:30
  * @tester        : 
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                    author          description
  * ===============================================================
    0.1     2020-06-08             Park HE         Create
****************************************************************************************/

/**
 * Created by ms on 2020-06-08.
 */

public with sharing class GuideActionOpportunityActivityCheck_ba implements Database.Batchable<sObject>, Database.Stateful{

    public String query ;
    public Boolean isNextBatch = true;

    public Database.QueryLocator start(Database.BatchableContext BC) {
              if(String.isEmpty(query)){
                  query =  'SELECT Id, OwnerId, AccountId, Account.Name, Name FROM Opportunity ' +
                          'WHERE StageName = \'상담\' AND RecordType.developerName = \'PerFarCorp\' ' +
                          'AND Account.Dealer__r.CustomerType__c = \'대리점\' AND LastModifiedDate < LAST_N_DAYS:6';
              }

        //AND CreatedDate = LAST_N_DAYS:14 AND CreatedDate != LAST_N_DAYS:6 에서 LastModifiedDate < LAST_N_DAYS:6 로 변경.
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Opportunity> scope) {
        Set<String> accIds = new Set<String>();
        for (Opportunity o : scope) {
            accIds.add(o.AccountId);
        }

        Map<String, Id> taskOwnerId = Dummy_IF_BatchUtil.getDealerOwner(accIds);
        List<Task> taskList = new List<Task>();
        Task newTask;
        for(Opportunity oppty : scope){
            newTask = new Task();
            newTask.OwnerId = taskOwnerId.get(oppty.AccountId);
            newTask.ActivityDate = System.today();
            newTask.Type__c='Guide';
            newTask.WhatId = oppty.Id;
            newTask.Subject = '[판매기회]고객상태 점검요청';
            newTask.Description =   '('+oppty.Name+')' + '\n '+
                                    '지난 고객 접촉 후 1주일이 경과되었습니다.\n' +
                                    '고객진행상태를 점검해 보시기 바랍니다.\n' +
                                    '만약, 고객이 이미 다른 경쟁사의 기대를 구매한 경우 본 영업 기회를 마감해 주시기 바랍니다.';
            newTask.CustomAlert__c = true;
            newTask.Status = 'Completed';
            taskList.add(newTask);
        }
        // 작업 Insert
        if(taskList.size() > 0) insert taskList;

    }
    
    public void finish(Database.BatchableContext param1) {
        // 후행 배치.
        if(isNextBatch){
        Database.executeBatch(new GuideActionOpportunityCloseCheck_ba(), 200);
        }
    }
}