/**
 * Created by MS on 2020-07-15.
 */

@IsTest
private class lsMSalesDesignChange_ts {
    @IsTest
    static void testBehavior() {
        TestDataBaseFactory.init();
        Product2 testProduct = TestDataProductFactory.baseProduct2;
        ProductChange__c pc = new ProductChange__c(
                DELETE_FLAG__c = false,
                Name = 'testProductChange',
                PECN_NAME__c = 'testProductChange',
                PREGISTRATION_DATE__c = TestDataUtilFactory.d,
                SetDealerPublic__c = '공개'
        );
        insert pc;
        ProductChangeModel__c pcm = new ProductChangeModel__c(
                Name = 'testProductChangeModel',
                ProductChangeId__c = pc.Id,
                ProductId__c = testProduct.Id
        );
        insert pcm;

        lsMSalesDesignChange.init();
        I2ComClass.ResData resData = lsMSalesDesignChange.getSearch('{"pageSize":"5","productName":"' + testProduct.Name + '"}', 5, 1);
        System.assertEquals(1, resData.totalSize);
    }
}