@IsTest
private class LsMSalesCustomerConsultSearchCustomQa_ts {
    @IsTest
    static void testBehavior() {
        TestDataBaseFactory.init();
        String pRecordTypeId = TestDataUtilFactory.getRecordTypeId('Account','PersonAccount');
        String cRecordTypeId = TestDataUtilFactory.getRecordTypeId('Account','CorporationAccount');

        System.assertEquals(lsMSalesCustomerConsultSearchCustomerQa.init().account, null);
        System.assertNotEquals(lsMSalesCustomerConsultSearchCustomerQa.search('{"name": "test"}'), null);
        System.assertNotEquals(lsMSalesCustomerConsultSearchCustomerQa.search('{"name": "test", "accountRecordTypeId" : "'+pRecordTypeId+'"}'), null);
        System.assertNotEquals(lsMSalesCustomerConsultSearchCustomerQa.search('{"name": "test", "accountRecordTypeId" : "'+cRecordTypeId+'"}'), null);

    }
}