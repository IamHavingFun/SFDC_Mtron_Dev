/****************************************************************************************
  * @filename      : OrderCancelQa_ts
  * @author        : I2MAX
  * @date          : 2021-05-10
  * @group         :
  * @group-content :
  * @description   : 
  * @reference     :
  * @release       : v1.0.0
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author         description
  * ===============================================================
    1.0     2021-05-10           I2MAX           Create
****************************************************************************************/
@IsTest
private class OrderCancelQa_ts {

    @IsTest
    static void testBehavior1() {
        //==============================================================================
        // Logic Test
        //==============================================================================
        System.assertNotEquals(null, OrderCancelQa.init(TestDataSalesFactory.orderForPerFarCorp.Id));
        OrderCancelQa.save(TestDataSalesFactory.orderForPerFarCorp);
    }

    @IsTest
    static void testBehavior2() {
        //==============================================================================
        // Logic Test
        //==============================================================================
        IfStaticValue__c ifStaticValue = TestDataIFCalloutFactory.createIfStaticValue();
        IF_Base.IfStaticValue(ifStaticValue);

        final Id orderId = TestDataSalesFactory.orderForPerFarCorp.Id;

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

        System.assertNotEquals(null, OrderCancelQa.init(orderId));
        List<IF_KR_SE_ERP_0007.T_DATA> tData = new List<IF_KR_SE_ERP_0007.T_DATA>{t1, t2};

        String tDataString = JSON.serialize(tData);
        Test.setMock(HttpCalloutMock.class, TestDataMockFactory.createSuccessCalloutMock('{"response":{"header":{"TrackingId":"38a0f138-ca02-a983-ce9d-64dd5caf0911","TaskId":"IF_KR_SE_ERP_0007","SenderGroup":"CN","SenderCode":"CXP","ResultCode":"S","IFDatetime":"20190603085741","ErrorMsg":"","ErrorCode":"","DestinationGroup":"CN","DestinationCode":"ERP","ifResult":"S"},"payload":{"TOTAL_RECORD_CNT":"2","t_data":' + tDataString + '}}}'));
        Test.startTest();
        OrderCancelQa.callIF(TestDataSalesFactory.orderForPerFarCorp, 'OR');
        Test.stopTest();
    }


    @IsTest
    static void testBehavior3() {
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
        OrderCancelQa.callIF(TestDataSalesFactory.orderForPerFarCorp, 'ZORT');
        Test.stopTest();
    }


    @IsTest
    static void testBehavior4() {
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
        OrderCancelQa.callIF(TestDataSalesFactory.orderForPerFarCorp, 'ZRET');
        Test.stopTest();
    }
}