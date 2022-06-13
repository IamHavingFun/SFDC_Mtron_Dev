@IsTest
private class LsMSalesProductSearchTractor_ts {
    @IsTest
    static void testBehavior() {
        TestDataProductFactory.init();

        System.assertNotEquals(LsMSalesProductSearchTractor.init(), null);
        System.assertNotEquals(LsMSalesProductSearchTractor.getProductSeriesVOSForType('{"productType":"트랙터"}'), null);
        System.assertNotEquals(LsMSalesProductSearchTractor.getProduct(TestDataProductFactory.baseProductSeries), null);
        System.assertNotEquals(LsMSalesProductSearchTractor.getProducts(TestDataProductFactory.baseProductSeries), null);
    }
}