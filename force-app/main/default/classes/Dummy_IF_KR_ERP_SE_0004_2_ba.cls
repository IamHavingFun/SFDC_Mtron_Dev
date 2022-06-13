/****************************************************************************************
  * @filename      : Dummy_IF_KR_ERP_SE_0004_2_ba
  * @author        : i2max_my.Seo 
  * @date          : 2020-12-16 오후 12:12
  * @group         : 
  * @group-content : 
  * @description   : 
  * @tester        : Dummy_IF_KR_ERP_SE_0004_2_ba_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author              description
  * ===============================================================
    0.1     2020-12-16 오후 12:12     i2max_my.Seo           Create
****************************************************************************************/
public class Dummy_IF_KR_ERP_SE_0004_2_ba implements Database.Batchable<SObject> {

    private List<IF_KR_ERP_SE_0004__c> targetList;

    private Dummy_IF_KR_ERP_SE_0004_2_ba() {}

    public Dummy_IF_KR_ERP_SE_0004_2_ba(List<IF_KR_ERP_SE_0004__c> targetList) {
        this.targetList = (targetList == null) ? new List<IF_KR_ERP_SE_0004__c>() : targetList;
    }

    public List<IF_KR_ERP_SE_0004__c> start(Database.BatchableContext BC) {
        return this.targetList;
    }

    public void execute(Database.BatchableContext BC, List<SObject> targetScope) {
        //-------------------------------------------------------------
        // 중복 데이털 일괄 배채 수행 결과 업데이트
        // 동일한 처리 데이터를 update
        // 20210414 : 헛기창 이사님 요청
        //-------------------------------------------------------------
        //delete targetScope;
        Dummy_IF_BatchUtil.setDummyBatchDupResult(targetScope);
        update targetScope;
    }

    public void finish(Database.BatchableContext BC) {}
}