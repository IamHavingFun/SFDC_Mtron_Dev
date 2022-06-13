/****************************************************************************************
  * @filename      : OrderCancelERPSend2_ba_ts
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
private class OrderCancelERPSend2_ba_ts {
	@IsTest
	static void testBehavior() {
		Order__c order = TestDataSalesFactory.orderForNhGov.clone(true, true);
		order.IsAutoCancel__c = true;
		order.ERPOrderCancelStatus__c = 'ZORT 취소성공';
		order.SalesDocNo__c = '11111111';
		update order;

		TransferOrder__c transferOrder = new TransferOrder__c(
				OrderLineitem__c = TestDataSalesFactory.oliForPerFarCorp.Id,
				Order__c = order.Id
		);

		insert transferOrder;

		Database.executeBatch(new OrderCancelERPSend2_ba(), 1);
	}
}