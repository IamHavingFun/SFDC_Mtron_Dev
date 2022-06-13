@IsTest
private class Dummy_IF_KR_ERP_SE_0001_ba_ts {
    @IsTest
    static void testBehavior() {
        TestDataBaseFactory.init();
        TestDataDummyBatchFactory.init();
         //============================================================================
         // 필요시 Dummy 데이터 변경 및 추가
         //============================================================================
        IF_KR_ERP_SE_0001__c erpSe0001s3 = TestDataDummyBatchFactory.erpSe0001dummyDataBase.clone(false, true);
        erpSe0001s3.ErpPriceType__c = 'test';
        erpSe0001s3.ERPCode__c = '002';
        insert erpSe0001s3;

        IF_KR_ERP_SE_0001__c erpSe0001s2 = TestDataDummyBatchFactory.erpSe0001dummyDataBase.clone(false, true);
        erpSe0001s2.BusinessOffice__c = '';
        erpSe0001s2.ErpPriceType__c = 'test';
        insert erpSe0001s2;

        IF_KR_ERP_SE_0001__c erpSe0001s = TestDataDummyBatchFactory.erpSe0001dummyDataBase.clone(false, true);
        erpSe0001s.ERPCode__c = '';
        insert erpSe0001s;

        //============================================================================
        // 배치 실행
        //============================================================================\
        Database.executeBatch(new Dummy_IF_KR_ERP_SE_0001_ba(), 200);
    }
}