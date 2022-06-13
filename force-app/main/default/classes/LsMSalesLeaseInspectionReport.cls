/****************************************************************************************
  * @filename      : LsMSalesLeaseInspectionReport
  * @author        : I2MAX
  * @date          : 2021-03-29
  * @group         : 
  * @group-content : 
  * @description   : 
  * @tester        : LsMSalesLeaseInspectionReport_ts.cls
  * @reference     : 
  * @release       : v1.0.0
  * @copyright     : Copyright © I2max. All Rights Reserved.rudd
  * @modification Log
  * ===============================================================
  * ver     date                     author        description
  * ===============================================================
    1.0     2021-03-29          I2MAX           Create
****************************************************************************************/
public with sharing class LsMSalesLeaseInspectionReport {

    /**
     * Init method
     *
     * @return I2ComClass.InitData
     */
    @AuraEnabled
    public static LsMSalesStepVO init(String assetName) {
        return getLeaseInspectionReportData(assetName);
    }

    @AuraEnabled
    public static LsMSalesStepVO getLeaseInspectionReportData(String assetName) {
        LsMSalesLeaseInspectionVO lsMSalesLeaseInspectionVO = new LsMSalesLeaseInspectionVO();
        lsMSalesLeaseInspectionVO.bizData = new LsMSalesLeaseInspectionVO.BizData();
        lsMSalesLeaseInspectionVO.setData = new LsMSalesLeaseInspectionVO.SetData();
        List<Asset> tempAssetList;
        Set<Id> contractIdSet;

        lsMSalesLeaseInspectionVO.bizData.leaseInspectionReport = new LeaseInspectionReport__c();

        tempAssetList = [
                SELECT Id, Name,
                       BusinessOffice__r.Name,
                       Dealer__r.Name,
                       Account.Name, Account.fm_Mobile__c,
                       Product2Id, Product2.Name
                FROM Asset
                WHERE Name = :assetName
                AND InventoryType__c = '대리점재고'

        ];

        if(tempAssetList.size() != 0) {
            contractIdSet = new Set<Id>();

            lsMSalesLeaseInspectionVO.bizData.leaseInspectionReport.Asset__c = tempAssetList[0].Id;
            lsMSalesLeaseInspectionVO.bizData.leaseInspectionReport.Asset__r = tempAssetList[0];
            lsMSalesLeaseInspectionVO.bizData.leaseInspectionReport.Product__c = tempAssetList[0].Product2Id;

            // 계약 제품의 정보로 계약 Id Set 구성
            for(ContractLineItem__c cli : [
                    SELECT Id, Contract__c
                    FROM ContractLineItem__c
                    WHERE ProductId__c = :tempAssetList[0].Product2Id
                    AND Contract__c IN (
                            SELECT Contract__c
                            FROM Lease__c
                            WHERE Contract__r.Status__c = '계약'
                    )
            ]) {
                contractIdSet.add(cli.Contract__c);
            }

            lsMSalesLeaseInspectionVO.setData.targetContracts = [
                    SELECT Id, Name,
                           Customer__c, Customer__r.Name, Customer__r.fm_Mobile__c,
                           Dealer__c,
                           BusinessOffice__c,
                           (
                                   SELECT ProductId__r.Name
                                   FROM ContractLineItem__r
                           )
                    FROM Contract__c
                    WHERE Id IN :contractIdSet
            ];

            if (lsMSalesLeaseInspectionVO.setData.targetContracts.size() == 0) {
                lsMSalesLeaseInspectionVO.setData.noContractMessage = '해당 계약건이 없습니다.';
            }
        }
        else {
            lsMSalesLeaseInspectionVO.setData.noContractMessage = '해당 기대는 유통재고가 아닙니다.';
        }

        return lsMSalesLeaseInspectionVO;
    }

    @AuraEnabled
    public static LsMSalesLeaseInspectionVO.BizData save(LsMSalesLeaseInspectionVO.BizData bizData, String inspectorSign) {
        // bizData로부터 data setting
        LeaseInspectionReport__c dmlLeaseInspectionReport = bizData.leaseInspectionReport;
        Contract__c tempContract = bizData.contract;

        dmlLeaseInspectionReport.Contract__c = tempContract.Id;
        dmlLeaseInspectionReport.Lease__c = [
                SELECT Id
                FROM Lease__c
                WHERE Contract__c = :tempContract.Id
        ]?.Id;
        dmlLeaseInspectionReport.BusinessOffice__c = tempContract.BusinessOffice__c;
        dmlLeaseInspectionReport.Dealer__c = tempContract.Dealer__c;
        dmlLeaseInspectionReport.Customer__c = tempContract.Customer__c;
        dmlLeaseInspectionReport.Asset__r = null;

        insert dmlLeaseInspectionReport;

        //================================================================================================================
        //  사인 저장
        //================================================================================================================
        ContentVersion dmlContentVersion = new ContentVersion(
                Title = 'inspectorSign.png',
                PathOnClient = 'inspectorSign.png',
                VersionData = EncodingUtil.base64Decode(inspectorSign.split(',')[1])
        );

        insert dmlContentVersion;

        // ContentDocumentId를 가져오기 위해 임시 CV에 담음
        ContentVersion tempContentVersion = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :dmlContentVersion.Id];

        insert new ContentDocumentLink(
                ContentDocumentId = tempContentVersion.ContentDocumentId,
                LinkedEntityId = dmlLeaseInspectionReport.Id,
                ShareType = 'V'
        );

        // 리스검수보고서 Id return
        return bizData;
    }

    @AuraEnabled
    public static void savePDF(String leaseInspectionReportId) {
        PageReference pdf;
        String pdfFormUrl = '/apex/LeaseInspectionReportPDF?leaseInspectionId=' + leaseInspectionReportId;
        pdf = new PageReference(pdfFormUrl);

        ContentVersion cv = new ContentVersion();

        cv.Title = 'LeaseInspectionReport.pdf';
        cv.VersionData = !Test.isRunningTest() ? pdf.getContent() : Blob.valueOf('testData');
        cv.PathOnClient = 'LeaseInspectionReport.pdf';

        insert cv;

        ContentDocumentLink cd = new ContentDocumentLink();

        for(ContentVersion cv_temp : [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id]) {
            cd.ContentDocumentId = cv_temp.ContentDocumentId;
            cd.LinkedEntityId = leaseInspectionReportId;
            cd.ShareType = 'V';
        }

        insert cd;
    }
}