@IsTest
private class LsMSalesProductSearchRiceTransplanter_ts {
    @IsTest
    static void testBehavior() {
        TestDataProductFactory.init();

        final LsMSalesProductSearchRiceTransplanter.InitData initData = LsMSalesProductSearchRiceTransplanter.init(TestDataProductFactory.ProductRiceTransplanter);

        System.assertNotEquals(initData.riceTransplanterOptions, null);
        System.assertNotEquals(LsMSalesProductSearchRiceTransplanter.getHorsePowerStandardOptions(TestDataProductFactory.ProductRiceTransplanter), null);
        System.assertNotEquals(LsMSalesProductSearchRiceTransplanter.search(TestDataProductFactory.ProductRiceTransplanter), null);
    }
}