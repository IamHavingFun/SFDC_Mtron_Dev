/**
** @filename     : OrderKeepDeliveryQa_ts
* @projectname   :
* @author        : CHOI SEONGWON
* @date          : 2020-07-20 오후 3:53
* @group         :
* @group-content :
* @description   : 보관주문 - 출하지시
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
private class OrderKeepDeliveryQa_ts {
	@IsTest
	static void testBehavior() {
		/*
		 * ================================================================
		 * 필요시 IF_INFO__c 객체의 데이터를 변경하여 insert 할것
		 * one transaction 처리 때문에 TestSetup 에서 insert 할것
		 * ================================================================
		 */
		OrderKeepDeliveryQa.runTest();
	}
}