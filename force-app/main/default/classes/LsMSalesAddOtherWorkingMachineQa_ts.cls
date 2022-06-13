/****************************************************************************************
  * @filename      : LsMSalesAddOtherWorkingMachineQa_ts
  * @author        : i2max_my.Seo
  * @date          : 2021-01-15 오전 10:19
  * @group         :
  * @group-content :
  * @description   : 
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author            description
  * ===============================================================
    0.1     2021-01-15 오전 10:19     i2max_my.Seo         Create
****************************************************************************************/
@IsTest
private class LsMSalesAddOtherWorkingMachineQa_ts {
    @IsTest
    static void testBehavior() {
        //==============================================================================
        // Data Setting
        //==============================================================================
        LsMSalesQuoteData lsMSalesQuoteData = new LsMSalesQuoteData();
        lsMSalesQuoteData.qliList = new List<QuoteLineItem__c>{TestDataSalesFactory.baseQuoteLineItem};
        lsMSalesQuoteData.qoiList = new List<QuoteOtherItem__c>{TestDataSalesFactory.baseQuoteOtherItem};
        lsMSalesQuoteData.qliWpList = new List<LsMSalesQuoteData.qliWrapper>();

        LsMSalesQuoteData.qliWrapper qliWrapper = new LsMSalesQuoteData.qliWrapper();

        //==============================================================================
        // Logic Test
        //==============================================================================
        System.assertNotEquals(null, LsMSalesAddOtherWorkingMachineQa.setQuoteOtherItem(lsMSalesQuoteData));
        System.assertNotEquals(null, LsMSalesAddOtherWorkingMachineQa.modifyQuoteOtherItem(
                lsMSalesQuoteData, TestDataSalesFactory.baseQuoteOtherItem, qliWrapper
        ));
    }
}