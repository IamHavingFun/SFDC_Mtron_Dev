/**
** @filename     : OrderAssetTransferApprovalQa_ts
* @projectname   :
* @author        : CHOI SEONGWON
* @date          : 2020-07-20 오후 3:35
* @group         :
* @group-content :
* @description   : 전수배 전환 동의 승인 처리.
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
private class OrderAssetTransferApprovalQa_ts {
	@IsTest
	static void testBehavior() {
		TestDataSalesFactory.init();

		OrderAssetTransferApprovalQa.InitData initData = OrderAssetTransferApprovalQa.init(TestDataSalesFactory.orderForPerFarCorp.Id);

		System.debug(initData.isProcessed);
		System.debug(initData.isNotRequested);

		OrderAssetTransferApprovalQa.setApprove(TestDataSalesFactory.orderForPerFarCorp, '승인');
		OrderAssetTransferApprovalQa.setReject(TestDataSalesFactory.orderForPerFarCorp, '거부');
	}
}