/****************************************************************************************
  * @filename      : LsMSalesDashboard_ts
  * @projectname   : LS_PS
  * @author        : Park HE
  * @date          : 2020-07-13
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
    0.1     2020-07-13             Park HE         Create
****************************************************************************************/

@IsTest
private class LsMSalesDashboard_ts {
    @IsTest
    static void testBehavior() {
        TestDataBaseFactory.init();
        TestDataSalesFactory.init();

        LsMSalesDashboard.ArResData arResData = new LsMSalesDashboard.ArResData();
        LsMSalesDashboard.SalesPerformanceResData salesPerformanceResData = new LsMSalesDashboard.SalesPerformanceResData();
        LsMSalesDashboard.MarketResData resData = new LsMSalesDashboard.MarketResData('test',123);
        System.assertNotEquals(arResData, null);
        System.assertNotEquals(salesPerformanceResData, null);
        System.assertNotEquals(resData, null);
        System.debug(salesPerformanceResData.goalPercent);

        User u = TestDataBaseFactory.agencyUser;
        
        SalesPerformance__c performance = TestDataBizFactory.baseSalesPerformance;
        performance.AccountId__c = TestDataBaseFactory.agencyAccount.Id;
        performance.Division__c = '계획';
        performance.SalesAmount__c = 10000;
        performance.BaseYearMonth__c = TestDataUtilFactory.d;
//        performance.OwnerId = u.Id;
        update performance;

        SalesPerformance__c performance2 = performance.clone(false,true);
        performance2.Division__c = '실적';
        insert performance2;

        MarketInfo__c marketInfo = new MarketInfo__c();
        marketInfo.Company__c = 'LS';
        marketInfo.Quantity__c = 100;
        marketInfo.BaseYearMonth__c = TestDataUtilFactory.d;
        marketInfo.AccountId__c = TestDataBaseFactory.agencyAccount.Id;
        insert marketInfo;

        ActualSales__c actualSales = new ActualSales__c();
        actualSales.Qty__c = 100;
        actualSales.BaseYearMonth__c = TestDataUtilFactory.d;
        actualSales.Division__c = '실적';
        actualSales.AccountId__c = TestDataBaseFactory.agencyAccount.Id;
        insert actualSales;

        ActualSales__c actualSales2 = actualSales.clone(false, true);
        actualSales2.Division__c = '계획';
        insert actualSales2;

        System.runAs(u) {
            List<String> sObjects = new List<String>{'Sales','DealerStock','MarketInfoThis','MarketInfoLast','Delivery','AR','Purchase'};
            for(String ob : sObjects) {
                LsMSalesDashboard.doGet(ob);
            }
        }
    }
 }