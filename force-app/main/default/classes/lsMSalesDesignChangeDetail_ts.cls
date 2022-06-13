/**
 * Created by MS on 2020-07-15.
 */

@IsTest
private class lsMSalesDesignChangeDetail_ts {
    @IsTest
    static void testBehavior() {
        TestDataBaseFactory.init();
        Product2 testProduct = TestDataProductFactory.baseProduct2;
        ProductChange__c pc = new ProductChange__c(
                DELETE_FLAG__c = false,
                Name = 'testProductChange',
                PECN_NAME__c = 'testProductChange',
                PDESC__c = 'test',
                PREGISTRATION_DATE__c = TestDataUtilFactory.d,
                PAPPLY_DATE__c = 'test data',
                PUNITEFFECTIVITY__c = 'test',
                SetDealerPublic__c = '공개'
        );
        insert pc;
        ProductChangeModel__c pcm = new ProductChangeModel__c(
                Name = 'testProductChangeModel',
                ProductChangeId__c = pc.Id,
                ProductId__r = testProduct,
                ProductId__c = testProduct.Id,
                PECN_ID__c = 'test',
                PLANT_ID__c = 'test',
                PSEQ__c = 'test'
        );
        insert pcm;

        ProductChange__c resultPc = lsMSalesDesignChangeDetail.init(pc.Id);
        /*System.assertEquals(pc.Id, resultPc.Id);
        System.assertEquals(pcm.Id, resultPc.ProductChange2__r[0].Id);
        System.assertEquals(pcm.ProductId__r.Id, resultPc.ProductChange2__r[0].ProductId__r.Id);*/
    }
}