/****************************************************************************************
  * @filename      : OrderTransferSearchQa_ts
  * @author        : i2max_my.Seo
  * @date          : 2020-11-20 오후 4:46
  * @group         :
  * @group-content :
  * @description   : 
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author            description
  * ===============================================================
    0.1     2020-11-20 오후 4:46     i2max_my.Seo         Create
****************************************************************************************/
@IsTest
private class OrderTransferSearchQa_ts {
    @IsTest
    static void testBehavior() {
        //==============================================================================
        // Data Setting
        //==============================================================================
        Asset testAsset = TestDataSalesFactory.baseAsset.clone(false, true);
        testAsset.Name = '2300000001';
        testAsset.BatchNo__c = '2300000001';
        testAsset.BusinessOfficeName__c = '71A';
        testAsset.IsSendReceiveItem__c = true;
        testAsset.TransferOrder__c = null;
        testAsset.Order__c = null;

        insert testAsset;

        Map<String, String> reqMap = new Map<String, String>{
                'assetTransferTarget' => 'true',
                'assetName' => '123'
        };

        //==============================================================================
        // Logic Test
        //==============================================================================
        System.assertNotEquals(null, OrderTransferSearchQa.search(
                TestDataProductFactory.baseProduct2.Id,
                TestDataSalesFactory.orderForPerFarCorp.Id,
                reqMap));

        OrderTransferSearchQa.WrapperData wrapperData = new OrderTransferSearchQa.WrapperData();
        System.assertEquals(false, wrapperData.isRejected);

        OrderTransferSearchQa.InitData initData = new OrderTransferSearchQa.InitData();
        System.assertNotEquals(null, initData.businessOfficeNameList);
        System.assertNotEquals(null, initData.wrapperDataList);

        System.assertNotEquals(null, OrderTransferSearchQa.init(
                TestDataProductFactory.baseProduct2.Id,
                TestDataSalesFactory.orderForPerFarCorp.Id,
                new Map<String, String>()
        ));
    }
}