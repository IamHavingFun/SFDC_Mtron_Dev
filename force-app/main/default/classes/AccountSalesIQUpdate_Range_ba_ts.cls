/****************************************************************************************
  * @filename      : AccountSalesIQUpdate_Range_ba_ts
  * @author        : i2max_my.Seo
  * @date          : 2020-09-11 오전 9:51
  * @group         :
  * @group-content :
  * @description   : 
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author            description
  * ===============================================================
    0.1     2020-09-11 오전 9:51     i2max_my.Seo         Create
****************************************************************************************/
@IsTest
private class AccountSalesIQUpdate_Range_ba_ts {
    @IsTest
    static void testBehavior() {
        TestDataBaseFactory.init();
        TestDataDummyBatchFactory.init();

        PDI__c pdi = new PDI__c();
        pdi.Consumer__c = TestDataBaseFactory.agencyAccount.Id;
        pdi.HandoverDate__c = system.today().addMonths(-1);
        insert pdi;

        //배치실행
        Database.executeBatch(new AccountSalesIQUpdate_Range_ba(), 1);
    }
}