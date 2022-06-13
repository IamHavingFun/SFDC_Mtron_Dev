@IsTest
private class SalesPerformance_tr_ts {
    @IsTest
    static void testBehavior() {
        TestDataBaseFactory.init();

        SalesPerformance__c salesPerformance = TestDataBizFactory.baseSalesPerformance.clone(false, true);
        salesPerformance.Division__c = '계획';

        TestDataBaseFactory.agencyAccount.ERPCode__c = salesPerformance.CustomerCode__c;
        update TestDataBaseFactory.agencyAccount;

        insert salesPerformance;
    }

}