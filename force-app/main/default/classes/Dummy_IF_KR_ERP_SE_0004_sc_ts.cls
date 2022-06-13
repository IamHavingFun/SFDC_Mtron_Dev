@IsTest
private class Dummy_IF_KR_ERP_SE_0004_sc_ts {
    @IsTest
    static void testBehavior() {
        Account testAcc = TestDataBaseFactory.businessOfficeAccount.clone(false, true);
        testAcc.Name = '공장재고';
        testAcc.ERPCode__c = '100000';

        insert testAcc;

        Dummy_IF_KR_ERP_SE_0004_sc.runSchedule();
        Dummy_IF_KR_ERP_SE_0004_sc.abortSchedule();
    }
}