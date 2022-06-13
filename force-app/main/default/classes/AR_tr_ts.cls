@IsTest
private class AR_tr_ts {
    @IsTest
    static void testBehavior() {
        TestDataBaseFactory.init();

        AR__c ar = TestDataBizFactory.baseAR.clone(false, true);
        ar.Division__c = '계획';

        TestDataBaseFactory.agencyAccount.ERPCode__c = ar.CustomerCode__c;
        update TestDataBaseFactory.agencyAccount;

        insert ar;
    }

}