/****************************************************************************************
  * @filename      : GuideActionAR6MonthOverByAsset_ba_ts
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
private class GuideActionAR6MonthOverByAsset_ba_ts {
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
        testAr.PlanDate__c = TestDataUtilFactory.d.addDays(-190);
        testAr.BaseYearMonth__c = TestDataUtilFactory.d;
        testAr.RepaymentKRW__c = 1000;

        insert testAr;

        AR__c queryResult = [SELECT Id,AccountId__c, AccountId__r.OwnerId, fm_isAsset__c, PlanDate__c, BaseYearMonth__c, AccountId__r.Name,AccountId__r.BusinessOffice__r.Name, Asset__r.Name, RepaymentKRW__c, AccountId__r.CustomerType__c
                            FROM AR__C
                            WHERE Id = :testAr.Id];

        System.debug(queryResult);
        System.debug(queryResult.BaseYearMonth__c);
        System.debug(queryResult.PlanDate__c);
        System.debug(queryResult.fm_isAsset__c);
        System.debug(queryResult.RepaymentKRW__c);
        System.debug(queryResult.AccountId__r.CustomerType__c);

        Database.executeBatch(new GuideActionAR6MonthOverByAsset_ba(), 200);
    }
}