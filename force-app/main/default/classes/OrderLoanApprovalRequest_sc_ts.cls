/**
** @filename     : OrderLoanApprovalRequest_sc_ts
* @projectname   :
* @author        : CHOI SEONGWON
* @date          : 2020-07-21 오후 4:51
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
private class OrderLoanApprovalRequest_sc_ts {
	@IsTest
	static void testBehavior() {
		TestDataSalesFactory.init();

		OrderLoanApprovalRequest_sc.runSchedule(TestDataSalesFactory.orderForPerFarCorp.Id);
	}
}