/****************************************************************************************
  * @filename      : LsMSalesContractRegister_ts
  * @projectname   :
  * @author        : i2max_my.Seo
  * @date          : 2020-07-13 오후 1:21
  * @group         :
  * @group-content :
  * @description   : 
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author            description
  * ===============================================================
    0.1     2020-07-13 오후 1:21     i2max_my.Seo         Create
****************************************************************************************/
@IsTest
private class LsMSalesContractRegister_ts {
    @IsTest
    static void testBehavior() {
        TestDataBaseFactory.init();

        TestDataSalesFactory.baseContract.CustomerExpectedDate__c = TestDataUtilFactory.d;
        update TestDataSalesFactory.baseContract;

        LsMSalesContractRegister.init(TestDataSalesFactory.baseContract.Id);

        Contract__c newContract = TestDataSalesFactory.baseContract.clone(false, true);
        newContract.Quote__c = null;

        //==============================================================================
        // insert.
        //==============================================================================
        LsMSalesContractRegister.saveContract(
                newContract,
                TestDataSalesFactory.baseQuote,
                new List<QuoteLineItem__c>{TestDataSalesFactory.baseQuoteLineItem},
                new List<QuoteOtherItem__c>{TestDataSalesFactory.baseQuoteOtherItem},
                '2020-07-13',
                String.valueOf(TestDataUtilFactory.d.addDays(1))
        );

        //==============================================================================
        // update.
        //==============================================================================
        LsMSalesContractRegister.saveContract(
                newContract,
                TestDataSalesFactory.baseQuote,
                new List<QuoteLineItem__c>{TestDataSalesFactory.baseQuoteLineItem},
                new List<QuoteOtherItem__c>{TestDataSalesFactory.baseQuoteOtherItem},
                '2020-07-13',
                String.valueOf(TestDataUtilFactory.d.addDays(1))
        );
    }
}