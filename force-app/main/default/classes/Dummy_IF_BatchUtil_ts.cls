@IsTest
private class Dummy_IF_BatchUtil_ts {

    @IsTest
    static void testBehavior() {
        TestDataBaseFactory.init();

        System.assertNotEquals(Dummy_IF_BatchUtil.getIFDate('20200101'), null);
        try {
            System.assertNotEquals(Dummy_IF_BatchUtil.getIFDate('00020101'), null);
        }
        catch(Exception e){}
        System.assertNotEquals(Dummy_IF_BatchUtil.getIFDate('2020-01-01'), null);
        System.assertNotEquals(Dummy_IF_BatchUtil.getIFDateTime('20200101091112'), null);
        System.assertNotEquals(Dummy_IF_BatchUtil.getIFDateTime('2020-01-01091112'), null);
        try {
            System.assertNotEquals(Dummy_IF_BatchUtil.getIFDateTime('0002-01-01091112'), null);
        }
        catch(Exception e){}
        System.assertNotEquals(Dummy_IF_BatchUtil.getIFDateTime('20200101'), null);

        System.assert(Dummy_IF_BatchUtil.isValidCurrency(null), true);

        IF_KR_ERP_SE_0001__c dummy = new IF_KR_ERP_SE_0001__c(
            isBatchCompleted__c = false,
            isBatchError__c = false,
            BatchErrorMessage__c = ''
        );

        System.assertNotEquals(Dummy_IF_BatchUtil.setDummyBatchResult(
            dummy,
            new List<Id>()
        ), null);

        System.assertNotEquals(Dummy_IF_BatchUtil.setDummyBatchResult(
            dummy,
            Dummy_IF_BatchUtil.DUMMY_BATCH_ERROR_DML,
            new List<Id>()
        ), null);

        System.assertNotEquals(Dummy_IF_BatchUtil.setDummyBatchResult(
            dummy,
            Dummy_IF_BatchUtil.DUMMY_BATCH_ERROR_DML,
            new List<Id>(),
            null
        ), null);

        System.assertNotEquals(Dummy_IF_BatchUtil.setDummyBatchResult(
            new List<IF_KR_ERP_SE_0001__c>{dummy},
            new List<Id>()
        ), null);

        System.assertNotEquals(Dummy_IF_BatchUtil.setDummyBatchResult(
            new List<IF_KR_ERP_SE_0001__c>{dummy},
            Dummy_IF_BatchUtil.DUMMY_BATCH_ERROR_DML,
            new List<Id>()
        ), null);

        System.assertNotEquals(Dummy_IF_BatchUtil.setDummyBatchResult(
            new List<IF_KR_ERP_SE_0001__c>{dummy},
            new List<Id>(),
            null
        ), null);

        System.assertNotEquals(Dummy_IF_BatchUtil.setDummyBatchResult(
            new List<IF_KR_ERP_SE_0001__c>{dummy},
            new List<Id>()
        ), null);

        System.assertNotEquals(Dummy_IF_BatchUtil.getRecordOwnder('IF_KR_ERP_SE_0012', new Set<String>{'011', '021', '111'}), null);
        System.assertNotEquals(Dummy_IF_BatchUtil.getDealerOwner(new Set<String>{'011', '021', '111'}), null);
        System.assertNotEquals(Dummy_IF_BatchUtil.getErpCodeLpad('1'), null);
        System.assertNotEquals(Dummy_IF_BatchUtil.getProductCodeLpad('1'), null);
        System.assertNotEquals(Dummy_IF_BatchUtil.getTargetProduct2(), null);

        System.assertNotEquals(new Dummy_IF_BatchUtil.DummyValidException('error'), null);

        Dummy_IF_BatchUtil.getEmployeeNumber();
        System.assertNotEquals(Dummy_IF_BatchUtil.getBooleanFromString('Y'), null);

        System.assertNotEquals(Dummy_IF_BatchUtil.getTypeFromProductCode('1'), null);
        System.assertNotEquals(Dummy_IF_BatchUtil.getTypeFromProductCode('3'), null);
        System.assertEquals(Dummy_IF_BatchUtil.getTypeFromProductCode('2'), null);
        System.assertEquals(Dummy_IF_BatchUtil.getTypeFromProductCode(null), null);


        System.assertEquals(Dummy_IF_BatchUtil.getNumber(null), null);
        System.assertNotEquals(Dummy_IF_BatchUtil.getNumber('100'), null);

        System.assertNotEquals(Dummy_IF_BatchUtil.setDummyBatchDupResult(
            new List<IF_KR_ERP_SE_0001__c>{dummy}
        ), null);

    }
}