@IsTest
private class LsMSalesCustomerVO_ts {
    @IsTest
    static void testBehavior() {
        LsMSalesCustomerVO lsMSalesCustomerVO = new LsMSalesCustomerVO();
        System.assertEquals(lsMSalesCustomerVO.customer, null);
        System.assertEquals(lsMSalesCustomerVO.cupi, null);
    }
}