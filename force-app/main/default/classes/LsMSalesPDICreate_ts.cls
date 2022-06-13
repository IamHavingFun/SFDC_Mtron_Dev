/****************************************************************************************
 * @filename      : LsMSalesPDICreate_ts
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
private class LsMSalesPDICreate_ts {
    @IsTest
    static void testBehavior() {

        LsMSalesPDICreate.init(TestDataSalesFactory.baseAsset.Name);

    }

    @IsTest
    static void testBehavior2() {

        Asset asset = TestDataSalesFactory.baseAsset.clone(false, true);
        TestDataSalesFactory.baseAsset.InventoryType__c = '대리점재고';
        TestDataSalesFactory.baseAsset.Customer__c = TestDataBaseFactory.agencyAccount.Id;
        update TestDataSalesFactory.baseAsset;

        LsMSalesPDICreate.init('');
        LsMSalesPDICreate.init(TestDataSalesFactory.baseAsset.Name);

        LsMSalesPDIVO lsMSalesPDIVO = new LsMSalesPDIVO();

        LsMSalesPDIVO.BizData bizData = new LsMSalesPDIVO.BizData();
        TestDataSalesFactory.baseContract.Customer__c = TestDataBaseFactory.agencyAccount.Id;
        TestDataSalesFactory.baseContract.Opportunity__c = TestDataSalesFactory.baseOpportunity.Id;
        bizData.asset = TestDataSalesFactory.baseAsset;
        bizData.contract = TestDataSalesFactory.baseContract;

        bizData.pdi = new PDI__c();

        lsMSalesPDIVO.bizData = bizData;

        LsMSalesPDICreate.save(lsMSalesPDIVO, 'dealerSignPng,dealerSignPng', 'customerSignPng,customerSignPng');

        //LsMSalesPDICreate.getPdiPDF(lsMSalesPDIVO);

        try {
            LsMSalesPDICreate.savePDI(lsMSalesPDIVO, 'dealerSignPng,dealerSignPng', 'customerSignPng,customerSignPng');
        } catch (Exception e){}

    }

}