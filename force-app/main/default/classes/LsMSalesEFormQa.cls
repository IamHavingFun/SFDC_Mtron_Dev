/**
 * Created by MS on 2020-07-02.
 */
/****************************************************************************************
  * @filename      : LsMSalesEFormQa
  * @projectname   : LS_PS
  * @author        : Park HE
  * @date          : 2020-07-02
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
    0.1     2020-07-02             Park HE         Create
    0.2     2020-08-04             Park_JW         리스부분 업데이트
****************************************************************************************/
public with sharing class LsMSalesEFormQa {

    /**
     *
     *
     * @param recordId
     *
     * @return
     */
    @AuraEnabled
    public static Contract__c init(String recordId) {
        Contract__c contract = [
                SELECT  Id,
                        CustomerReviewCheck__c,
                        eFormsignStatus__c
                FROM Contract__c
                WHERE Id =: recordId
        ];
        return contract;
    }

    /**
     *
     *
     * @param recordId
     *
     * @return
     */
    @AuraEnabled
    public static Map<String, Object> getServiceExecute(String recordId) {

        Contract__c contract = [
                SELECT  Id,
                        CustomerReviewCheck__c,
                        fm_CustomerName__c,
                        fm_CustomerMobile__c,
                        Quote__r.CustomerName__r.PersonBirthdate,
                        isCUPI__c,
                        (
                                SELECT ProductId__r.ProductType__c, ProductId__r.Name, Quanitity__c, TotalPrice__c
                                FROM ContractLineItem__r
                        )
                FROM Contract__c
                WHERE Id =: recordId
        ];

        Map<String, Object> returnData = new Map<String, Object>();
        Map<String,String> cListMap = new Map<String, String>();

        Integer i = 0;
        for(ContractLineItem__c c : contract.ContractLineItem__r){
            ++i;
            cListMap.put('ProductType' + String.valueOf(i), c.ProductId__r.ProductType__c);
            cListMap.put('Model' + String.valueOf(i), String.valueOf(c.ProductId__r.Name));
            cListMap.put('Quantity' + String.valueOf(i), String.valueOf(c.Quanitity__c));
            cListMap.put('TotalPrice' + String.valueOf(i), c.TotalPrice__c == null ? '0' : c.TotalPrice__c.format());
        }
        cListMap.put('ContactLineItemCount', String.valueOf(i-1));
        cListMap.put('fm_CustomerName', contract.fm_CustomerName__c);
        cListMap.put('fm_CustomerMobile', contract.fm_CustomerMobile__c);
        cListMap.put('isCUPI', String.valueOf(contract.isCUPI__c));
        cListMap.put('birthdate', String.valueOf(contract.Quote__r.CustomerName__r.PersonBirthdate).replaceAll('-', '').right(6));

        returnData.put('Contract', cListMap);

        return returnData;
    }

    @AuraEnabled
    public static Contract__c setReview(String recordId) {
        Contract__c contract = [
                SELECT  Id,
                        CustomerReviewCheck__c
                FROM Contract__c
                WHERE Id =: recordId
        ];
        contract.CustomerReviewCheck__c = true;
        update contract;
        return contract;
    }

    @AuraEnabled
    public static void signSave(String recordId, String dealerSignPng, String customerSignPng) {

        List<ContentVersion> contentVersionList = new List<ContentVersion>{
                new ContentVersion(
                        Title = 'DealerSign.png',
                        VersionData = EncodingUtil.base64Decode(dealerSignPng.split(',')[1]),
                        PathOnClient = 'DealerSign.png'
                ),
                new ContentVersion(
                        Title = 'CustomerSign.png',
                        VersionData = EncodingUtil.base64Decode(customerSignPng.split(',')[1]),
                        PathOnClient = 'CustomerSign.png'
                )
        };

        insert contentVersionList;

        Map<Id,ContentVersion> tempContentVersionsByIds = new Map<Id,ContentVersion>(contentVersionList);
        List<ContentDocumentLink> contentDocumentLinkList = new List<ContentDocumentLink>();
        ContentDocumentLink cdl;

        for(ContentVersion cv : [SELECT ContentDocumentId, CreatedDate FROM ContentVersion WHERE Id = :tempContentVersionsByIds.keySet()]){
            cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = cv.ContentDocumentId;
            cdl.LinkedEntityId = recordId;
            cdl.ShareType = 'V';
            contentDocumentLinkList.add(cdl);
        }

        insert contentDocumentLinkList;
    }

    @AuraEnabled
    public static void pdfSave(String recordId) {
        PageReference pdf;
        String pdfformUrl = '/apex/ContractPDF?contractid=' + recordId;
        pdf = new PageReference(pdfformUrl);

        ContentVersion cv = new ContentVersion();

        cv.Title = 'Contract.pdf';
        cv.VersionData = !Test.isRunningTest() ? pdf.getContent() : Blob.valueOf('testData');
        cv.PathOnClient = 'Contract.pdf';

        insert cv;

        ContentDocumentLink cd = new ContentDocumentLink();

        for(ContentVersion cv_temp:[SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id]){
            cd.ContentDocumentId = cv_temp.ContentDocumentId;
            cd.LinkedEntityId = recordId;
            cd.ShareType = 'V';
        }

        insert cd;
    }

    /**
     * 계약서 저장 성공 시 documentId 저장
     *
     * @param recordId
     * @param eFormsignDocID : documnetId
     * @param eFormsignFormID : FormId
     */
    @AuraEnabled
    public static String successSave(Contract__c referContract) {
        String returnValue;

        Contract__c contract= [
                SELECT  Id, LeaseContractAmt__c, eFormsignDocID__c, eFormsignFormID__c, eFormsignStatus__c, eFormsignDate__c, fm_CustomerName__c, fm_DealerRepName__c, OwnerId,
                        isLWSRegistration__c,ContractAmt__c,ContractAmtCollectAmt__c,ContractNotes__c,ContractAmtCollectDueDate__c,Name,ContractStartDate__c,CustomerExpectedDate__c,DeliveryDate__c,
                        Customer__c,Dealer__c,LeasePaymentAmt__c,LeaseDueDate__c,LeaseNotes__c,SubsidyContractAmt__c,SubsidyNotes__c,SubsidyCollectAmt__c,SubsidyCollectDueDate__c,BusinessOffice__c,
                        LoanContractAmt__c,LoanPaymentAmt__c,LoanDueDate__c,LoanNotes__c,SelfPayContractAmt__c,SelfPayPaymentAmt__c,SelfPayDueDate__c,SelfPayNotes__c,SelfPayCollectAmt__c,SelfPayCollectDueDate__c,
                        SelfPayDebtAmt__c,isUsedUndertaking__c,UsedUndertakingAmt__c,UsedUndertakingModel__c,UsedUndertakingYear__c,
                        SocialNoIn__c, VwSocialNo__c, Remarks__c, AdditionalTerms__c
                FROM Contract__c
                WHERE Id = :referContract.Id
        ];

        contract.eFormsignDate__c = System.today();
        contract.eFormsignStatus__c = '계약체결';//(referContract.eFormsignStatus__c.equals('계약체결')) ? '계약체결' : '미요청';
        contract.SocialNoIn__c = referContract.SocialNoIn__c;
        contract.VwSocialNo__c = referContract.VwSocialNo__c;
        contract.Remarks__c = referContract.Remarks__c;
        contract.AdditionalTerms__c = referContract.AdditionalTerms__c;
        contract.isCUPI__c = true;

        update contract;

        if(referContract.eFormsignStatus__c.equals('계약체결')) {
            if (contract.LeaseContractAmt__c > 0) {
                // 계약제품 조회
                List<ContractLineItem__c> cliList = [
                        SELECT Id, Name, UnitPrice__c, ListPrice__c, NetPrice__c, AdditionalDisc__c, TotalPrice__c, ProductId__r.Name
                        FROM ContractLineItem__c
                        WHERE Contract__c = :contract.Id
                        AND ProductId__r.Type__c = '본체'
                ];

                // 리스 데이터 생성
                Lease__c lease = new Lease__c(isLWSRegistration__c = contract.isLWSRegistration__c,
                        SystemStatus__c = '리스서류접수',
                        Contract__c = contract.Id,
                        ContractAmt__c = contract.ContractAmt__c,
                        ContractAmtCollectAmt__c = contract.ContractAmtCollectAmt__c,
                        ContractNotes__c = contract.ContractNotes__c,
                        ContractAmtCollectDueDate__c = contract.ContractAmtCollectDueDate__c,
                        ContractNumber__c = contract.Name,
                        ContractStartDate__c = contract.ContractStartDate__c,
                        CustomerExpectedDate__c = contract.CustomerExpectedDate__c,
                        DeliveryDate__c = contract.DeliveryDate__c,
                        Customer__c = contract.Customer__c,
                        Dealer__c = contract.Dealer__c,
                        LeaseContractAmt__c = contract.LeaseContractAmt__c,
                        LeasePaymentAmt__c = contract.LeasePaymentAmt__c,
                        LeaseDueDate__c = contract.LeaseDueDate__c,
                        LeaseNotes__c = contract.LeaseNotes__c,
                        SubsidyContractAmt__c = contract.SubsidyContractAmt__c,
                        SubsidyNotes__c = contract.SubsidyNotes__c,
                        SubsidyCollectAmt__c = contract.SubsidyCollectAmt__c,
                        SubsidyCollectDueDate__c = contract.SubsidyCollectDueDate__c,
                        Status__c = '리스서류접수',
                        OwnerId = contract.OwnerId,
                        BusinessOffice__c = contract.BusinessOffice__c,
                        LoanContractAmt__c = contract.LoanContractAmt__c,
                        LoanPaymentAmt__c = contract.LoanPaymentAmt__c,
                        LoanDueDate__c = contract.LoanDueDate__c,
                        LoanNotes__c = contract.LoanNotes__c,
                        SelfPayContractAmt__c = contract.SelfPayContractAmt__c,
                        SelfPayPaymentAmt__c = contract.SelfPayPaymentAmt__c,
                        SelfPayDueDate__c = contract.SelfPayDueDate__c,
                        SelfPayNotes__c = contract.SelfPayNotes__c,
                        SelfPayCollectAmt__c = contract.SelfPayCollectAmt__c,
                        SelfPayCollectDueDate__c = contract.SelfPayCollectDueDate__c,
                        SelfPayDebtAmt__c = contract.SelfPayDebtAmt__c,
                        isUsedUndertaking__c = contract.isUsedUndertaking__c,
                        UsedUndertakingAmt__c = contract.UsedUndertakingAmt__c,
                        UsedUndertakingModel__c = contract.UsedUndertakingModel__c,
                        UsedUndertakingYear__c = contract.UsedUndertakingYear__c
                );
                insert lease;

                // 리스제품 데이터 생성
                if (cliList.isEmpty() == false && cliList.size() > 0) {
                    LeaseLineItem__c lli = null;
                    for (ContractLineItem__c cli : cliList) {
                        lli = new LeaseLineItem__c(
                                Lease__c = lease.Id,
                                ContractLineItemId__c = cli.Id,
                                UnitPrice__c = cli.UnitPrice__c,
                                Name = cli.ProductId__r.Name,
                                ListPrice__c = cli.ListPrice__c,
                                NetPrice__c = cli.NetPrice__c,
                                AdditionalDisc__c = cli.AdditionalDisc__c,
                                TotalPrice__c = cli.TotalPrice__c
                        );
                        break;      // 본체 한건만 처리.
                    }
                    if (lli != null) insert lli;
                }

                // 리스 사용자 검색
                List<User> leaseUser = [
                        SELECT Id
                        FROM User
                        WHERE Profile.Name = 'Korea Partner Community Lease User'
                        AND IsActive = TRUE
                        LIMIT 1
                ];
                if (leaseUser.isEmpty() == false && leaseUser.size() > 0) {
                    Lease__Share ls = new Lease__Share();
                    ls.ParentId = lease.Id;
                    ls.AccessLevel = 'Edit';
                    ls.RowCause = 'Manual';
                    ls.UserOrGroupId = leaseUser[0].Id;
                    insert ls;
                }
            }
/*
        전자계약 완료 시점에 리스/리스제품 레코드 생성(계약.LeaseContractAmt__c > 0)
                리스 레코드 대리점사장님 레코드 sharing 처리
*/

            // 알림만 가는 경우 :: type = guide; status = completed; activityDate = today; customAlert = true;
            Task newTask = new Task();
            newTask.OwnerId = contract.OwnerId;
            newTask.WhatId = contract.Id;
            newTask.Type__c = 'Guide';
            newTask.ActivityDate = System.today();
            newTask.Status = 'Completed';
            newTask.Subject = '[계약 완료]';
            newTask.Description = contract.fm_CustomerName__c + '과/와 계약이 완료되었습니다. ' + contract.fm_DealerRepName__c + '의 노고에 감사드립니다.';
            newTask.CustomAlert__c = true;
            insert newTask;

            returnValue = 's';
        } else {
            delete [
                    SELECT
                            Id
                    FROM ContentDocumentLink
                    WHERE LinkedEntityId = :referContract.Id
            ];

            returnValue = 'e';
        }

        return returnValue;
    }

    @AuraEnabled
    public static String getContentDocumentLinkId(String recordId) {
        String returnId;

        Contract__c contract = [
                SELECT Id,
                (
                        SELECT Id, ContentDocumentId, Title, FileExtension
                        FROM AttachedContentDocuments
                )
                FROM Contract__c
                WHERE Id = :recordId
        ];

        for(AttachedContentDocument attachedContentDocument : contract.AttachedContentDocuments) {
            if(attachedContentDocument.Title.equals('Contract.pdf')) {
                returnId = attachedContentDocument.ContentDocumentId;
            }
        }

        return returnId;
    }
}