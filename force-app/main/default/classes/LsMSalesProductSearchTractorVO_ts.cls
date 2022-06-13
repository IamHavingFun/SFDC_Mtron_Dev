@IsTest
private class LsMSalesProductSearchTractorVO_ts {
    @IsTest
    static void testBehavior() {
        LsMSalesProductSearchTractorVO lsMSalesProductSearchTractorVO = new LsMSalesProductSearchTractorVO();
        lsMSalesProductSearchTractorVO.infoData = new LsMSalesProductSearchTractorVO.InfoData();

        System.assertEquals(lsMSalesProductSearchTractorVO.infoData.searchProductSeries, null);

        lsMSalesProductSearchTractorVO.bizData = new LsMSalesProductSearchTractorVO.BizData();

        System.assertEquals(lsMSalesProductSearchTractorVO.bizData.productType, null);
        System.assertEquals(lsMSalesProductSearchTractorVO.bizData.productSeriesVO, null);
        System.assertEquals(lsMSalesProductSearchTractorVO.bizData.productVO, null);

    }
}