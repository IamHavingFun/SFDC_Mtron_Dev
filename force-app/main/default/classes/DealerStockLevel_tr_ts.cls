/****************************************************************************************
  * @filename      : DealerStockLevel_tr_ts
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
private class DealerStockLevel_tr_ts {
    static testMethod void testBehavior() {
        TestDataBaseFactory.init();
        TestDataSalesFactory.init();

        DealerStockLevel__c dealerStockLevel = new DealerStockLevel__c(Qty__c = 0,ErpBusinessOfficeCode__c='001',Segment__c='이앙기',BaseYearMonth__c=System.today());
        insert dealerStockLevel;
    }
}