/****************************************************************************************
  * @filename      : GuideActionContractNHLoanCheck_ba
  * @projectname   : LS
  * @author        : Park HE
  * @date          : 2020-06-09
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
    0.1     2020-06-09             Park HE         Create
****************************************************************************************/

public with sharing class GuideActionContractNHLoanCheck_ba implements Database.Batchable<sObject>, Database.Stateful {
    public String query;
    public Boolean isNextBatch = true;

    public Database.QueryLocator start(Database.BatchableContext BC) {
        if(String.isEmpty(query)) {
            query = ' SELECT Id, Customer__r.Name, Customer__r.Dealer__c, Customer__r.Dealer__r.OwnerId ' +
                    ' FROM Contract__c ' +
                    ' WHERE RecordType.developerName = \'PerFarCorp\'  ' +
                    ' AND LoanPaymentAmt__c = 0 ' +
                    ' AND fm_LoanDebtAmt__c > 0 ' +
                    ' AND IsCollectExist__c = false ' +
                    ' AND ContractStartDate__c < LAST_N_DAYS:45';
        }
        System.debug('start ::: ' + query);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Contract__c> scope) {
        Set<String> accIds = new Set<String>();
        for (Contract__c con : scope) {
            accIds.add(con.Customer__r.Dealer__c);
        }
        Map<String, Id> taskOwnerId =  Dummy_IF_BatchUtil.getDealerOwner(accIds);
        List<Task> taskList = new List<Task>();
        Task newTask;
        for(Contract__c contract : scope){
            newTask = new Task();
            newTask.OwnerId = taskOwnerId.get(contract.Customer__r.Dealer__c);
            newTask.ActivityDate = System.today();
            newTask.Type__c = 'Guide';
            newTask.WhatId = contract.Id;
            newTask.Subject = '[미상환 농협융자]';
            newTask.Description =   contract.Customer__r.Name + '님과 계약한 이후 45일 경과되었습니다. 농협 융자 상태를 점검해 보세요.' +
                    '만약, 고객이 아직 농협 융자 서류 미 접수 경우 접수 독려 부탁드립니다.';
            newTask.CustomAlert__c = true;
            taskList.add(newTask);

            if(taskOwnerId.get(contract.Customer__r.Dealer__c) != contract.Customer__r.Dealer__r.OwnerId){
                newTask = new Task();
                newTask.OwnerId = contract.Customer__r.Dealer__r.OwnerId;
                //newTask.OwnerId = contract.Opportunity__r.Account.Dealer__r.OwnerId;
                newTask.ActivityDate = System.today();
                newTask.Type__c = 'Guide';
                newTask.WhatId = contract.Id;
                newTask.Subject = '[미상환 농협융자]';
                newTask.Description =   contract.Customer__r.Name + '님과 계약한 이후 45일 경과되었습니다. 농협 융자 상태를 점검해 보세요.' +
                        '만약, 고객이 아직 농협 융자 서류 미 접수 경우 접수 독려 부탁드립니다.';
                newTask.CustomAlert__c = true;
                taskList.add(newTask);
            }
        }
        // 작업 Insert
        if(taskList.size() > 0) insert taskList;

    }

    public void finish(Database.BatchableContext BC) {
        if(isNextBatch) {
            // 미상환 자부담 체크.
            Database.executeBatch(new GuideActionContractPDICheck_ba(), 200);
        }
    }
}