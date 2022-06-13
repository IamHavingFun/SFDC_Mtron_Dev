/****************************************************************************************
  * @filename      : AccSimpleInfoController
  * @projectname   : LS
  * @author        : Park HE
  * @date          : 2020-04-16
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
    0.1     2020-04-16 16:24   Park HE           Create
****************************************************************************************/

public with sharing class AccSimpleInfoController {
    /**
     *
     *
     * @param recordId
     *
     * @return
     */
    @AuraEnabled
    public static Map<String, Object> getAccSimpleInfo(String recordId) {
        Account acc = [SELECT Id, Name, fm_Mobile__c, FarmingArea__c,FarmingForm__c, LastModifiedDate, LastActivityDate, fm_OwnTractor__c, InterestModel__r.Name FROM Account WHERE Id = :recordId];
        List<QuoteLineItem__c> qli = [
                SELECT Product__r.Name, Product__r.Id
                FROM QuoteLineItem__c
                WHERE Quote__r.Opportunity__r.AccountId = :recordId and Type__c = '본체'
                ORDER BY Quote__r.CreatedDate DESC
                LIMIT 1
        ];
        List<Asset> asset = [
                SELECT Product2.Name, Customer__c
                FROM Asset
                WHERE Customer__c = :recordId
                LIMIT 1
        ];

        return new Map<String, Object>{
                'acc' => acc,
                'asset' => (asset.size() > 0 ? asset.get(0) : null),
                'qli' => (qli.size() > 0 ? qli.get(0) : null)
        };
    }
}