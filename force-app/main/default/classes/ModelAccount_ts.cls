@IsTest
private class ModelAccount_ts {
    @IsTest
    static void testBehavior() {
        TestDataBaseFactory.init();

        ModelAccount mAccount = new ModelAccount(TestDataBaseFactory.agencyAccount);

        System.assertNotEquals(mAccount.isPersonAccount, null);
        System.assertNotEquals(mAccount.isBusinessAccount, null);
        System.assertNotEquals(mAccount.isBusinessOffice, null);
        System.assertNotEquals(mAccount.isAgency, null);
        System.assertNotEquals(mAccount.isGoverment, null);
        System.assertNotEquals(mAccount.isNH, null);
        System.assertNotEquals(mAccount.isPerson, null);
        System.assertNotEquals(mAccount.name, null);
        System.assertEquals(mAccount.email, null);
        System.assertEquals(mAccount.personContactId, null);
        System.assertNotEquals(mAccount.phone, null);

        System.assertNotEquals(ModelAccount.getAccounts(ModelAccount.ACCOUNT_RECORD_TYPE.BUSINESS, '', '', ''), null);
        System.assertNotEquals(ModelAccount.getAccounts(ModelAccount.ACCOUNT_RECORD_TYPE.PERSON, '', '', ''), null);

        System.assertNotEquals(ModelAccount.getAccounts(ModelAccount.ACCOUNT_CUSTOMER_TYPE.BUSINESSOFFICE, '', '', ''), null);
        System.assertNotEquals(ModelAccount.getAccounts(ModelAccount.ACCOUNT_CUSTOMER_TYPE.PERSON, '', '', ''), null);
        System.assertNotEquals(ModelAccount.getAccounts(ModelAccount.ACCOUNT_CUSTOMER_TYPE.AGENCY, '', '', ''), null);
        System.assertNotEquals(ModelAccount.getAccounts(ModelAccount.ACCOUNT_CUSTOMER_TYPE.GOVERMENT, '', '', ''), null);
        System.assertNotEquals(ModelAccount.getAccounts(ModelAccount.ACCOUNT_CUSTOMER_TYPE.NH, '', '', ''), null);

    }
}