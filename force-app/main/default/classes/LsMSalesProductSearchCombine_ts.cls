@IsTest
private class LsMSalesProductSearchCombine_ts {
    @IsTest
    static void testBehavior() {
        TestDataProductFactory.init();

        LsMSalesProductSearchCombine.InitData initData = LsMSalesProductSearchCombine.init(TestDataProductFactory.ProductCombine);

        System.assertNotEquals(initData.combineOptions, null);
        System.assertNotEquals(LsMSalesProductSearchCombine.search(TestDataProductFactory.ProductCombine), null);
    }
}