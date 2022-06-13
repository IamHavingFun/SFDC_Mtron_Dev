/****************************************************************************************
 * @filename      : LsMSalesPDIVO_ts
 * @projectname   :
 * @author        : i2max_my.Seo
 * @date          : 2020-07-09 오후 02:04
 * @group         :
 * @group-content :
 * @description   :
 * @tester        :
 * @reference     :
 * @copyright     : Copyright ⓒ I2max. All Rights Reserved.
 * @modification Log
 * ===============================================================
 * ver     date                     author              description
 * ===============================================================
 0.1     2020-07-09 오후 02:04      i2max_my.Seo         Create
 ****************************************************************************************/

@IsTest
private class LsMSalesPDIVO_ts {
    @IsTest
    static void testBehavior() {
        LsMSalesPDIVO pdivo = new LsMSalesPDIVO();
        pdivo.bizData = new LsMSalesPDIVO.BizData();

        System.assertEquals(pdivo.bizData.isPDI, null);
        System.assertEquals(pdivo.bizData.isViewMode, null);
        System.assertEquals(pdivo.bizData.asset, null);
        System.assertEquals(pdivo.bizData.assetPrice, null);
        System.assertEquals(pdivo.bizData.targetContracts, null);
        System.assertEquals(pdivo.bizData.contract, null);
        System.assertEquals(pdivo.bizData.contractItem, null);
        System.assertEquals(pdivo.bizData.pdi, null);
        System.assertEquals(pdivo.bizData.dealerSign, null);
        System.assertEquals(pdivo.bizData.customerSign, null);
        System.assertEquals(pdivo.bizData.dealerSignPng, null);
        System.assertEquals(pdivo.bizData.customerSignPng, null);
        System.assertEquals(pdivo.bizData.pdfContentVersionId, null);
        System.assertEquals(pdivo.bizData.assetMessage, null);
        System.assertEquals(pdivo.bizData.isSameDealer, null);
    }
}