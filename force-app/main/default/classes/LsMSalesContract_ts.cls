/****************************************************************************************
  * @filename      : LsMSalesContract_ts
  * @projectname   :
  * @author        : i2max_my.Seo
  * @date          : 2020-07-13 오후 1:00
  * @group         :
  * @group-content :
  * @description   : 
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author            description
  * ===============================================================
    0.1     2020-07-13 오후 1:00     i2max_my.Seo         Create
****************************************************************************************/
@IsTest
private class LsMSalesContract_ts {
    @IsTest
    static void testBehavior() {
        TestDataBaseFactory.init();

        LsMSalesContract.getDataForNewContract(TestDataSalesFactory.baseQuote.Id);

        TestDataSalesFactory.baseQuote.CustomerName__c = TestDataBaseFactory.personAccount.Id;
        update TestDataSalesFactory.baseQuote;

        LsMSalesContract.getDataForNewContract(TestDataSalesFactory.baseQuote.Id);
    }
}