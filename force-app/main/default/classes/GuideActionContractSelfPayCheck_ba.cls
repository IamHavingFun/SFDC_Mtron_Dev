/****************************************************************************************
  * @filename      : GuideActionContractSelfPayCheck_ba
  * @projectname   : LS_PS
  * @author        : Park HE
  * @date          : 2020-07-14
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
    0.1     2020-07-14             Park HE         Create
****************************************************************************************/
public with sharing class GuideActionContractSelfPayCheck_ba implements Database.Batchable<sObject>, Database.Stateful {
    public String query;

    public Database.QueryLocator start(Database.BatchableContext BC) {
        if(String.isEmpty(query)) {
            query = ' SELECT Id,Customer__r.Name, Customer__r.Dealer__c, Customer__r.Dealer__r.OwnerId ' +
                    ' FROM Contract__c ' +
                    ' WHERE SelfPayCollectDueDate__c = LAST_N_DAYS:45 ' +
                    ' AND SelfPayCollectDueDate__c < LAST_N_DAYS:44 ' +
                    ' AND IsCollectExist__c = false ' +
                    ' AND fm_SelfPayApex__c = false';
        }
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext param1, List<Contract__c> scope) {
        Set<String> accIds = new Set<String>();
        for (Contract__c con : scope) {
            accIds.add(con.Customer__r.Dealer__c);
        }
        Map<String, Id> taskOwnerId =  Dummy_IF_BatchUtil.getDealerOwner(accIds);
        System.debug(taskOwnerId);
        List<Task> taskList = new List<Task>();
        Task newTask;
        for(Contract__c contract : scope){
            System.debug(contract);
            newTask = new Task();
            newTask.OwnerId = taskOwnerId.get(contract.Customer__r.Dealer__c);
            newTask.ActivityDate = System.today();
            newTask.Type__c = 'Guide';
            newTask.WhatId = contract.Id;
            newTask.Subject = '[미상환 자부담]';
            newTask.Description = contract.Customer__r.Name + '님의 자부담 납입 기일이 45일 경과되었습니다.';
            newTask.Status = 'Completed';
            newTask.CustomAlert__c = true;
            taskList.add(newTask);

        }
        // 작업 Insert
        if(taskList.size() > 0) insert taskList;
    }


    public void finish(Database.BatchableContext param1) {
        /*// 미상환 리스 융자 체크.
        Database.executeBatch(new GuideActionQuoteCheck_ba(), 200);*/
    }

}