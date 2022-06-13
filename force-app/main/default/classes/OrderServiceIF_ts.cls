/****************************************************************************************
  * @filename      : OrderService_ts
  * @projectname   :
  * @author        : i2max_my.Seo
  * @date          : 2020-07-17 오전 10:24
  * @group         :
  * @group-content :
  * @description   :
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author            description
  * ===============================================================
    0.1     2020-07-17 오전 10:24     i2max_my.Seo         Create
****************************************************************************************/
@IsTest
private class OrderServiceIF_ts {
	@TestSetup
	static void setup() {
		IF_INFO__c ifInfo07 = TestDataIFCalloutFactory.createIFInfo();
		ifInfo07.IF_ID__c = 'IF_KR_SE_ERP_0007';
		ifInfo07.URL__c = '/api/dev/IF_KR_SE_ERP_0007.json';

		insert ifInfo07;
	}

	@IsTest
	static void testBehavior1() {
		// IF_KR_SE_ERP_0007 method.
		IfStaticValue__c ifStaticValue = TestDataIFCalloutFactory.createIfStaticValue();
		IF_Base.IfStaticValue(ifStaticValue);

		IF_KR_SE_ERP_0007.T_DATA t1 = new IF_KR_SE_ERP_0007.T_DATA();
		t1.OrderID          = TestDataSalesFactory.orderForPerFarCorp.Id;

		IF_KR_SE_ERP_0007.T_DATA t2 = new IF_KR_SE_ERP_0007.T_DATA();
		t2.OrderID          = TestDataSalesFactory.orderForPerFarCorp.Id;
		t2.ErpS_RESULT      = '00';
		t2.ErpPOSNR         = 'test';
		t2.SalesDocNo       = 'test';
		t2.ErpCMGST         = 'B';
		t2.ErpABGRU         = '95';
		t2.ErpS_MESSAGE     = 'Success';

		List<IF_KR_SE_ERP_0007.T_DATA> tData = new List<IF_KR_SE_ERP_0007.T_DATA>{t1, t2};

		String tDataString = JSON.serialize(tData);

		Test.setMock(HttpCalloutMock.class, TestDataMockFactory.createSuccessCalloutMock('{"response":{"header":{"TrackingId":"38a0f138-ca02-a983-ce9d-64dd5caf0911","TaskId":"IF_KR_SE_ERP_0007","SenderGroup":"CN","SenderCode":"CXP","ResultCode":"S","IFDatetime":"20190603085741","ErrorMsg":"","ErrorCode":"","DestinationGroup":"CN","DestinationCode":"ERP","ifResult":"S"},"payload":{"TOTAL_RECORD_CNT":"2","t_data":' + tDataString + '}}}'));

		final Id orderId = TestDataSalesFactory.orderForPerFarCorp.Id;

		Test.startTest();
		OrderServiceIF.OrderCancel_OR(orderId);
		Test.stopTest();
	}

	@IsTest
	static void testBehavior2() {
		IfStaticValue__c ifStaticValue = TestDataIFCalloutFactory.createIfStaticValue();
		IF_Base.IfStaticValue(ifStaticValue);

		//Order__c testOrder = TestDataSalesFactory.orderForPerFarCorp.clone(false, true);
		//insert testOrder;
		final Id orderId = TestDataSalesFactory.orderForPerFarCorp.Id;

		TransferOrder__c transferOrder = new TransferOrder__c(
				OrderLineitem__c = TestDataSalesFactory.oliForPerFarCorp.Id,
				Order__c = orderId
		);

		insert transferOrder;

		IF_KR_SE_ERP_0007.T_DATA t1 = new IF_KR_SE_ERP_0007.T_DATA();
		t1.OrderID          = orderId;

		List<IF_KR_SE_ERP_0007.T_DATA> tData = new List<IF_KR_SE_ERP_0007.T_DATA>{t1};

		String tDataString = JSON.serialize(tData);

		Test.setMock(HttpCalloutMock.class, TestDataMockFactory.createSuccessCalloutMock('{"response":{"header":{"TrackingId":"38a0f138-ca02-a983-ce9d-64dd5caf0911","TaskId":"IF_KR_SE_ERP_0007","SenderGroup":"CN","SenderCode":"CXP","ResultCode":"S","IFDatetime":"20190603085741","ErrorMsg":"","ErrorCode":"","DestinationGroup":"CN","DestinationCode":"ERP","ifResult":"S"},"payload":{"TOTAL_RECORD_CNT":"2","t_data":' + tDataString + '}}}'));

		Test.startTest();
		OrderServiceIF.OrderCancel_ZORT(orderId);
		Test.stopTest();
	}

