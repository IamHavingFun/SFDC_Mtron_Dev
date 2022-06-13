@IsTest
private class LsMSalesProductService_ts {
    @IsTest
    static void testBehavior() {
        TestDataProductFactory.init();

        System.assertNotEquals(LsMSalesProductService.getProductSeriesVOS(
            TestDataProductFactory.baseProdSerRecStd.FarmingForm__c,
            TestDataProductFactory.baseProdSerRecStd.FarmingSize__c
        ), null);

        System.assertNotEquals(LsMSalesProductService.getProductSeriesVOSForType(
            TestDataProductFactory.baseProductSeries.ProductType__c,
            TestDataProductFactory.baseProductContentsList[0].ContentsType__c
        ), null);

        System.assertNotEquals(LsMSalesProductService.getProductSeriesVOSForId(
            TestDataProductFactory.baseProductSeries.Id,
            TestDataProductFactory.ProductTractor.ProductType__c
        ), null);

        System.assertNotEquals(LsMSalesProductService.getProduct(
            TestDataProductFactory.baseProductSeries
        ), null);

        System.assertNotEquals(LsMSalesProductService.getProducts(
            TestDataProductFactory.baseProductSeries
        ), null);

        System.assertNotEquals(LsMSalesProductService.getProductVO(
            TestDataProductFactory.ProductTractor.Id,
            LsMSalesProductService.carouselContentsTypeList
        ), null);

    }
}