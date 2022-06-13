/****************************************************************************************
  * @filename      : Dummy_IF_KR_ERP_SE_0014_ba_ts
  * @projectname   :
  * @author        : i2max_my.Seo
  * @date          : 2020-04-23
  * @group         :
  * @group-content :
  * @description   : [채권현황]
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2020-04-23      i2max_my.Seo     Create
****************************************************************************************/
@IsTest
private class Dummy_IF_KR_ERP_SE_0014_ba_ts {
    @IsTest
    static void testBehavior() {
        TestDataBaseFactory.init();
        TestDataDummyBatchFactory.init();
        //============================================================================
        // 필요시 Dummy 데이터 변경 및 추가
        //============================================================================
        IF_KR_ERP_SE_0006__c dummyErpSe0006 = TestDataDummyBatchFactory.erpSe0006dummyDataBase.clone(false, true);
        dummyErpSe0006.CustomerCode__c = null;

        insert dummyErpSe0006;

        //============================================================================
        // 배치 실행
        //============================================================================\
        Database.executeBatch(new Dummy_IF_KR_ERP_SE_0014_ba(), 200);
    }
}