@IsTest
private class Dummy_IF_KR_ERP_SE_0006_ba_ts {
    @IsTest
    static void testBehavior() {
        TestDataBaseFactory.init();
        TestDataDummyBatchFactory.init();
        //============================================================================
        // 필요시 Dummy 데이터 변경 및 추가
        //============================================================================
        IF_KR_ERP_SE_0006__c erpSe0006s = TestDataDummyBatchFactory.erpSe0006dummyActualSales.clone(false, true);
        erpSe0006s.DataType__c = 'C';
        erpSe0006s.QueryDate__c = '202001';
        erpSe0006s.SalesDate__c = '-------';

        insert erpSe0006s;

        Product2 product = TestDataProductFactory.baseProduct2.clone(false, true);
        product.ProductCode = '001';

        insert product;
        //============================================================================
        // 배치 실행
        //============================================================================\
        Database.executeBatch(new Dummy_IF_KR_ERP_SE_0006_ba(), 200);
    }
}