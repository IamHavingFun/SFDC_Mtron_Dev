/****************************************************************************************
  * @filename      : Dummy_IF_KR_ERP_SE_0027_ba_ts
  * @projectname   :
  * @author        : i2max_my.Seo
  * @date          : 2020-05-11 오후 4:44
  * @group         :
  * @group-content :
  * @description   : 
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author            description
  * ===============================================================
    0.1     2020-05-11 오후 4:44     i2max_my.Seo         Create
****************************************************************************************/
@IsTest
private class Dummy_IF_KR_ERP_SE_0027_ba_ts {
    @IsTest
    static void testBehavior() {
        TestDataBaseFactory.init();
        TestDataDummyBatchFactory.init();
        //============================================================================
        // 필요시 Dummy 데이터 변경 및 추가
        //============================================================================
        IF_KR_ERP_SE_0001__c dummy1 = TestDataDummyBatchFactory.erpSe0001dummyDataSoldTo.clone(false, true);
        dummy1.ErpPARVW__c = 'RE';
        IF_KR_ERP_SE_0001__c dummy2 = dummy1.clone(false, true);
        dummy2.ErpPARVW__c = 'RG';
        IF_KR_ERP_SE_0001__c dummy3 = dummy1.clone(false, true);
        dummy3.ErpPARVW__c = 'WE';
        IF_KR_ERP_SE_0001__c dummy4 = dummy1.clone(false, true);
        dummy4.ErpKUNNR__c = null;


        insert new List<IF_KR_ERP_SE_0001__c>{
            dummy1, dummy2, dummy3, dummy4
        };

        //============================================================================
        // 배치 실행
        //============================================================================\
        Database.executeBatch(new Dummy_IF_KR_ERP_SE_0027_ba(), 200);
    }
}