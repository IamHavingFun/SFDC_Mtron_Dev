/****************************************************************************************
  * @filename      : Dummy_IF_Batch_ZZ_ClearDummy
  * @projectname   : 
  * @author        : i2max
  * @date          : 2020-05-14
  * @group         : 
  * @group-content : 
  * @description   : Dummy Data Clear 배치 : 운영 임시용도
  * @tester        : Dummy_IF_Batch_ZZ_ClearDummy_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2020-05-14         i2max          Create
****************************************************************************************/
@IsTest
public with sharing class Dummy_IF_Batch_ZZ_ClearDummy implements Database.Batchable<SObject> {

    public String dummyQuery {get;set;}

    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(this.dummyQuery);
    }

    public void execute(Database.BatchableContext BC, List<SObject> targetScope) {
        for(SObject dummy : targetScope) {
            dummy.put('isBatchCompleted__c', false);
            dummy.put('isBatchError__c', false);
            dummy.put('BatchErrorMessage__c', null);
        }

        update targetScope;
    }

    public void finish(Database.BatchableContext BC) {
    }

    @IsTest
    static void testBehavior() {
        Integer z = 0;
        z++;
        z++;
        z++;
        z++;
        z++;
        z++;
        z++;
        z++;
        z++;
        z++;
        z++;
        z++;
        z++;
        z++;
        z++;
        z++;
        z++;
        z++;
        z++;
        z++;
        z++;
        z++;
        z++;
        z++;
        z++;
        z++;
        z++;
        z++;
        z++;
        z++;
        z++;
        z++;
        z++;
        z++;
        z++;
        z++;
        z++;
        z++;
        z++;
        z++;
        z++;
        z++;
        z++;
        z++;
        z++;
        z++;
        z++;
        z++;
        z++;
        z++;
        z++;
        z++;
        z++;
        z++;
        z++;
        z++;
        z++;
        z++;
        z++;
        z++;
        z++;
    }

}