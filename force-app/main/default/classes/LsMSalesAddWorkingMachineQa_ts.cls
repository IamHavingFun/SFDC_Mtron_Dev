/****************************************************************************************
  * @filename      : LsMSalesAddWorkingMachineQa_ts
  * @projectname   :
  * @author        : i2max_my.Seo
  * @date          : 2020-07-15 오후 2:29
  * @group         :
  * @group-content :
  * @description   : 
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author            description
  * ===============================================================
    0.1     2020-07-15 오후 2:29     i2max_my.Seo         Create
****************************************************************************************/
@IsTest
private class LsMSalesAddWorkingMachineQa_ts {
    @IsTest
    static void testBehavior() {
        LsMSalesAddWorkingMachineQa.init(TestDataProductFactory.baseProduct2.Id);

        LsMSalesQuoteData lsMSalesQuoteData = new LsMSalesQuoteData();
        lsMSalesQuoteData.qliWpList = new List<LsMSalesQuoteData.qliWrapper>();
        LsMSalesAddWorkingMachineQa.getQliDataForQuote(lsMSalesQuoteData, TestDataProductFactory.baseProduct2.Id);

        LsMSalesAddWorkingMachineQa.prodWrapperData prodWrapperData = new LsMSalesAddWorkingMachineQa.prodWrapperData(TestDataProductFactory.baseProductFeature);
        System.assertNotEquals(prodWrapperData.prodOptionList, null);
    }
}