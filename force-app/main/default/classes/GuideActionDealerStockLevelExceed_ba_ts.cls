/****************************************************************************************
  * @filename      : GuideActionDealerStockLevelExceed_ba_ts
  * @projectname   : LS_PS
  * @author        : Park HE
  * @date          : 2020-07-22
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
    0.1     2020-07-22             Park HE         Create
****************************************************************************************/

@IsTest
private class GuideActionDealerStockLevelExceed_ba_ts {
    @IsTest
    static void testBehavior() {
        TestDataBaseFactory.init();
        TestDataSalesFactory.init();

        Asset testAsset = TestDataSalesFactory.baseAsset;
        testAsset.BusinessOffice__c = TestDataBaseFactory.businessOfficeAccount.Id;
        update testAsset;

        Product2 prd = TestDataProductFactory.baseProduct2;
        prd.Segment__c = '이앙기';
        update prd;

        DealerStockLevel__c dealerStockLevel = new DealerStockLevel__c(
                Qty__c = 0,
                ErpBusinessOfficeCode__c = '001',
                Segment__c = '이앙기',
                BaseYearMonth__c = System.today(),
                BusinessOffice__c = TestDataBaseFactory.businessOfficeAccount.Id
        );
        insert dealerStockLevel;

        Database.executeBatch(new GuideActionDealerStockLevelExceed_ba(), 1);
    }
}