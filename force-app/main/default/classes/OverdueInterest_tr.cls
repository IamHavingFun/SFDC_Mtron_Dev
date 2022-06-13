/****************************************************************************************
  * @filename      : OverdueInterest_tr
  * @author        : I2MAX
  * @date          : 2021-03-11 오전 10:10
  * @group         : 
  * @group-content : 
  * @description   : 
  * @tester        : OverdueInterest_tr_ts.cls
  * @reference     : 
  * @release       : v1.0.0
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author        description
  * ===============================================================
    1.0     2021-03-11 오전 10:10          I2MAX           Create
****************************************************************************************/
public with sharing class OverdueInterest_tr extends TriggerHandler {

    public override void beforeInsert() {
        this.setLookupFieldForOverdueInterest(Trigger.new);
    }

    public override void beforeUpdate() {
        this.setLookupFieldForOverdueInterest(Trigger.new);
    }

    /**
     * 연체이자 insert, update 시, 해당 record를 토대로 lookup field setting.
     * 영업소, 대리점, 기대번호, 채권, 모델
     *
     * @param newList : List<OverdueInterest__c>
     */
    private void setLookupFieldForOverdueInterest(List<OverdueInterest__c> newList) {

        // 대리점 코드 set
        Set<String> dealerCodeSet = new Set<String>();
        // 기대번호 set
        Set<String> serialNoSet = new Set<String>();
        // 청구문서번호 set
        Set<String> bondBillNoSet = new Set<String>();


        // 대리점 코드 별 Account map
        Map<String, Account> accountMap = new Map<String, Account>();
        // 기대번호 별 Asset Id map
        Map<String, Id> assetMap = new Map<String, Id>();
        // 청구문서번호 별 AR Id map
        Map<String, Id> arMap = new Map<String, Id>();
        // 기대번호 별 Product2 Id map
        Map<String, Id> productMap = new Map<String, Id>();

        // 각각의 set data setting
        for(OverdueInterest__c oi : newList) {
            dealerCodeSet.add(oi.DealerCode__c);
            serialNoSet.add(oi.SerialNo__c);
            bondBillNoSet.add(oi.BondBillNo__c);
        }

        // accountMap setting
        for(Account acc : [SELECT Id, ERPCode__c, ParentId, Parent.BusinessOfficeName__c FROM Account WHERE ERPCode__c IN :dealerCodeSet]) {
            if(!accountMap.containsKey(acc.ERPCode__c)) {
                accountMap.put(acc.ERPCode__c, acc);
            }
        }
/*

        // assetMap setting
        for(Asset asset : [SELECT Id, Name FROM Asset WHERE Name IN :serialNoSet]) {
            if(!assetMap.containsKey(asset.Name)) {
                assetMap.put(asset.Name, asset.Id);
            }
        }

        // arMap setting
        for(AR__c ar : [SELECT Id, BillingDocNo__c FROM AR__c WHERE BillingDocNo__c IN :bondBillNoSet]) {
            if(!arMap.containsKey(ar.BillingDocNo__c)) {
                arMap.put(ar.BillingDocNo__c, ar.Id);
            }
        }

        // productMap setting
        for(Product2 prod : [SELECT Id, ProductCode FROM Product2 WHERE ProductCode IN :serialNoSet]) {
            if(!productMap.containsKey(prod.ProductCode)) {
                productMap.put(prod.ProductCode, prod.Id);
            }
        }
*/

        for(OverdueInterest__c oi : newList) {
            Account tempAccount = accountMap.get(oi.DealerCode__c);

            // 영업소
            oi.SalesOffice__c = tempAccount?.ParentId;
            //필드 통합으로 주석처리
            //oi.BusinessOfficeName__c = tempAccount?.Parent.BusinessOfficeName__c;
/*
            // 대리점
            oi.Dealer__c = tempAccount?.Id;
            // 기대번호
            oi.Asset__c = assetMap.get(oi.SerialNo__c);
            // 채권
            oi.AR__c = arMap.get(oi.BondBillNo__c);
            // 모델
            oi.Product__c = productMap.get(oi.SerialNo__c);

 */
        }
    }
}