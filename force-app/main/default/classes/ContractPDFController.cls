public with sharing class ContractPDFController {
    public String contractid { get; set; }          //parameter
    public String contentType { get; set; }          //parameter
    public Contract__c contract { get; set; }      //계약Record
    public Decimal totalAmt { get; set; }          //계약 총 금액
    public Integer totalCnt {get;set;}             // 제품 총 개수
    public static String SocialNumber {get;set;}
    public static Boolean isCorporationAccount {get;set;} // B2B 여부 (B2B 외 B2C로 본다)

    public static String dealerSignId {get;set;}   // 대리점 주 사인
    public static String customerSignId {get;set;}  // 고객 사인

    public ContractPDFController() {
        contractid = ApexPages.currentPage().getParameters().get('contractid'); //getParam
        contentType = ApexPages.currentPage().getParameters().get('type'); //getParam
        if(String.isEmpty(contentType) == true) {
            contentType = 'pdf';
        } else {
            contentType = '';
        }

        contract = new Contract__c();
        totalAmt = 0;

        searchContract(contractid);
    }

    public void searchContract(Id ContractId) {
        contract = [
                SELECT Id, Name,
                        fm_CustomerName__c,
                        fm_DealerRepName__c,
                (SELECT ProductId__r.ProductType__c, ProductId__r.Name, Quanitity__c, TotalPrice__c FROM ContractLineItem__r),
                (
                        SELECT Id, NetPrice__c, ProductName__c, ProductType__c, Quantity__c
                        FROM ContractOtherItem__r
                ),
                        CustomerExpectedDate__c,
                        ContractAmt__c,
                        ContractAmtCollectDueDate__c,
                        LoanContractAmt__c,
                        fm_LoanCollectDueDate__c,
                        LoanApplyDate__c,
                        LeaseContractAmt__c,
                        fm_LeaseCollectDueDate__c,
                        LeaseApplyDate__c,
                        SubsidyContractAmt__c,
                        SubsidyCollectDueDate__c,
                        SelfPayContractAmt__c,
                        SelfPayCollectDueDate__c,
                        UsedUndertakingAmt__c,
                        UsedUndertakingModel__c,
                        UsedUndertakingYear__c,
                        fm_TotalPayAmt__c,
                        isCUPI__c,
                        ContractStartDate__c,
                        fm_CustomerAddr__c,
                        fm_CustomerMobile__c,
                        fm_SalesRepAddr__c,
                        fm_DealerName__c,
                        fm_DealerMobile__c,
                        fm_DealerPhone__c,
                        eFormsignDocID__c,
                        fm_AdditionalDisc__c,
                        AdditionalTerms__c,
                        Remarks__c,
                        SocialNoIn__c,
                        BusinessRegNo__c,
                        Customer__r.RecordType.DeveloperName,
                (SELECT Id, ContentDocumentId, Title, FileExtension FROM AttachedContentDocuments)
                FROM Contract__c
                WHERE Id = :ContractId
        ];

        isCorporationAccount = (contract.Customer__r.RecordType.DeveloperName == 'CorporationAccount');

        //decode and Set Social number
        if(!String.isEmpty(contract.SocialNoIn__c)){
            String socialNum = EncodingUtil.base64Decode(contract.SocialNoIn__c).toString();

            socialNumber = socialNum.left(6) + '-' + socialNum.right(7);
        } else {
            String socialNum = contract.BusinessRegNo__c;

            socialNumber = socialNum;
        }

        //set Total Amount
        for (ContractLineItem__c cntitm : contract.ContractLineItem__r) {
            totalAmt += cntitm.TotalPrice__c == null ? 0 : cntitm.TotalPrice__c;
        }

        for (ContractOtherItem__c coi : contract.ContractOtherItem__r) {
            totalAmt += coi.NetPrice__c == null ? 0 : coi.NetPrice__c;
        }

        for (AttachedContentDocument file : contract.AttachedContentDocuments) {
            if(file.Title == 'DealerSign.png') dealerSignId = file.ContentDocumentId;
            if(file.Title == 'CustomerSign.png') customerSignId = file.ContentDocumentId;
        }

        // 제품 총 개수
        totalCnt = contract.ContractLineItem__r.size() + contract.ContractOtherItem__r.size();
    }


}