@IsTest
private class LsMSalesCustomerConsultVO_ts {
    @IsTest
    static void testBehavior() {
        LsMSalesCustomerConsultVO lsMSalesCustomerConsultVO = new LsMSalesCustomerConsultVO();
        lsMSalesCustomerConsultVO.infoData = new LsMSalesCustomerConsultVO.InfoData();

        System.assertNotEquals(lsMSalesCustomerConsultVO, null);
        System.assertEquals(lsMSalesCustomerConsultVO.infoData.searchProductSeries, null);

        lsMSalesCustomerConsultVO.bizData = new LsMSalesCustomerConsultVO.BizData();

        System.assertEquals(lsMSalesCustomerConsultVO.bizData.guidedSellingType, null);
        System.assertEquals(lsMSalesCustomerConsultVO.bizData.prodSerRecStd, null);
        System.assertEquals(lsMSalesCustomerConsultVO.bizData.productSeriesVO, null);
        System.assertEquals(lsMSalesCustomerConsultVO.bizData.productVO, null);
        System.assertEquals(lsMSalesCustomerConsultVO.bizData.customerVO, null);
        System.assertEquals(null, lsMSalesCustomerConsultVO.bizData.strCloseDate);
    }
}