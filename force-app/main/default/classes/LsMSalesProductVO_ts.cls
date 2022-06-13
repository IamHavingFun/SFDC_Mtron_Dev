@IsTest
private class LsMSalesProductVO_ts {
    @IsTest
    static void testBehavior() {
        LsMSalesProductVO lsMSalesProductVO = new LsMSalesProductVO();

        System.assertEquals(lsMSalesProductVO.sitePathPrefix, null);
        System.assertEquals(lsMSalesProductVO.product, null);
        System.assertEquals(lsMSalesProductVO.productContentsDataList, null);
        System.assertEquals(lsMSalesProductVO.productContentsCatalogueDataList, null);
        System.assertEquals(lsMSalesProductVO.productContentsVideoDataList, null);

        LsMSalesProductVO.ProductContentsData productContentsData = new LsMSalesProductVO.ProductContentsData(null, null);

        System.assertEquals(productContentsData.productContents, null);
        System.assertEquals(productContentsData.contentVersions, null);

    }
}