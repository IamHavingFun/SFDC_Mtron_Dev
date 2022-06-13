/****************************************************************************************
  * @filename      : Dummy_IF_KR_ERP_SE_0001_2_ba
  * @author        : i2max
  * @date          : 2021-04-14
  * @group         : 
  * @group-content : 
  * @description   : 
  * @tester        : Dummy_IF_KR_ERP_SE_0001_2_ba_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2021-04-14         i2max          Create
****************************************************************************************/
public with sharing class Dummy_IF_KR_ERP_SE_0001_2_ba implements Database.Batchable<SObject> {

    private List<IF_KR_ERP_SE_0001__c> targetList;

    private Dummy_IF_KR_ERP_SE_0001_2_ba() {}

    public Dummy_IF_KR_ERP_SE_0001_2_ba(List<IF_KR_ERP_SE_0001__c> targetList) {
        this.targetList = (targetList == null) ? new List<IF_KR_ERP_SE_0001__c>() : targetList;
    }

    public List<IF_KR_ERP_SE_0001__c> start(Database.BatchableContext BC) {
        return this.targetList;
    }

    public void execute(Database.BatchableContext BC, List<SObject> targetScope) {
        //-------------------------------------------------------------
        // 중복 데이털 일괄 배채 수행 결과 업데이트
        // 동일한 처리 데이터를 update
        //-------------------------------------------------------------
        Dummy_IF_BatchUtil.setDummyBatchDupResult(targetScope);
        update targetScope;
    }

    public void finish(Database.BatchableContext BC) {}

}