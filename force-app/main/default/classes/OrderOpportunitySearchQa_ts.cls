/****************************************************************************************
  * @filename      : OrderOpportunitySearchQa_ts
  * @projectname   :
  * @author        : i2max_my.Seo
  * @date          : 2020-07-17 오전 10:23
  * @group         :
  * @group-content :
  * @description   : 
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author            description
  * ===============================================================
    0.1     2020-07-17 오전 10:23     i2max_my.Seo         Create
****************************************************************************************/
@IsTest
private class OrderOpportunitySearchQa_ts {
    @IsTest
    static void testBehavior() {
        OrderOpportunitySearchQa.init();

        OrderOpportunitySearchQa.InitData initData = new OrderOpportunitySearchQa.InitData();

        System.assertNotEquals(initData.productTypeList, null);
        System.assertNotEquals(initData.seriesList, null);

        OrderOpportunitySearchQa.getSearch('{"productType":"트랙터", "series":"LV", "name":"MT3"}', 10, 1);

        OrderNewQa.WrapperData wrapperData = new OrderNewQa.WrapperData();
        wrapperData.order                   = TestDataSalesFactory.orderForPerFarCorp;
        wrapperData.orderLineItemList[0]    = TestDataSalesFactory.oliForPerFarCorp;
        wrapperData.isPerFarCorp            = true;

        OrderOpportunitySearchQa.calculatePrice(wrapperData);
    }
}