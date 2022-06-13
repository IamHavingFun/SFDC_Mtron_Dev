/****************************************************************************************
  * @filename      : LsMSalesLeaseInspectionVO
  * @author        : I2MAX
  * @date          : 2021-03-29
  * @group         : 
  * @group-content : 
  * @description   : 
  * @tester        : LsMSalesLeaseInspectionVO_ts.cls
  * @reference     : 
  * @release       : v1.0.0
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                author        description
  * ===============================================================
    1.0     2021-03-29          I2MAX           Create
****************************************************************************************/
public with sharing class LsMSalesLeaseInspectionVO implements LsMSalesStepVO {

    @AuraEnabled public BizData bizData {get;set;}
    @AuraEnabled public SetData setData {get;set;}

    public class BizData {
        // 리스검수보고서
        @AuraEnabled public LeaseInspectionReport__c leaseInspectionReport {get;set;}
        // 대상이 되는 Contract
        @AuraEnabled public Contract__c contract {get;set;}
    }

    public class SetData {
        // 대상이 되는 Contract List
        @AuraEnabled public List<Contract__c> targetContracts {get;set;}
        // 대상이 되는 Contract 없을 시, 메세지
        @AuraEnabled public String noContractMessage {get;set;}
    }
}