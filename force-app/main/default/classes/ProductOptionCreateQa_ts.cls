/****************************************************************************************
 * @filename      : ProductOptionCreateQa_ts
 * @projectname   : 
 * @author        : SEOKHO LEE
 * @date          : 2020-09-02 오전 9:51
 * @group         :
 * @group-content :
 * @description   :
 * @tester        :
 * @reference     :
 * @copyright     : Copyright © I2max. All Rights Reserved.
 * @modification Log
 * ===============================================================
 * ver     date                     author              description
 * ===============================================================
 0.1     2020-09-02 오전 9:51        SEOKHO LEE          Create
 ****************************************************************************************/

@isTest
private class ProductOptionCreateQa_ts {
    @isTest
    static void testBehavior() {
        ProductOptionCreateQa.InitData initData = new ProductOptionCreateQa.InitData();
        System.assertNotEquals(initData.productFeaturesList, null);

        ProductOptionCreateQa.init(TestDataProductFactory.baseProduct2.Id);
        Product2 workingMachineProduct = TestDataProductFactory.baseProduct2.clone(false, true);
        workingMachineProduct.Type__c = '작업기';
        workingMachineProduct.Segment__c = '로더';
        insert workingMachineProduct;

        ProductFeature__c pf = TestDataProductFactory.baseProductFeature.clone(false, true);
        pf.Name = '로더';
        pf.Product__c = TestDataProductFactory.baseProduct2.Id;
        insert pf;

        String reqData = '{"featureId":"'+pf.Id+'", "workingMachineId":"'+workingMachineProduct.Id+'" }';
        ProductOptionCreateQa.save(reqData, TestDataProductFactory.baseProduct2);

    }
}