@IsTest
private class Dummy_IF_KR_ERP_SE_0012_ba_ts {
/*
    @IsTest
    static void testBehavior() {

        TestDataBaseFactory.init();
        TestDataSalesFactory.init();
        TestDataDummyBatchFactory.init();
        TestDataBizFactory.init();
        //============================================================================
        // 필요시 Dummy 데이터 변경 및 추가
        //============================================================================

        Account testBusinessAccount = TestDataBaseFactory.businessOfficeAccount.clone(false, true);
        testBusinessAccount.ERPCode__c = '71I';
        insert testBusinessAccount;

        Account testAccount = TestDataBaseFactory.agencyAccount.clone(false, true);
        testAccount.BusinessOffice__c = testBusinessAccount.Id;
        insert testAccount;

        IF_KR_ERP_SE_0012__c erpSe0012 = TestDataDummyBatchFactory.erpSe0012dummyDataBase.clone(false, true);
        erpSe0012.ProductCode__c = null;
        erpSe0012.DealerCode__c = null;
        erpSe0012.ErpOUT_DATE__c = null;
        insert erpSe0012;

        IF_KR_ERP_SE_0012__c erpSe0012_2 = TestDataDummyBatchFactory.erpSe0012dummyDataBase;

        IF_KR_ERP_SE_0012__c erpSe0012_3 = TestDataDummyBatchFactory.erpSe0012dummyDataBase.clone(false, true);
        erpSe0012_3.SalesDocNo__c = '222';
        erpSe0012_3.DeliveryType__c = '보관출고';
        erpSe0012_3.DealerCode__c = testAccount.ERPCode__c;
        erpSe0012_3.DeliveryCode__c = testAccount.ERPCode__c;
        erpSe0012_3.Asset__c = '2390000001';
        erpSe0012_3.BatchNo__c = '2390000001';
        insert erpSe0012_3;

        IF_KR_ERP_SE_0012__c erpSe0012_4 = TestDataDummyBatchFactory.erpSe0012dummyDataBase.clone(false, true);
        erpSe0012_4.SalesDocNo__c = '222';
        erpSe0012_4.DeliveryType__c = '공장주문';
        erpSe0012_4.DealerCode__c = testAccount.ERPCode__c;
        erpSe0012_4.DeliveryCode__c = testAccount.ERPCode__c;
        erpSe0012_4.Asset__c = '2390000002';
        erpSe0012_3.BatchNo__c = '2390000002';
        insert erpSe0012_4;

        Order__c testOrder = TestDataSalesFactory.orderForPerFarCorp;
        Order__c testOrder2 = TestDataSalesFactory.orderForPerFarCorp;
        testOrder2.SalesDocNo__c = '222';
        update testOrder2;

        Delivery__c testDelivery = TestDataBizFactory.baseDelivery.clone(false, true);
        testDelivery.Externalkey__c = erpSe0012.SalesDocNo__c+'|'+erpSe0012.SalesDocItem__c+'|'+erpSe0012.ErpOUT_DATE__c+'|'+erpSe0012.DealerCode__c;
        insert testDelivery;

        Delivery__c testDelivery_2 = TestDataBizFactory.baseDelivery.clone(false, true);
        testDelivery_2.Externalkey__c = erpSe0012_2.SalesDocNo__c+'|'+erpSe0012_2.SalesDocItem__c+'|'+erpSe0012_2.ErpOUT_DATE__c+'|'+erpSe0012_2.DealerCode__c;
        insert testDelivery_2;

        Delivery__c testDelivery_3 = TestDataBizFactory.baseDelivery.clone(false, true);
        testDelivery_2.Externalkey__c = erpSe0012_2.SalesDocNo__c+'|'+erpSe0012_2.SalesDocItem__c+'|'+erpSe0012_2.ErpOUT_DATE__c+'|dffff';
        insert testDelivery_3;

        //============================================================================
        // 배치 실행
        //============================================================================\
        Database.executeBatch(new Dummy_IF_KR_ERP_SE_0012_ba(), 200);

    }

 */
    @IsTest
    static void testBehavior2() {
        Dummy_IF_KR_ERP_SE_0012_ba.runFakeTest();
        Dummy_IF_KR_ERP_SE_0012_2_ba.runFakeTest();
    }
}