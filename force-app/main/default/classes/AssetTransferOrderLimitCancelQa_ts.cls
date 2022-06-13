/****************************************************************************************
  * @filename      : AssetTransferOrderLimitCancelQa_ts
  * @author        : I2MAX
  * @date          : 2021-03-24
  * @group         :
  * @group-content :
  * @description   : 
  * @reference     :
  * @release       : v1.0.0
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author         description
  * ===============================================================
    1.0     2021-03-24           I2MAX           Create
****************************************************************************************/
@IsTest
private class AssetTransferOrderLimitCancelQa_ts {
    @IsTest
    static void testBehavior() {
        //==============================================================================
        // Logic Test
        //==============================================================================
        Test.startTest();

        AssetTransferOrderLimitCancelQa.init(TestDataSalesFactory.baseAsset.Id);
        AssetTransferOrderLimitCancelQa.save(TestDataSalesFactory.baseAsset);

        Test.stopTest();
    }
}