@IsTest
private class ModelUser_ts {
    @IsTest
    static void testBehavior() {
        TestDataBaseFactory.init();

        ModelUser mUser = new ModelUser(TestDataBaseFactory.agencyUser);

        System.assertNotEquals(mUser, null);
        System.assertNotEquals(ModelUser.getDealerUserId(TestDataBaseFactory.agencyAccount.Id), null);
        System.assertNotEquals(ModelUser.getUserData(), null);

    }
}