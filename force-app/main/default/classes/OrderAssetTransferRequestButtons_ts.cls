/**
** @filename     : OrderAssetSearchQa_ts
* @projectname   :
* @author        : CHOI SEONGWON
* @date          : 2020-07-20 오후 3:35
* @group         :
* @group-content :
* @description   :
* @tester        :
* @reference     :
* @copyright     : Copyright © I2max. All Rights Reserved.
* @modification Log
* ===============================================================
* ver     date             author              description
* ===============================================================
  0.1                            Create
 */
@IsTest
private class OrderAssetTransferRequestButtons_ts {
	@IsTest
	static void testBehavior() {
		TestDataSalesFactory.init();

		OrderAssetTransferRequestButtons.InitData initData = OrderAssetTransferRequestButtons.init(TestDataSalesFactory.orderForPerFarCorp.Id);

		System.assertEquals(initData.isRequested,false);

	}
}