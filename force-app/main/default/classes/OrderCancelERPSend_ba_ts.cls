/****************************************************************************************
  * @filename      : OrderCancelAlarm_ba_ts
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
private class OrderCancelERPSend_ba_ts {
	@IsTest
	static void testBehavior() {
		Order__c order = TestDataSalesFactory.orderForNhGov.clone(true, true);
		order.IsAutoCancel__c = true;
		order.SalesDocNo__c = '11111111';
		update order;

		Database.executeBatch(new OrderCancelERPSend_ba(), 1);
	}
	@IsTest
	static void testBehavior2() {
		Order__c order = TestDataSalesFactory.orderForNhGov.clone(true, true);
		order.IsAutoCancel__c = true;
		order.Division__c = '전수배';
		update order;

		Database.executeBatch(new OrderCancelERPSend_ba(), 1);
	}
}