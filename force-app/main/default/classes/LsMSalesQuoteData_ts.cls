/****************************************************************************************
  * @filename      : LsMSalesQuoteData_ts
  * @projectname   :
  * @author        : i2max_my.Seo
  * @date          : 2020-07-15 오후 2:03
  * @group         :
  * @group-content :
  * @description   : 
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author            description
  * ===============================================================
    0.1     2020-07-15 오후 2:03     i2max_my.Seo         Create
****************************************************************************************/
@IsTest
private class LsMSalesQuoteData_ts {
    @IsTest
    static void testBehavior() {
        LsMSalesQuoteData lsMSalesQuoteData = new LsMSalesQuoteData();
        System.assertEquals(null, lsMSalesQuoteData.quote);
        System.assertEquals(null, lsMSalesQuoteData.oppty);
        System.assertNotEquals(null, lsMSalesQuoteData.qliList);
        System.assertNotEquals(null, lsMSalesQuoteData.qoiList);
        System.assertNotEquals(null, lsMSalesQuoteData.product);
        System.assertNotEquals(null, lsMSalesQuoteData.amtWrapper);

        lsMSalesQuoteData.qliWpList = new List<LsMSalesQuoteData.qliWrapper>();
        LsMSalesQuoteData.qliWrapper qw = new LsMSalesQuoteData.qliWrapper();
        qw.prod = TestDataProductFactory.baseProduct2;

        System.assertNotEquals(null, qw.qliProductType);
        System.assertNotEquals(null, qw.qliName);
        System.assertEquals(null, qw.option1);
        System.assertEquals(null, qw.option2);
        System.assertEquals(null, qw.option3);
        System.assertEquals(null, qw.option4);
        System.assertNotEquals(null, qw.listPrice);
        System.assertEquals(null, qw.unitPrice);
        System.assertEquals(null, qw.netPrice);
        System.assertEquals(null, qw.loanSupport);
        System.assertEquals(false, qw.isOtherWorkingMachine);
    }
}