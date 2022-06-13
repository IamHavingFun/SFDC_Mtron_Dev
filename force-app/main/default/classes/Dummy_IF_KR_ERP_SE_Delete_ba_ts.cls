@IsTest
private class Dummy_IF_KR_ERP_SE_Delete_ba_ts {
    @IsTest
    static void testBehavior() {
        TestDataDummyBatchFactory.init();
        TestDataDummyBatchFactory.erpSe0001dummyDataBase.isBatchCompleted__c = true;
        update TestDataDummyBatchFactory.erpSe0001dummyDataBase;

        Dummy_IF_KR_ERP_SE_Delete_ba batch = new Dummy_IF_KR_ERP_SE_Delete_ba(new Dummy_IF_Batch.DeleteInfo(
            'IF_KR_ERP_SE_0001__c',
            'IF_KR_ERP_SE_0001',
            Dummy_IF_Batch.DUMMY_BATCH_PERIOD_TYPE.DAILY,
            System.now()
        ));

        Database.executeBatch(batch, 200);
        batch.execute(null, new List<SObject>{TestDataDummyBatchFactory.erpSe0001dummyDataBase});
    }
}