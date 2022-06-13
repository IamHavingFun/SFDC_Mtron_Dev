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
private class OrderService_ts {
    @TestSetup
    static void setup() {
        IF_INFO__c ifInfo07 = TestDataIFCalloutFactory.createIFInfo();
        ifInfo07.IF_ID__c = 'IF_KR_SE_ERP_0007';
        ifInfo07.URL__c = '/api/dev/IF_KR_SE_ERP_0007.json';

        insert ifInfo07;
    }

    @IsTest
    static void testBehavior() {
        //==============================================================================
        // Data Setting.
        //==============================================================================
        TestDataSalesFactory.init();

        TestDataBaseFactory.governmentOrNHAccount.Dealer__c = TestDataBaseFactory.agencyAccount.Id;

        update TestDataBaseFactory.governmentOrNHAccount;

        //==============================================================================
        // Logic Test.
        //==============================================================================
        // calculatePrice method.
        TestDataSalesFactory.oliForPerFarCorp.ProductId__c = TestDataProductFactory.baseProduct2.Id;
        TestDataSalesFactory.oliForPerFarCorp.ProductId__r = TestDataProductFactory.baseProduct2;

        update TestDataSalesFactory.oliForPerFarCorp;

        OrderNewQa.WrapperData wrapperData = new OrderNewQa.WrapperData();
        wrapperData.order                   = TestDataSalesFactory.orderForPerFarCorp;
        wrapperData.orderLineItemList[0]    = TestDataSalesFactory.oliForPerFarCorp;
        wrapperData.isPerFarCorp            = true;

        OrderService.calculatePrice(wrapperData);

        // getTargetSoldTo method.
        OrderService.getTargetSoldTo(TestDataBaseFactory.governmentOrNHAccount.Id);

        // getTargetSoldToId method. 2020-12-15 추가.
        System.assertNotEquals(null, OrderService.getTargetSoldToId(TestDataBaseFactory.governmentOrNHAccount.Id));

        // calculateResultPriceForNhGov method.
        wrapperData.order                   = TestDataSalesFactory.orderForNhGov;
        wrapperData.orderLineItemList[0]    = TestDataSalesFactory.oliForNhGov;

        OrderService.calculateResultPriceForNhGov(wrapperData);

        TestDataBaseFactory.governmentOrNHAccount.CustomerType__c = '농협';
//        update TestDataBaseFactory.governmentOrNHAccount;

        OrderService.calculateResultPriceForNhGov(wrapperData);

        // getProductSeriesList method.
        OrderService.getProductSeriesList('트랙터');

        // validForOrder method.
        OrderService.validForOrder(TestDataBaseFactory.agencyAccount.Id);

        // isPartner method.
        System.assertNotEquals(OrderService.isPartner(), true);

        // loanApprovalCompleteReturnERP method.
        OrderApprover__c orderApprover = new OrderApprover__c(
                OrderSellIn__c = TestDataSalesFactory.orderForPerFarCorp.Id,
                ExternalKey__c = 'test'
        );

        insert orderApprover;

        OrderService.loanApprovalCompleteReturnERP(new Set<Id>{TestDataSalesFactory.orderForPerFarCorp.Id});


        OrderService.runTest();
    }

    @IsTest
    static void testBehavior2() {
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
        OrderService.IF_KR_SE_ERP_0007(orderId);
//        OrderService.IF_KR_SE_ERP_0007_ZRET(testOrder.Id);
//        OrderService.IF_KR_SE_ERP_0007_ZORT(orderId);
        Test.stopTest();
    }

    @IsTest
    static void testBehavior3() {
        IfStaticValue__c ifStaticValue = TestDataIFCalloutFactory.createIfStaticValue();
        IF_Base.IfStaticValue(ifStaticValue);

        Order__c testOrder = TestDataSalesFactory.orderForPerFarCorp.clone(false, true);
        insert testOrder;

        TransferOrder__c transferOrder = new TransferOrder__c(
                OrderLineitem__c = TestDataSalesFactory.oliForPerFarCorp.Id,
                Order__c = testOrder.Id
        );

        insert transferOrder;

        IF_KR_SE_ERP_0007.T_DATA t1 = new IF_KR_SE_ERP_0007.T_DATA();
        t1.OrderID          = testOrder.Id;

        List<IF_KR_SE_ERP_0007.T_DATA> tData = new List<IF_KR_SE_ERP_0007.T_DATA>{t1};

        String tDataString = JSON.serialize(tData);

        Test.setMock(HttpCalloutMock.class, TestDataMockFactory.createSuccessCalloutMock('{"response":{"header":{"TrackingId":"38a0f138-ca02-a983-ce9d-64dd5caf0911","TaskId":"IF_KR_SE_ERP_0007","SenderGroup":"CN","SenderCode":"CXP","ResultCode":"S","IFDatetime":"20190603085741","ErrorMsg":"","ErrorCode":"","DestinationGroup":"CN","DestinationCode":"ERP","ifResult":"S"},"payload":{"TOTAL_RECORD_CNT":"2","t_data":' + tDataString + '}}}'));

        Test.startTest();
        OrderService.IF_KR_SE_ERP_0007_ZRET(testOrder.Id);
        Test.stopTest();
    }

    @IsTest
    static void testBehavior4() {
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

        Test.startTest();
        OrderService.IF_KR_SE_ERP_0007_ZORT(TestDataSalesFactory.orderForPerFarCorp.Id);
        Test.stopTest();
    }
}