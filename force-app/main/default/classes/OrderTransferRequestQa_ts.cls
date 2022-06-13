/****************************************************************************************
  * @filename      : OrderTransferRequestQa_ts
  * @author        : i2max_my.Seo
  * @date          : 2020-11-20 오후 5:08
  * @group         :
  * @group-content :
  * @description   : 
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author            description
  * ===============================================================
    0.1     2020-11-20 오후 5:08     i2max_my.Seo         Create
****************************************************************************************/
@IsTest
private class OrderTransferRequestQa_ts {
    @IsTest
    static void testBehavior() {
        //==============================================================================
        // Data Setting
        //==============================================================================
        AssetTransferRequest__c testAssetTransferRequest = TestDataSalesFactory.baseAssetTransferRequest.clone(false, true);
        testAssetTransferRequest.Order__r = TestDataSalesFactory.orderForPerFarCorp;
        testAssetTransferRequest.TransferDealer__c = TestDataBaseFactory.agencyAccount.Id;

        //==============================================================================
        // Wrapper Data Test
        //==============================================================================
        OrderTransferRequestQa.InitData initData = new OrderTransferRequestQa.InitData();
        initData.assetTransferRequest = TestDataSalesFactory.baseAssetTransferRequest;
        System.assertEquals(null, initData.isTransferAgree);
        System.assertEquals(null, initData.isRequestProcess);
        System.assertEquals(null, initData.notiMessage);

        //==============================================================================
        // Logic Test
        //==============================================================================
        System.assertNotEquals(null, OrderTransferRequestQa.init(TestDataSalesFactory.orderForPerFarCorp.Id));
        System.assertNotEquals(null, OrderTransferRequestQa.save(testAssetTransferRequest));
    }

    @IsTest
    static void testBehavior2() {
        //==============================================================================
        // Data Setting
        //==============================================================================
        Order__c tempOrder = TestDataSalesFactory.orderForPerFarCorp.clone(false, true);
        tempOrder.AssetTransferAgreeStatus__c = '승인';

        insert tempOrder;

        OrderLineitem__c tempOli = TestDataSalesFactory.oliForPerFarCorp.clone(false, true);
        tempOli.OrderId__c = tempOrder.Id;

        insert tempOli;

        AssetTransferRequest__c testAssetTransferRequest = TestDataSalesFactory.baseAssetTransferRequest.clone(false, true);
        testAssetTransferRequest.Order__r = TestDataSalesFactory.orderForPerFarCorp;

        //==============================================================================
        // Logic Test
        //==============================================================================
        System.assertNotEquals(null, OrderTransferRequestQa.init(tempOrder.Id));
    }
}