/****************************************************************************************
  * @filename      : LsMSalesQuoteRegister_ts
  * @projectname   :
  * @author        : i2max_my.Seo
  * @date          : 2020-07-15 오후 1:34
  * @group         :
  * @group-content :
  * @description   : 
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author            description
  * ===============================================================
    0.1     2020-07-15 오후 1:34     i2max_my.Seo         Create
****************************************************************************************/
@IsTest
private class LsMSalesQuoteRegister_ts {
    @IsTest
    static void testBehavior() {
        TestDataBaseFactory.init();

        LsMSalesQuoteRegister.init('v', null, TestDataSalesFactory.baseQuote.Id);
        LsMSalesQuoteRegister.init('m', null, TestDataSalesFactory.baseQuote.Id);
        LsMSalesQuoteRegister.init('i', TestDataSalesFactory.baseOpportunity.Id, null);
        LsMSalesQuoteRegister.init('i', null, null);

        Quote__c quote          = TestDataSalesFactory.baseQuote.clone(false, true);
        QuoteLineItem__c qli    = TestDataSalesFactory.baseQuoteLineItem.clone(false, true);

        LsMSalesQuoteRegister.save(
                TestDataSalesFactory.baseOpportunity,
                quote,
                new List<QuoteLineItem__c>{qli},
                new List<QuoteOtherItem__c>{TestDataSalesFactory.baseQuoteOtherItem},
                new List<String>()
        );

        LsMSalesQuoteData lsMSalesQuoteData = new LsMSalesQuoteData();
        lsMSalesQuoteData.qliList.add(TestDataSalesFactory.baseQuoteLineItem);

        LsMSalesQuoteRegister.getQliDataForDelete(lsMSalesQuoteData);

        Test.startTest();

        LsMSalesQuoteRegister.save(
                TestDataSalesFactory.baseOpportunity,
                quote,
                new List<QuoteLineItem__c>{qli},
                new List<QuoteOtherItem__c>{TestDataSalesFactory.baseQuoteOtherItem},
                new List<String>{TestDataSalesFactory.baseQuoteLineItem.Id}
        );

        Test.stopTest();
    }
}