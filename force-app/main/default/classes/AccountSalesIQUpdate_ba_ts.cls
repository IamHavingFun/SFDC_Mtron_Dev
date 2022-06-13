/****************************************************************************************
  * @filename      : AccountSalesIQUpdate_ba_ts
  * @projectname   : LS
  * @author        : Park HE
  * @date          : 2020-05-15
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
    0.1     2020-05-15             Park HE         Create
****************************************************************************************/
@IsTest
private class AccountSalesIQUpdate_ba_ts {
    @IsTest
    static void testBehavior() {
        TestDataBaseFactory.init();
        TestDataDummyBatchFactory.init();

        PDI__c pdi = new PDI__c();
        pdi.Consumer__c = TestDataBaseFactory.agencyAccount.Id;
        pdi.HandoverDate__c = system.today().addMonths(-1);
        insert pdi;

        //배치실행
        Database.executeBatch(new AccountSalesIQUpdate_ba(), 1);
        /*Database.executeBatch(new AccountSalesIQUpdate_this_ba(), 1);*/
    }
}