/****************************************************************************************
 * @filename      : AccountSalesIQUpdate_this_ba_ts
 * @projectname   : 
 * @author        : SEOKHO LEE
 * @date          : 2020-08-18 오전 9:01
 * @group         :
 * @group-content :
 * @description   :
 * @tester        :
 * @reference     :
 * @copyright     : Copyright © I2max. All Rights Reserved.
 * @modification Log
 * ===============================================================
 * ver     date                     author              description
 * ===============================================================
 0.1     2020-08-18 오전 9:01        SEOKHO LEE          Create
 ****************************************************************************************/

@IsTest
private class AccountSalesIQUpdate_this_ba_ts {
    @IsTest
    static void testBehavior() {
        TestDataBaseFactory.init();
        TestDataDummyBatchFactory.init();

        PDI__c pdi = new PDI__c();
        pdi.Consumer__c = TestDataBaseFactory.agencyAccount.Id;
        pdi.HandoverDate__c = system.today().addMonths(-1);
        insert pdi;

        //배치실행
        Database.executeBatch(new AccountSalesIQUpdate_this_ba(), 1);
    }
}