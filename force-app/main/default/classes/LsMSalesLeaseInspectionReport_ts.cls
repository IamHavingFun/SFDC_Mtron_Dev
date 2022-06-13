/****************************************************************************************
  * @filename      : LsMSalesLeaseInspectionReport_ts
  * @author        : I2MAX
  * @date          : 2021-04-12
  * @group         : 
  * @group-content : 
  * @description   : 
  * @tester        : LsMSalesLeaseInspectionReport_ts_ts.cls
  * @reference     : 
  * @release       : v1.0.0
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author        description
  * ===============================================================
    1.0     2021-04-12          I2MAX           Create
****************************************************************************************/


@IsTest
private class LsMSalesLeaseInspectionReport_ts {
    @IsTest
    static void testBehavior() {
        //================================================================================================================
        // Data Setting
        //================================================================================================================
        TestDataSalesFactory.baseContract.Status__c = '계약';
        update TestDataSalesFactory.baseContract;

        Lease__c newLease = new Lease__c();
        newLease.Contract__c = TestDataSalesFactory.baseContract.Id;

        insert newLease;

        ContractLineItem__c tempCli = TestDataSalesFactory.baseCli.clone(false, true);
        tempCli.ProductId__c = TestDataProductFactory.baseProduct2.Id;

        insert tempCli;


        //================================================================================================================
        // Logic Test
        //================================================================================================================
        Test.startTest();

        System.assertNotEquals(null, LsMSalesLeaseInspectionReport.init(''));
        System.assertNotEquals(null, LsMSalesLeaseInspectionReport.init(TestDataSalesFactory.baseAsset.Name));

        Test.stopTest();
    }

    @IsTest
    static void testBehavior2() {
        LsMSalesLeaseInspectionVO.BizData bizData = new LsMSalesLeaseInspectionVO.BizData();
        bizData.leaseInspectionReport = new LeaseInspectionReport__c();
        bizData.contract = TestDataSalesFactory.baseContract;

        bizData = LsMSalesLeaseInspectionReport.save(bizData, 'test,test');
        Id leaseInspectionId = bizData.leaseInspectionReport.Id;

        Test.startTest();

        System.assertNotEquals(null, leaseInspectionId);
        LsMSalesLeaseInspectionReport.savePDF(leaseInspectionId);

        Test.stopTest();
    }
}