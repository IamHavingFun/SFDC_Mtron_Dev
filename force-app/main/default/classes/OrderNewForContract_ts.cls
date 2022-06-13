/****************************************************************************************
  * @filename      : OrderNewForContract_ts
  * @author        : i2max_my.Seo
  * @date          : 2020-12-17 오후 3:57
  * @group         :
  * @group-content :
  * @description   : 
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author            description
  * ===============================================================
    0.1     2020-12-17 오후 3:57     i2max_my.Seo         Create
****************************************************************************************/
@IsTest
private class OrderNewForContract_ts {
    @IsTest
    static void testBehavior() {
        //==============================================================================
        // Data Setting
        //==============================================================================
        TestDataBaseFactory.init();

        OrderNewQa.WrapperData wrapperData = new OrderNewQa.WrapperData();
        wrapperData.isInsert        = true;
        wrapperData.isPerFarCorp    = false;
        wrapperData.order           = TestDataSalesFactory.orderForNhGov.clone(false, true);

        //==============================================================================
        // Logic Test
        //==============================================================================
        System.assertNotEquals(null, OrderNewForContract.init());
        System.assertNotEquals(null, OrderNewForContract.save(wrapperData));
        System.assertNotEquals(null, OrderNewForContract.getTargetSoldToId(TestDataBaseFactory.personAccount.Id));
    }
}