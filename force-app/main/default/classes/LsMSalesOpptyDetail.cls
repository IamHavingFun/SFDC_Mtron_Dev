/****************************************************************************************
  * @filename      : LsMSalesOpptyDetail
  * @projectname   : 
  * @author        : i2max_my.Seo 
  * @date          : 2020-08-05 오전 7:43
  * @group         : 
  * @group-content : 
  * @description   : 
  * @tester        : LsMSalesOpptyDetail_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author              description
  * ===============================================================
    0.1     2020-08-05 오전 7:43     i2max_my.Seo           Create
****************************************************************************************/
public with sharing class LsMSalesOpptyDetail {

    /**
     * @param opptyId : Opportunity Id
     *
     * @return Opportunity
     */
    @AuraEnabled(Cacheable=true)
    public static Opportunity init(String opptyId) {
        return [
                SELECT
                        CloseDate, StageName,
                        InterestModel__r.Name, InterestModel__r.ProductType__c,
                        Account.Name, Account.FarmingArea__c, Account.FarmingForm__c, Account.PersonMobilePhone,
                        (
                                SELECT  Product__r.ProductType__c, Product__r.Name, Type__c,
                                        Product__r.Option1__c, Product__r.Option2__c, Product__r.Option3__c, Product__r.Option4__c,
                                        ListPrice__c, UnitPrice__c, NetPrice__c, LoanLimitAmt__c,
                                        Quote__c
                                FROM QuoteLineItem__r
                                ORDER BY Type__c
                        )
                FROM Opportunity
                WHERE Id = :opptyId
        ];
    }
}