	@IsTest
	static void testBehavior3() {
		IfStaticValue__c ifStaticValue = TestDataIFCalloutFactory.createIfStaticValue();
		IF_Base.IfStaticValue(ifStaticValue);

		final Id orderId = TestDataSalesFactory.orderForPerFarCorp.Id;

		TransferOrder__c transferOrder = new TransferOrder__c(
				OrderLineitem__c = TestDataSalesFactory.oliForPerFarCorp.Id,
				Order__c = orderId
		);

		insert transferOrder;

		IF_KR_SE_ERP_0007.T_DATA t1 = new IF_KR_SE_ERP_0007.T_DATA();
		t1.OrderID          = orderId;

		IF_KR_SE_ERP_0007.T_DATA t2 = new IF_KR_SE_ERP_0007.T_DATA();
		t2.OrderID          = orderId;
		t2.ErpS_RESULT      = '00';
		t2.ErpPOSNR         = 'test';
		t2.SalesDocNo       = 'test';
		t2.ErpCMGST         = 'B';
		t2.ErpABGRU         = '95';
		t2.ErpS_MESSAGE     = 'Success';

		List<IF_KR_SE_ERP_0007.T_DATA> tData = new List<IF_KR_SE_ERP_0007.T_DATA>{t1, t2};

		String tDataString = JSON.serialize(tData);

		Test.setMock(HttpCalloutMock.class, TestDataMockFactory.createSuccessCalloutMock('{"response":{"header":{"TrackingId":"38a0f138-ca02-a983-ce9d-64dd5caf0911","TaskId":"IF_KR_SE_ERP_0007","SenderGroup":"CN","SenderCode":"CXP","ResultCode":"S","IFDatetime":"20190603085741","ErrorMsg":"","ErrorCode":"","DestinationGroup":"CN","DestinationCode":"ERP","ifResult":"S"},"payload":{"TOTAL_RECORD_CNT":"2","t_data":' + tDataString + '}}}'));

		Test.startTest();
		OrderServiceIF.OrderCancel_ZRET(orderId);
		Test.stopTest();
	}

	@IsTest
	static void testBehavior4() {
		OrderServiceIF.runTest();
	}

	@IsTest
	static void testBehavior5() {
		// IF_KR_SE_ERP_0007 method.
		IfStaticValue__c ifStaticValue = TestDataIFCalloutFactory.createIfStaticValue();
		IF_Base.IfStaticValue(ifStaticValue);

		IF_KR_SE_ERP_0007.T_DATA t1 = new IF_KR_SE_ERP_0007.T_DATA();
		t1.OrderID          = TestDataSalesFactory.orderForPerFarCorp.Id;

		IF_KR_SE_ERP_0007.T_DATA t2 = new IF_KR_SE_ERP_0007.T_DATA();
		t2.OrderID          = TestDataSalesFactory.orderForPerFarCorp.Id;
		t2.ErpS_RESULT      = '00';
		t2.ErpPOSNR         = 'test';
		t2.SalesDocNo       = 'test';
		t2.ErpCMGST         = 'B';
		t2.ErpABGRU         = '95';
		t2.ErpS_MESSAGE     = 'Success';

		List<IF_KR_SE_ERP_0007.T_DATA> tData = new List<IF_KR_SE_ERP_0007.T_DATA>{t1, t2};

		String tDataString = JSON.serialize(tData);

		Test.setMock(HttpCalloutMock.class, TestDataMockFactory.createSuccessCalloutMock('{"response":{"header":{"TrackingId":"38a0f138-ca02-a983-ce9d-64dd5caf0911","TaskId":"IF_KR_SE_ERP_0007","SenderGroup":"CN","SenderCode":"CXP","ResultCode":"S","IFDatetime":"20190603085741","ErrorMsg":"","ErrorCode":"","DestinationGroup":"CN","DestinationCode":"ERP","ifResult":"S"},"payload":{"TOTAL_RECORD_CNT":"2","t_data":' + tDataString + '}}}'));

		OrderLineitem__c oli = TestDataSalesFactory.oliForPerFarCorp;
		//final Id orderId = TestDataSalesFactory.orderForPerFarCorp.Id;

		OrderKeep__c orderKeep = new OrderKeep__c();
		orderKeep.Order__c = oli.OrderId__c;
		insert orderKeep;

		System.debug('Id : ' + oli.OrderId__c);
		Test.startTest();
		OrderServiceIF.IF_KR_SE_ERP_0007_ZCS(oli.OrderId__c);
		Test.stopTest();
	}
}