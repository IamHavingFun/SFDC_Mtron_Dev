/****************************************************************************************
  * @filename      : AssetSendReceiveItemConfirm_ba_ts
  * @projectname   : LS
  * @author        : Park JW
  * @date          : 2020-07-20 오후 2:23
  * @group         :
  * @group-content :
  * @description   :
  * @tester        :
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                      author          description
  * ===============================================================
    0.1     2020-07-20 오후 2:23           Park JW         Create
****************************************************************************************/

@IsTest
private class AssetSendReceiveItemConfirm_ba_ts {
    @IsTest
    static void testBehavior() {
        TestDataBaseFactory.init();
        TestDataDummyBatchFactory.init();
        TestDataSalesFactory.init();

        Asset testAsset = TestDataSalesFactory.baseAsset.clone(false, true);
        testAsset.Order__c = null;
        testAsset.DealerReceiptDate__c = TestDataUtilFactory.d.addDays(-90);
        insert testAsset;

        Database.executeBatch(new AssetSendReceiveItemConfirm_ba(), 200);
    }
}