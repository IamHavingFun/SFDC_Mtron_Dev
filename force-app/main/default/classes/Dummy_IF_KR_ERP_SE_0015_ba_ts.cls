/****************************************************************************************
  * @filename      : Dummy_IF_KR_ERP_SE_0015_ba_ts
  * @projectname   :
  * @author        : i2max_my.Seo
  * @date          : 2020-04-23 오후 4:21
  * @group         :
  * @group-content :
  * @description   : 
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author            description
  * ===============================================================
    0.1     2020-04-23 오후 4:21     i2max_my.Seo         Create
****************************************************************************************/
@IsTest
private class Dummy_IF_KR_ERP_SE_0015_ba_ts {
    @IsTest
    static void testBehavior() {
        TestDataBaseFactory.init();

        // 정상 Data
        IF_KR_ERP_SE_0006__c dummyErpSe0006 = TestDataDummyBatchFactory.erpSe0006dummyDataBase.clone(false, true);
        dummyErpSe0006.InterfaceId__c = 'IF_KR_ERP_SE_0015';

        insert dummyErpSe0006;

        // 비정상 Data
        IF_KR_ERP_SE_0006__c dummyErpSe0006Sec = dummyErpSe0006.clone(false, true);
        dummyErpSe0006Sec.CustomerCode__c = null;

        insert dummyErpSe0006Sec;

        Database.executeBatch(new Dummy_IF_KR_ERP_SE_0015_ba(), 200);
    }

    @IsTest
    static void testBehavior2() {
        TestDataBaseFactory.init();

        TestDataSalesFactory.baseContract.LeaseContractAmt__c = 0;
        update TestDataSalesFactory.baseContract;

        IF_KR_ERP_SE_0006__c dummyErpSe0006 = TestDataDummyBatchFactory.erpSe0006dummyDataBase.clone(false, true);
        dummyErpSe0006.InterfaceId__c = 'IF_KR_ERP_SE_0015';

        insert dummyErpSe0006;

        Database.executeBatch(new Dummy_IF_KR_ERP_SE_0015_ba(), 200);
    }
}