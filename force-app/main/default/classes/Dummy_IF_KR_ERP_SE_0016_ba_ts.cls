@IsTest
private class Dummy_IF_KR_ERP_SE_0016_ba_ts {
    @IsTest
    static void testBehavior() {
        TestDataBaseFactory.init();
        TestDataDummyBatchFactory.init();
        //============================================================================
        // 필요시 Dummy 데이터 변경 및 추가
        //============================================================================
        IF_KR_ERP_SE_0006__c erpSe0006s = TestDataDummyBatchFactory.erpSe0006dummySalesPerformance.clone(false, true);
        erpSe0006s.ProductCode__c   = '00000001';
        erpSe0006s.ErpCode__c       = '001';
        erpSe0006s.SalesAmount__c   = 10000;
        erpSe0006s.SalesGroupName__c = '트랙터경기영업소';

        insert erpSe0006s;
        //============================================================================
        // 배치 실행
        //============================================================================\
        Database.executeBatch(new Dummy_IF_KR_ERP_SE_0016_ba(), 200);
    }
}