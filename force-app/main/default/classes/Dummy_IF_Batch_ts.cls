@IsTest
private class Dummy_IF_Batch_ts {

    private class DummyIFBatchTest extends Dummy_IF_Batch {
        public override Database.QueryLocator start(Database.BatchableContext BC) {
            return Database.getQueryLocator([SELECT Id FROM User LIMIT 1]);
        }

        public override void execute(Database.BatchableContext BC, List<SObject> targetScope) {
            return;
        }

        public override void finish(Database.BatchableContext BC) {
            super.finish(BC);
            return;
        }
    }

    @IsTest
    static void testBehavior() {

        Test.startTest();

        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

        DummyIFBatchTest batch = new DummyIFBatchTest();
        System.assertNotEquals(batch, null);
        batch.deleteInfo = new Dummy_IF_Batch.DeleteInfo(
            'IF_KR_ERP_SE_0001__c',
            'IF_KR_ERP_SE_0001',
            Dummy_IF_Batch.DUMMY_BATCH_PERIOD_TYPE.DAILY,
            System.now()
        );
        System.assertNotEquals(batch.deleteInfo, null);
        System.assertNotEquals(batch.deleteInfo.dummyDeleteBaseDt, null);

        batch.deleteInfo.dummyBatchPeriodType = Dummy_IF_Batch.DUMMY_BATCH_PERIOD_TYPE.MONTHLY;
        System.assertNotEquals(batch.deleteInfo.dummyDeleteBaseDt, null);

        batch.deleteInfo.dummyBatchPeriodType = Dummy_IF_Batch.DUMMY_BATCH_PERIOD_TYPE.YEARLY;
        System.assertNotEquals(batch.deleteInfo.dummyDeleteBaseDt, null);
        System.assertEquals(batch.deleteInfo.fromBatchClass, null);

        batch.execute(null, new List<User>{u});
        batch.finish(null);

        Test.stopTest();

    }
}