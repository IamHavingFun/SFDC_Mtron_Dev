/****************************************************************************************
  * @filename      : LsMSalesQuoteItemAddQa_ts
  * @projectname   :
  * @author        : i2max_my.Seo
  * @date          : 2020-07-13 오전 8:45
  * @group         :
  * @group-content :
  * @description   : 
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author            description
  * ===============================================================
    0.1     2020-07-13 오전 8:45     i2max_my.Seo         Create
****************************************************************************************/
@IsTest
private class LsMSalesQuoteItemAddQa_ts {
    @IsTest
    static void testBehavior() {
        TestDataBaseFactory.init();
        TestDataSalesFactory.init();

        LsMSalesQuoteData lsMSalesQuoteData = new LsMSalesQuoteData();
        lsMSalesQuoteData.quote             = TestDataSalesFactory.baseQuote;

        //==============================================================================
        // qliList, qliWpList 빈 값.
        //==============================================================================
        LsMSalesQuoteItemAddQa.getMainQliDataForQuote(lsMSalesQuoteData, TestDataProductFactory.baseProduct2.Id);

        //==============================================================================
        // qliList 세팅 및 qliWpList 세팅.
        //==============================================================================
        lsMSalesQuoteData.qliList[0] = new QuoteLineItem__c(
                Product__c = TestDataProductFactory.baseProduct2.Id,
                UnitPrice__c = 2000000,
                NetPrice__c = 1000000
        );

        lsMSalesQuoteData.qliWpList[0].prod = TestDataProductFactory.baseProduct2;

        LsMSalesQuoteItemAddQa.getMainQliDataForQuote(lsMSalesQuoteData, TestDataProductFactory.baseProduct2.Id);
        LsMSalesQuoteItemAddQa.reCalculateNetPrice(lsMSalesQuoteData, 200000);
    }
}