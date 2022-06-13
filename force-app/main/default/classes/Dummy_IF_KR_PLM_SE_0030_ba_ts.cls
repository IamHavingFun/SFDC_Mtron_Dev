/****************************************************************************************
  * @filename      : Dummy_IF_KR_PLM_SE_0030_ba_ts
  * @projectname   : 
  * @author        : i2max 
  * @date          : 2020-06-30
  * @group         : 
  * @group-content : 
  * @description   : 
  * @tester        : Dummy_IF_KR_PLM_SE_0030_ba_ts_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author              description
  * ===============================================================
    0.1     2020-06-30               i2max                  Create
*************a***************************************************************************/
@IsTest
private class Dummy_IF_KR_PLM_SE_0030_ba_ts {
    @IsTest
    static void testBehavior() {
        TestDataBaseFactory.init();
        TestDataDummyBatchFactory.init();
        //============================================================================
        // 필요시 Dummy 데이터 변경 및 추가
        //============================================================================

        IF_KR_PLM_SE_0029__c plmSe0029_2 = TestDataDummyBatchFactory.plmSe0006dummyDataProductChangeItem.clone(false, true);
        plmSe0029_2.PLANT_ID__c = null;
        plmSe0029_2.PECN_ID__c = null;
        IF_KR_PLM_SE_0029__c plmSe0029_3 = TestDataDummyBatchFactory.plmSe0006dummyDataProductChangeItem.clone(false, true);
        plmSe0029_3.PLANT_ID__c = '00002';
        plmSe0029_3.PECN_ID__c = '002';
        ProductChange__c pc = new ProductChange__c(
                DELETE_FLAG__c = false,
                Name = 'testProductChange',
                PECN_ID__c = '00001',
                PLANT_ID__c = '001',
                PECN_NAME__c = 'testProductChange',
                Externalkey__c = '00001|001',
                PREGISTRATION_DATE__c = TestDataUtilFactory.d,
                SetDealerPublic__c = '공개'
        );
        insert plmSe0029_2;
        insert plmSe0029_3;
        insert pc;
        Database.executeBatch(new Dummy_IF_KR_PLM_SE_0030_ba(), 200);

    }
}