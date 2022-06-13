/****************************************************************************************
  * @filename      : OrderAssetTransferRequestQa_ts
  * @author        : i2max_my.Seo
  * @date          : 2021-01-18 오후 7:59
  * @group         :
  * @group-content :
  * @description   : 
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author            description
  * ===============================================================
    0.1     2021-01-18 오후 7:59     i2max_my.Seo         Create
****************************************************************************************/
@IsTest
private class OrderAssetTransferRequestQa_ts {
    @IsTest
    static void testBehavior() {
        TestDataSalesFactory.orderForPerFarCorp.PurposeOfOrder__c = '실판매기회';
        update TestDataSalesFactory.orderForPerFarCorp;

        //==============================================================================
        // Logic Test
        //==============================================================================
        System.assertNotEquals(null, OrderAssetTransferRequestQa.init(TestDataSalesFactory.orderForPerFarCorp.Id));
        System.assertNotEquals(null, OrderAssetTransferRequestQa.save(TestDataSalesFactory.orderForPerFarCorp));

        OrderAssetTransferRequestQa.InitData initData = new OrderAssetTransferRequestQa.InitData();

        initData.order = TestDataSalesFactory.orderForPerFarCorp;
        System.assertNotEquals(null, initData.isRequested);
        System.assertEquals(true, initData.isOpportunityOrder);
        System.assertNotEquals(null, initData.isPossible);
    }
}