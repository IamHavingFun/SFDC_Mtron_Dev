/****************************************************************************************
  * @filename      : Dummy_IF_KR_SE_LWS_0035_ba_ts
  * @projectname   : 
  * @author        : i2max 
  * @date          : 2020-07-13 오후 6:12
  * @group         : 
  * @group-content : 
  * @description   : 
  * @tester        : Dummy_IF_KR_SE_LWS_0035_ba_ts_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author              description
  * ===============================================================
    0.1     2020-07-13 오후 6:12       i2max                  Create
*************a***************************************************************************/
@IsTest
private class Dummy_IF_KR_SE_LWS_0035_ba_ts {
    @IsTest
    static void testBehavior() {
        TestDataBaseFactory.init();
        TestDataDummyBatchFactory.init();
        
        Account testBusinessOfficeAccount = TestDataBaseFactory.businessOfficeAccount.clone(false, true);
        testBusinessOfficeAccount.CustomerType__c = '자영농';
        insert testBusinessOfficeAccount;
//        Account testPersonAccount = TestDataBaseFactory.personAccount.clone(false, true);
//        testPersonAccount.CustomerType__c = '개인고객';
//        insert testPersonAccount;

        TestDataBaseFactory.personAccount.CustomerStatus__c = '실고객';
        TestDataBaseFactory.personAccount.CustomerType__c = '자영농';
        TestDataBaseFactory.personAccount.LWSNo__c = '1';
        update TestDataBaseFactory.personAccount;

        Asset asset = TestDataSalesFactory.baseAsset;
        asset.AccountId = TestDataBaseFactory.personAccount.Id;
/*        asset.Name = '2390000004';
        asset.BatchNo__c = '2390000004';*/
        update asset;

        String query = '';
        query += ' SELECT\n' +
                ' Id\n' +
                ' FROM Account\n' +
                ' WHERE CustomerType__c IN (\'자영농\', \'농업법인\')\n' +
                ' AND CustomerStatus__c = \'실고객\'\n';
        Dummy_IF_KR_SE_LWS_0035_ba test = new Dummy_IF_KR_SE_LWS_0035_ba(query);
        Database.executeBatch(new Dummy_IF_KR_SE_LWS_0035_ba(), 200);
    }
}