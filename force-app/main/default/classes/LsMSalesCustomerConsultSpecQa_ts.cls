@IsTest
private class LsMSalesCustomerConsultSpecQa_ts {
    @IsTest
    static void testBehavior() {
        TestDataProductFactory.init();

        System.assertNotEquals(
            LsMSalesCustomerConsultSpecificationQa.getProductSeriesVOSSpecifications(
                TestDataProductFactory.baseProductSeries.Id
            )
        , null);
    }
}