/****************************************************************************************
  * @filename      : Dummy_IF_KR_ERP_SE_0004_2_ba_ts
  * @author        : i2max_my.Seo
  * @date          : 2020-12-17 오후 4:49
  * @group         :
  * @group-content :
  * @description   :
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author            description
  * ===============================================================
    0.1     2020-12-17 오후 4:49     i2max_my.Seo         Create
****************************************************************************************/
@IsTest
private class Dummy_IF_KR_ERP_SE_0001_2_ba_ts {
    @IsTest
    static void testBehavior() {
        //==============================================================================
        // Logic Test
        //==============================================================================
        Database.executeBatch(new Dummy_IF_KR_ERP_SE_0001_2_ba(new List<IF_KR_ERP_SE_0001__c>{TestDataDummyBatchFactory.erpSe0001dummyDataAccount}), 1);
    }
}