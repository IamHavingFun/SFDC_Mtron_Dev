/****************************************************************************************
  * @filename      : ContractDetail
  * @projectname   :
  * @author        : i2max_ss.Jung
  * @date          : 2020-04-08 오전 11:27
  * @group         :
  * @group-content :
  * @description   :
  * @tester        : ContractDetail_ts.cls
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author              description
  * ===============================================================
    0.1     2020-04-08 오전 11:27       i2max_ss.Jung         Create
****************************************************************************************/
public with sharing class ContractDetail {
    public class InitData extends I2ComClass.InitData {
        @AuraEnabled public Contract__c contractData {get;private set;}
    }

    @AuraEnabled
    public static InitData init(String recordId){
        InitData initData = new InitData();

        initData.contractData =  [
                SELECT
                        Id,
                        SelfPayDebtAmt__c,
                        SelfPayPaymentAmt__c,
                        SelfPayDueDate__c,
                        fm_SelfPayStatus__c,
                        fm_SelfPayRemarks__c,
                        SelfPayContractAmt__c,
                        SelfPayCollectAmt__c,
                        SelfPayCollectDueDate__c,
                        SelfPayNotes__c,

                        fm_LeaseDebtAmt__c,
                        LeasePaymentAmt__c,
                        LeaseDueDate__c,
                        fm_LeaseStatus__c,
                        fm_LeaseRemarks__c,
                        LeaseContractAmt__c,
                        fm_LeaseCollectAmt__c,
                        fm_LeaseCollectDueDate__c,
                        LeaseNotes__c,

                        fm_LoanDebtAmt__c,
                        LoanPaymentAmt__c,
                        LoanDueDate__c,
                        fm_LoanStatus__c,
                        fm_LoanRemarks__c,
                        LoanContractAmt__c,
                        fm_LoanCollectAmt__c,
                        fm_LoanCollectDueDate__c,
                        LoanNotes__c,

                        ContractAmt__c,
                        ContractAmtCollectAmt__c,
                        ContractAmtCollectDueDate__c,
                        ContractNotes__c,

                        SubsidyContractAmt__c,
                        SubsidyCollectAmt__c,
                        SubsidyCollectDueDate__c,
                        SubsidyNotes__c,

                        fm_TotalPayAmt__c,
                        TotalPrice__c,

                        isUsedUndertaking__c,
                        UsedUndertakingAmt__c
                FROM Contract__c
                WHERE Id =:recordId
        ];
        return initData;
    }

    @AuraEnabled
    public static void save(Contract__c contract) {
        System.debug('contactList : ' + JSON.serializePretty(contract));

        if(contract != null)    upsert contract;
    }
}