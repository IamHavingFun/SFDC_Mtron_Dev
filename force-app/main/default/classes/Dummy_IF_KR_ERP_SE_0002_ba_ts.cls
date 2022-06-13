/****************************************************************************************
  * @filename      : Dummy_IF_KR_ERP_SE_0002_ba_ts
  * @projectname   :
  * @author        : i2max_my.Seo
  * @date          : 2020-05-11 오후 5:11
  * @group         :
  * @group-content :
  * @description   : 
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author            description
  * ===============================================================
    0.1     2020-05-11 오후 5:11     i2max_my.Seo         Create
****************************************************************************************/
@IsTest
private class Dummy_IF_KR_ERP_SE_0002_ba_ts {
    @IsTest
    static void testBehavior() {
        TestDataBaseFactory.init();
        TestDataDummyBatchFactory.init();
        //============================================================================
        // 필요시 Dummy 데이터 변경 및 추가
        //============================================================================
        IF_KR_ERP_SE_0001__c dummy1 = TestDataDummyBatchFactory.erpSe0001dummyDataAccount.clone(false, true);
        dummy1.ERPCode__c = null;

        // 연체확인 Task 생성
        IF_KR_ERP_SE_0001__c dummy2 = TestDataDummyBatchFactory.erpSe0001dummyDataAccount.clone(false, true);
        dummy2.ERPCode__c = '001';
        dummy2.OverdueBond__c = 1;
        dummy2.OverdueSixMonths__c = 1;

        insert dummy1;
        insert dummy2;

        //============================================================================
        // 배치 실행
        //============================================================================\
        Database.executeBatch(new Dummy_IF_KR_ERP_SE_0002_ba(), 200);
    }
}