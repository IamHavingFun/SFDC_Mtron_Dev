/****************************************************************************************
  * @filename      : LsMSalesCustomerVO
  * @projectname   : 
  * @author        : i2max
  * @date          : 2020-06-30
  * @group         : 
  * @group-content : 
  * @description   : 고객 VO
  * @tester        : LsMSalesCustomerVO_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2020-06-30         i2max          Create
****************************************************************************************/
public with sharing class LsMSalesCustomerVO {
    @AuraEnabled public Account customer {get;set;}
    @AuraEnabled public Contact customerContact {get;set;}
    @AuraEnabled public CUPI__c cupi {get;set;}
    @AuraEnabled public Boolean isPersonAccount {get;set;}
}