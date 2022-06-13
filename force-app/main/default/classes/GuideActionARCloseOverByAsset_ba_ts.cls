/****************************************************************************************
  * @filename      : GuideActionARCloseOverByAsset_ba_ts
  * @projectname   : LS_PS
  * @author        : Park HE
  * @date          : 2020-07-09
  * @group         :
  * @group-content :
  * @description   :
  * @tester        :
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                    author          description
  * ===============================================================
    0.1     2020-07-09             Park HE         Create
****************************************************************************************/

@IsTest
private class GuideActionARCloseOverByAsset_ba_ts {
    @IsTest
    static void testBehavior() {
        TestDataBaseFactory.init();
        TestDataDummyBatchFactory.init();
        TestDataBizFactory.init();
        TestDataSalesFactory.init();

        Account testAgencyAccount = TestDataBaseFactory.agencyAccount;
        System.debug(testAgencyAccount.CustomerType__c);
        Asset testAsset = TestDataSalesFactory.baseAsset;
        AR__c testAr = TestDataBizFactory.baseAR.clone();

        testAr.AccountId__c = testAgencyAccount.Id;
        testAr.Asset__c = testAsset.Id;
        testAr.PlanDate__c = TestDataUtilFactory.d.addDays(-150);
        testAr.BaseYearMonth__c = TestDataUtilFactory.d;
        testAr.RepaymentKRW__c = 1000;

        insert testAr;

        Database.executeBatch(new GuideActionARCloseOverByAsset_ba(), 200);
    }
}