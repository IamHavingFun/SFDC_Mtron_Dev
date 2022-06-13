/****************************************************************************************
  * @filename      : SupplyPriceDisplayController
  * @projectname   : LS
  * @author        : Park HE
  * @date          : 2020-04-08
  * @group         : 
  * @group-content : 
  * @description   : 
  * @tester        : 
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author              description
  * ===============================================================
    0.1     2020-04-08 16:19   Park HE           Create
****************************************************************************************/

/**
 * Created by ms on 2020-04-08.
 */

public with sharing class SupplyPriceDisplayController {
    /**
     *
     *
     * @param recordId
     *
     * @return
     */
    @AuraEnabled
    public static Order__c getSupplyPrice(String recordId){
        return [Select ru_MaxNetPrice__c, ru_MinNetPrice__c, ru_UnitPrice__c,  ru_MaxFee__c, ru_MinFee__c
                From Order__c  Where Id =:recordId];
    }
}