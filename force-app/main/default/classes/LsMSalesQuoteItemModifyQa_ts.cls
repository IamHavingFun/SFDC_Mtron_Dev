/****************************************************************************************
  * @filename      : LsMSalesQuoteItemModifyQa_ts
  * @projectname   :
  * @author        : i2max_my.Seo
  * @date          : 2020-07-15 오후 1:55
  * @group         :
  * @group-content :
  * @description   : 
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author            description
  * ===============================================================
    0.1     2020-07-15 오후 1:55     i2max_my.Seo         Create
****************************************************************************************/
@IsTest
private class LsMSalesQuoteItemModifyQa_ts {
    @IsTest
    static void testBehavior() {
        TestDataBaseFactory.init();

        LsMSalesQuoteData lsMSalesQuoteData = new LsMSalesQuoteData();
        lsMSalesQuoteData.qliList.add(TestDataSalesFactory.baseQuoteLineItem);
        lsMSalesQuoteData.qliWpList = new List<LsMSalesQuoteData.qliWrapper>();
        lsMSalesQuoteData.amtWrapper = new LsMSalesQuoteData.quoteAmtWrapper();

        lsMSalesQuoteData.amtWrapper.totalDiscount  = 0;
        lsMSalesQuoteData.amtWrapper.totalUnitPrice = 100000;
        lsMSalesQuoteData.amtWrapper.discount       = 0;

        LsMSalesQuoteData.qliWrapper qw = new LsMSalesQuoteData.qliWrapper();
        qw.prod         = TestDataProductFactory.baseProduct2;
        qw.unitPrice    = 200000;

        lsMSalesQuoteData.qliWpList.add(qw);

        LsMSalesQuoteItemModifyQa.reCalculateNetPrice(lsMSalesQuoteData, TestDataSalesFactory.baseQuoteLineItem, 0);
    }
}