@IsTest
private class Dummy_IF_KR_ERP_SE_0004_ba_ts {
    @IsTest
    static void testBehavior() {
        TestDataBaseFactory.init();
        TestDataSalesFactory.init();
        TestDataDummyBatchFactory.init();

        Account testAcc = TestDataBaseFactory.businessOfficeAccount.clone(false, true);
        testAcc.Name = '공장재고';
        testAcc.ERPCode__c = '100000';

        insert testAcc;

        //============================================================================
        // 필요시 Dummy 데이터 변경 및 추가
        //============================================================================
        IF_KR_ERP_SE_0004__c erpSe0004s = TestDataDummyBatchFactory.erpSe0004dummyDataBase.clone(false, true);
        erpSe0004s.ProductCode__c       = '00000001';
        erpSe0004s.MachineNo__c         = '1234567891';

        insert erpSe0004s;

        IF_KR_ERP_SE_0004__c erpSe0004s2 = erpSe0004s.clone(false, true);
        // error 목적.
        erpSe0004s2.ProductionDate__c   = '----';

        insert erpSe0004s2;
        //============================================================================
        // 배치 실행
        //============================================================================\
        Database.executeBatch(new Dummy_IF_KR_ERP_SE_0004_ba(), 200);
    }
}