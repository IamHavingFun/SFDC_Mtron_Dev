/****************************************************************************************
  * @filename      : LeaseInspectionReportPDFController_ts
  * @author        : I2MAX
  * @date          : 2021-04-27
  * @group         :
  * @group-content :
  * @description   : 
  * @reference     :
  * @release       : v1.0.0
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author         description
  * ===============================================================
    1.0     2021-04-27           I2MAX           Create
****************************************************************************************/
@IsTest
private class LeaseInspectionReportPDFController_ts {
    @IsTest
    static void testBehavior() {
        //==============================================================================
        // Data Setting
        //==============================================================================
        LeaseInspectionReport__c leaseInspectionReport = new LeaseInspectionReport__c();

        insert leaseInspectionReport;

        ApexPages.currentPage().getParameters().put('leaseInspectionId', leaseInspectionReport.Id);

        //==============================================================================
        // Logic Test
        //==============================================================================
        LeaseInspectionReportPDFController leaseInspectionReportPDFController = new LeaseInspectionReportPDFController();

        leaseInspectionReportPDFController.searchLeaseInspectionReport(leaseInspectionReport.Id);

        System.assertEquals(System.today(), leaseInspectionReportPDFController.todayDate);
    }
}