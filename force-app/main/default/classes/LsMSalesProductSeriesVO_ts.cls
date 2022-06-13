@IsTest
private class LsMSalesProductSeriesVO_ts {
    @IsTest
    static void testBehavior() {
        LsMSalesProductSeriesVO lsMSalesProductSeriesVO = new LsMSalesProductSeriesVO();

        System.assertEquals(lsMSalesProductSeriesVO.sitePathPrefix, null);
        System.assertEquals(lsMSalesProductSeriesVO.productSeries, null);
        System.assertEquals(lsMSalesProductSeriesVO.productContents, null);
        System.assertEquals(lsMSalesProductSeriesVO.contentVersion, null);
    }
}