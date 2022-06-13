/**
** @filename     : OrderERPSendRetrunQa_ts
* @projectname   :
* @author        : CHOI SEONGWON
* @date          : 2020-07-20 오후 3:53
* @group         :
* @group-content :
* @description   : 반품 주문.
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
private class OrderERPSendRetrunQa_ts {
	@TestSetup
	static void setup() {
		/*
		 * ================================================================
		 * 필요시 IF_INFO__c 객체의 데이터를 변경하여 insert 할것
		 * one transaction 처리 때문에 TestSetup 에서 insert 할것
		 * ================================================================
		 */
		IF_INFO__c ifInfo = TestDataIFCalloutFactory.createIFInfo();
		ifInfo.IF_ID__c = 'IF_KR_SE_ERP_0007';
		insert ifInfo;
	}

	@IsTest
	static void testBehavior() {
		TestDataSalesFactory.init();
		TestDataProductFactory.init();

		List<Order__c> orderList = new List<Order__c>();
		Order__c order = TestDataSalesFactory.orderForPerFarCorp;
		Order__c order2 = order.clone(false, true);
		order2.SalesDocNo__c = '';
		order2.Division__c = '공장주문';
		order2.Status__c = '본사 주문 확정';
		orderList.add(order2);
		Order__c order3 = order2.clone(false, true);
		order3.SalesDocNo__c = '';
		order3.Division__c = 'test';
		orderList.add(order3);
		Order__c order4 = order2.clone(false, true);
		order4.SalesDocNo__c = '';
		order4.Status__c = '본사 여신 검토';
		orderList.add(order4);
		insert orderList;

		OrderERPSendRetrunQa.InitData initData = OrderERPSendRetrunQa.init(order.Id);
		System.assertNotEquals(initData.validMessage,null);
		for(Order__c o : orderList){
			initData = OrderERPSendRetrunQa.init(o.Id);
			System.assertNotEquals(initData.validMessage,null);
		}

		IfStaticValue__c ifStaticValue = TestDataIFCalloutFactory.createIfStaticValue();
		IF_Base.IfStaticValue(ifStaticValue);
		// Mock 객체 세팅
		Test.setMock(HttpCalloutMock.class, TestDataMockFactory.createSuccessCalloutMock(
				'{"Response":{"Header":{"TrackingId":"38a0f138-ca02-a983-ce9d-64dd5caf0911","TaskId":"IF_KR_SE_ERP_0007","SenderGroup":"CN","SenderCode":"CXP","ResultCode":"S","IFDatetime":"20190603085741","ErrorMsg":"","ErrorCode":"","DestinationGroup":"CN","DestinationCode":"ERP"},"Payload":{"TOTAL_RECORD_CNT":"2"}}}'
		));

		final String OrderId = order.Id;
		Test.startTest();
		OrderERPSendRetrunQa.sendERP(orderId, true);
		Test.stopTest();

	}
}