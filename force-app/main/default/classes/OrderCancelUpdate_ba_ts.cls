/****************************************************************************************
  * @filename      : OrderCancelUpdate_ba_ts
  * @author        : i2max_my.Seo
  * @date          : 2021-04-14 오후 4:49
  * @group         :
  * @group-content :
  * @description   :
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date           author            description
  * ===============================================================
    0.1     2021-04-15     i2max_my.Seo      Create
****************************************************************************************/
@IsTest
private class OrderCancelUpdate_ba_ts {
    @IsTest
    static void testBehavior() {
        Order__c order = TestDataSalesFactory.orderForNhGov.clone(true, true);
        order.OrderScheduleDate__c = System.today().addMonths(-1).toStartOfMonth();
        update order;

        Database.executeBatch(new OrderCancelUpdate_ba(), 200);
    }
}