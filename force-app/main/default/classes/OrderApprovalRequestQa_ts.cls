/**
** @filename     : OrderApprovalRequestQa_ts
* @projectname   :
* @author        : CHOI SEONGWON
* @date          : 2020-07-21 오후 4:51
* @group         :
* @group-content :
* @description   : 주문 승인 요청
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
private class OrderApprovalRequestQa_ts {
	@IsTest
	static void testBehavior() {
		TestDataSalesFactory.init();

		OrderApprovalRequestQa.InitData initData = OrderApprovalRequestQa.init(TestDataSalesFactory.orderForPerFarCorp.Id);

		System.assertNotEquals(initData.isApprovalRequest,null);

		OrderApprovalRequestQa.submitForApproval(TestDataSalesFactory.orderForPerFarCorp.Id, '');
	}
}