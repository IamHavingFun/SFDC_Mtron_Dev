/****************************************************************************************
  * @filename      : Dummy_IF_KR_PLM_SE_0029_ba_ts
  * @projectname   : 
  * @author        : i2max 
  * @date          : 2020-06-05 오후 4:58
  * @group         : 
  * @group-content : 
  * @description   : 
  * @tester        : Dummy_IF_KR_PLM_SE_0029_ba_ts_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author              description
  * ===============================================================
    0.1     2020-06-05 오후 4:58       i2max                  Create
*************a***************************************************************************/
@IsTest
private class Dummy_IF_KR_PLM_SE_0029_ba_ts {
    @IsTest
    static void testBehavior() {
        TestDataBaseFactory.init();
        TestDataDummyBatchFactory.init();
        //============================================================================
        // 필요시 Dummy 데이터 변경 및 추가
        //============================================================================
        IF_KR_PLM_SE_0029__c plmSe0029s1 = TestDataDummyBatchFactory.plmSe0006dummyDataProductChange.clone(false, true);
        plmSe0029s1.DELETE_FLAG__c = '';

        IF_KR_PLM_SE_0029__c plmSe0029s2 = TestDataDummyBatchFactory.plmSe0006dummyDataProductChange.clone(false, true);
        plmSe0029s2.DELETE_FLAG__c = '?';
        plmSe0029s2.PREGISTRATION_DATE__c = '-----';

        insert plmSe0029s1;
        insert plmSe0029s2;

        //============================================================================
        // 배치 실행
        //============================================================================\
        Database.executeBatch(new Dummy_IF_KR_PLM_SE_0029_ba(), 200);
    }
}