/****************************************************************************************
  * @filename      : OrderProductSearchQa_ts
  * @projectname   :
  * @author        : i2max_my.Seo
  * @date          : 2020-07-17 오전 10:24
  * @group         :
  * @group-content :
  * @description   : 
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author            description
  * ===============================================================
    0.1     2020-07-17 오전 10:24     i2max_my.Seo         Create
****************************************************************************************/
@IsTest
private class OrderProductSearchQa_ts {
    @IsTest
    static void testBehavior() {

        TestDataProductFactory.init();

        OrderProductSearchQa.InitData initData = new OrderProductSearchQa.InitData();

//        System.assertNotEquals(initData.productTypeList,null);
        System.assertEquals(initData.seriesList,null);



        System.assertNotEquals(OrderProductSearchQa.init(),null);

        String reqData ;
        reqData = '{"productType":"abc","series":"test","name":"test"}';
        OrderProductSearchQa.getSearch(reqData,10,1);

        OrderNewQa.WrapperData wrapperData = new OrderNewQa.WrapperData();

        wrapperData.order                   = TestDataSalesFactory.orderForPerFarCorp;
        wrapperData.orderLineItemList[0]    = TestDataSalesFactory.oliForPerFarCorp;
        wrapperData.isPerFarCorp            = true;

//        OrderService.calculatePrice(wrapperData);

        OrderProductSearchQa.calculatePrice(wrapperData);

        wrapperData.order                   = TestDataSalesFactory.orderForNhGov;
        wrapperData.orderLineItemList[0]    = TestDataSalesFactory.oliForNhGov;

//        OrderService.calculateResultPriceForNhGov(wrapperData);

        OrderProductSearchQa.calculatePriceForNhGov(wrapperData);
    }
}