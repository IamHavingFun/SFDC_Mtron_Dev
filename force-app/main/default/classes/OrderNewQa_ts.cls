/****************************************************************************************
  * @filename      : OrderNewQa_ts
  * @projectname   :
  * @author        : i2max_my.Seo
  * @date          : 2020-07-15 오전 9:17
  * @group         :
  * @group-content :
  * @description   : 
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author            description
  * ===============================================================
    0.1     2020-07-15 오전 9:17     i2max_my.Seo         Create
****************************************************************************************/
@IsTest
private class OrderNewQa_ts {
    /**
     * Test for NhGov.
     */
    @IsTest
    static void testBehavior() {
        TestDataBaseFactory.init();

        OrderNewQa.init(null);
        OrderNewQa.init(TestDataSalesFactory.orderForNhGov.Id);

        OrderNewQa.getTargetSoldTo(TestDataBaseFactory.governmentOrNHAccount.Id);

        //==============================================================================
        // Data Setting.
        //==============================================================================
        OrderNewQa.WrapperData wrapperData = new OrderNewQa.WrapperData();
        wrapperData.isInsert        = true;
        wrapperData.isPerFarCorp    = false;
        wrapperData.order           = TestDataSalesFactory.orderForNhGov;
        wrapperData.asset           = TestDataSalesFactory.baseAsset;
        wrapperData.orderLineItemList   = new List<OrderLineitem__c>{TestDataSalesFactory.oliForPerFarCorp.clone(false, true)};
        wrapperData.orderLineItemList[0].BaseSellingPrice__c = 1000;
        wrapperData.orderLineItemList[0].CorrectionPrice__c = 0;
        wrapperData.orderLineItemList[0].SellingPrice__c = 1000;
        wrapperData.orderLineItemList[0].ListPrice__c = 1000;
        wrapperData.orderLineItemList[0].UnitPrice__c = 1000;

        //OrderNewQa.save(wrapperData);

        //==============================================================================
        // InnerClass Coverage.
        //==============================================================================
        OrderNewQa.InitData initData = new OrderNewQa.InitData();

        OrderNewQa.WrapperData wrapperData2 = new OrderNewQa.WrapperData();
        System.assertEquals(wrapperData2.existAsset, null);
        System.assertEquals(wrapperData2.soldToInfo, null);
        System.assertEquals(wrapperData2.supplyHighAmt, 0);
        System.assertEquals(wrapperData2.supplyLowAmt, 0);
        System.assertEquals(wrapperData2.opptyName, null);
        System.assertEquals(wrapperData2.isValid, true);

        OrderNewQa.SoldToInfo soldToInfo = new OrderNewQa.SoldToInfo();
        System.assertNotEquals(soldToInfo.soldToList, null);

        OrderNewQa.runTest();
    }

    /**
     * Test for PerFarCorp
     */
    @IsTest
    static void testBehavior2() {
        TestDataBaseFactory.init();

        Product2 prod = TestDataProductFactory.baseProduct2.clone(false, true);
        prod.HorsePowerStandard__c  = '50';
        prod.Series__c              = 'MT3';
        prod.ProductType__c         = '트랙터';

        insert prod;

        TestDataSalesFactory.baseAsset.Product2Id = prod.Id;
        TestDataSalesFactory.baseAsset.Product2 = prod;

        update TestDataSalesFactory.baseAsset;

        OrderNewQa.WrapperData wrapperData = new OrderNewQa.WrapperData();
        wrapperData.isInsert            = true;
        wrapperData.isPerFarCorp        = true;
        wrapperData.order               = TestDataSalesFactory.orderForPerFarCorp;
        wrapperData.asset               = TestDataSalesFactory.baseAsset;
        wrapperData.orderLineItemList   = new List<OrderLineitem__c>{TestDataSalesFactory.oliForPerFarCorp.clone(false, true)};
        wrapperData.orderLineItemList[0].ListPrice__c = 1000;
        wrapperData.orderLineItemList[0].UnitPrice__c = 1000;
        wrapperData.orderLineItemList[0].BaseSellingPrice__c = 1000;
        wrapperData.orderLineItemList[0].CorrectionPrice__c = 0;
        wrapperData.orderLineItemList[0].SellingPrice__c = 1000;

//        ProductSeries__c productSeries = TestDataProductFactory.baseProductSeries.clone(false, true);
//        productSeries.Series__c = 'MT3';
//
//        insert productSeries;

        System.runAs(TestDataBaseFactory.agencyUser) {
            OrderNewQa.init(null);
            OrderNewQa.save(wrapperData);
            OrderNewQa.erpSave(wrapperData);
        }
    }
}