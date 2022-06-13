/****************************************************************************************
  * @filename      : LsMSalesQCService_ts
  * @projectname   :
  * @author        : i2max_my.Seo
  * @date          : 2020-07-13 오전 8:30
  * @group         :
  * @group-content :
  * @description   : 
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author            description
  * ===============================================================
    0.1     2020-07-13 오전 8:30     i2max_my.Seo         Create
****************************************************************************************/
@IsTest
private class LsMSalesQCService_ts {
    @IsTest
    static void testBehavior() {
        TestDataBaseFactory.init();

        LsMSalesQCService.getQuoteById(TestDataSalesFactory.baseQuote.Id);
        LsMSalesQCService.getContractById(TestDataSalesFactory.baseContract.Id);
        LsMSalesQCService.getProduct2ById(TestDataProductFactory.baseProduct2.Id);
        LsMSalesQCService.getProductPrice(TestDataProductFactory.baseProduct2.Id);

        LsMSalesQCService.sumTotalPrice(new List<QuoteLineItem__c>{TestDataSalesFactory.baseQuoteLineItem});

        LsMSalesQCService.getOpptyName(
                TestDataSalesFactory.baseOpportunity.Account.LastName,
                TestDataProductFactory.baseProduct2.Name
        );
        LsMSalesQCService.getOpptyName(
                TestDataSalesFactory.baseOpportunity.Account.LastName,
                TestDataProductFactory.baseProduct2.Name,
                System.now().format('yyyyMMdd')
        );

        LsMSalesQCService.getCampaign(TestDataSalesFactory.baseOpportunity.Id);

        TestDataSalesFactory.baseQuoteLineItem.UnitPrice__c = 100000;
        update TestDataSalesFactory.baseQuoteLineItem;

        LsMSalesQCService.sumTotalUnitPrice(new List<QuoteLineItem__c>{TestDataSalesFactory.baseQuoteLineItem});
        LsMSalesQCService.calculateDiscountRate(100, 300);
        LsMSalesQCService.sumTotalProductDiscount(new List<QuoteLineItem__c>{TestDataSalesFactory.baseQuoteLineItem});
        LsMSalesQCService.checkValidDate(TestDataUtilFactory.dt.format('yyyy-MM-dd'));

        Product2 tempProduct = TestDataProductFactory.baseProduct2.clone(false, true);
        insert tempProduct;

        LsMSalesQCService.checkWorkingMachine(new List<QuoteLineItem__c>{TestDataSalesFactory.baseQuoteLineItem}, tempProduct);
        LsMSalesQCService.setContractDateNull(TestDataSalesFactory.baseContract);
    }
}