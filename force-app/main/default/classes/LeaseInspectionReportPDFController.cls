/****************************************************************************************
  * @filename      : LeaseInspectionReportPDFController
  * @author        : I2MAX
  * @date          : 2021-03-26
  * @group         : 
  * @group-content : 
  * @description   : 
  * @tester        : LeaseInspectionReportPDFController_ts.cls
  * @reference     : 
  * @release       : v1.0.0
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author        description
  * ===============================================================
    1.0     2021-03-26          I2MAX           Create
****************************************************************************************/
public with sharing class LeaseInspectionReportPDFController {

    //parameter
    public String leaseInspectionId {get;set;}
    public LeaseInspectionReport__c leaseInspectionReport {get;set;}
    public Date todayDate {
        get {
            return System.today();
        }
    }


    public LeaseInspectionReportPDFController() {
        this.leaseInspectionId = ApexPages.currentPage().getParameters().get('leaseInspectionId');

        searchLeaseInspectionReport(this.leaseInspectionId);
    }

    public void searchLeaseInspectionReport(String leaseInspectionId) {
        this.leaseInspectionReport = [
                SELECT
                        Asset__c, Asset__r.CreatedDate,
                        Asset__r.Name,
                        Asset__r.BatchNo__c,
                        Contract__c, Contract__r.Name,
                        Customer__c, Customer__r.Name,
                        BusinessOffice__r.Name,
                        BusinessOfficeSalesRep__r.Name,
                        Product__c, Product__r.Name,
                        CustomerAddress__c,
                        CustomerMobile__c,
                        CustomerName__c,
                        Dealer__c,
                        Id,
                        InspectionType__c,
                        IsCorrect__c,
                        IsDeleted,
                        IsHandOver__c,
                        IsLeaseChecked__c,
                        IsStored__c,
                        InternalStatus__c,
                        ExternalStatus__c,
                        WholeStatus__c,
                        (
                                SELECT Id, ContentDocumentId
                                FROM AttachedContentDocuments
                                WHERE Title = 'inspectorSign.png'
                        )
                FROM LeaseInspectionReport__c
                WHERE Id = :leaseInspectionId
        ];
    }
}