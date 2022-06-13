/****************************************************************************************
  * @filename      : OpptySimpleInfoController
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
    0.1     2020-04-08 17:15        Park HE              Create
****************************************************************************************/

public with sharing class OpptySimpleInfoController {
    /**
     *
     *
     * @param recordId
     *
     * @return
     */
    @AuraEnabled
    public static Opportunity getOpptySimpleInfo(String recordId){
        return [SELECT Name, Id, AccountId, Account.Name, Account.fm_Mobile__c, InterestModel__r.Name,  Amount, CloseDate,  LastActivityDate, LastModifiedDate
            FROM Opportunity WHERE Id =:recordId];
    }
}