/****************************************************************************************
  * @filename      : LsMSalesContractRegister
  * @projectname   : 
  * @author        : i2max_my.Seo 
  * @date          : 2020-07-04 오후 7:13
  * @group         : 
  * @group-content : 
  * @description   : 
  * @tester        : LsMSalesContractRegister_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author              description
  * ===============================================================
    0.1     2020-07-04 오후 7:13     i2max_my.Seo           Create
****************************************************************************************/
public without sharing class LsMSalesContractRegister {

    /**
     * 바로 Contract 수정 화면 으로 넘어 왔을 시, init.
     *
     * @param contractId : Contract__c Id.
     *
     * @return LsMSalesStepVO
     */
    @AuraEnabled
    public static LsMSalesStepVO init(String contractId) {
        LsMSalesContractVO lsMSalesContractVO = new LsMSalesContractVO();

        lsMSalesContractVO.bizData = new LsMSalesContractVO.BizData();
        lsMSalesContractVO.dateData = new LsMSalesContractVO.DateData();

        lsMSalesContractVO.bizData.contract = LsMSalesQCService.getContractById(contractId);

        lsMSalesContractVO.bizData.quote = LsMSalesQCService.getQuoteById(lsMSalesContractVO.bizData.contract.Quote__c);
        lsMSalesContractVO.bizData.isCorporationAccount = (lsMSalesContractVO.bizData.quote.CustomerName__r.RecordType.DeveloperName == 'CorporationAccount');

        // 인도 기일 분할 세팅.
        Date tempDt = lsMSalesContractVO.bizData.contract.CustomerExpectedDate__c;
        lsMSalesContractVO.dateData.tempCustomerYear    = String.valueOf(tempDt.year());
        lsMSalesContractVO.dateData.tempCustomerMonth   = String.valueOf(tempDt.month());
        lsMSalesContractVO.dateData.tempCustomerDay     = String.valueOf(tempDt.day());

        lsMSalesContractVO.unchangedData = new LsMSalesContractVO.UnchangedData(lsMSalesContractVO.bizData.contract, lsMSalesContractVO.dateData);

        return (LsMSalesStepVO)lsMSalesContractVO;
    }


    /**
     * 신규 생성 및 수정.
     *
     * @param contract          : Contract__c
     * @param quote             : Quote__c
     * @param qliList           : List<QuoteLineItem__c>
     * @param qoiList           : List<QuoteOtherItem__c>
     * @param tempDate          : String 날짜 값. (ex : 2020-07-01)
     * @param tempCustomerDate  : String 날짜 값. (ex : 2020-07-01)
     *
     * @return String Contract__c.Id
     */
    @AuraEnabled
    public static String saveContract(Contract__c contract, Quote__c quote, List<QuoteLineItem__c> qliList, List<QuoteOtherItem__c> qoiList, String tempDate, String tempCustomerDate) {
        List<ContractLineItem__c> contractLineItems = new List<ContractLineItem__c>();
        List<ContractOtherItem__c> contractOtherItems = new List<ContractOtherItem__c>();
        Boolean isPersonAccount = quote.CustomerName__r.RecordType.DeveloperName == 'PersonAccount';
        Account updateAccount;

//        if(tempCustomerDate != null) {
//            LsMSalesQCService.checkValidDate(tempCustomerDate);
//
//            contract.CustomerExpectedDate__c = Date.valueOf(tempCustomerDate);
//        }

        contract.CustomerExpectedDate__c = Date.valueOf(tempCustomerDate);

        // 인도 기일 Valid Check.
        if(contract.CustomerExpectedDate__c < System.today()) {
            throw new AuraHandledException('오늘 날짜 이후의 날짜를 선택해 주세요.');
        }

        Id InterestModel = null;    // 관련 모델..

        // Contract 신규 생성.
        if(contract.Id == null) {
            contract.ContractStartDate__c = System.today();
            contract.Opportunity__c     = quote.Opportunity__c;
            contract.BusinessOffice__c  = quote.Opportunity__r.BusinessOffice__c;
            contract.Dealer__c          = quote.Opportunity__r.Dealer__c;
            if(contract.UsedUndertakingAmt__c > 0)  contract.isUsedUndertaking__c = true;

            insert contract;

            Campaign campaign = LsMSalesQCService.getCampaign(quote.Opportunity__c);

            for (QuoteLineItem__c qli : qliList) {
                contractLineItems.add(new ContractLineItem__c(
                        Contract__c         = contract.Id,
                        ProductId__c        = qli.Product__c,
                        ListPrice__c        = qli.ListPrice__c,
                        UnitPrice__c        = qli.UnitPrice__c,
                        NetPrice__c         = qli.NetPrice__c,
                        Quanitity__c        = 1,
                        TotalPrice__c       = qli.TotalPrice__c,
                        AdditionalDisc__c   = qli.AdditionalDisc__c,
                        LoanLimitAmt__c     = qli.LoanLimitAmt__c
                ));

                if(qli.Product__r.Type__c == '본체') {
                    InterestModel = qli.Product__c;
                    if(campaign != null) campaign.AssignNumber__c += 1;
                }
            }

            insert contractLineItems;

            for(QuoteOtherItem__c qoi : qoiList) {
                contractOtherItems.add(new ContractOtherItem__c(
                    Contract__c = contract.Id,
                    ProductName__c = qoi.ProductName__c,
                    NetPrice__c = qoi.NetPrice__c
                ));
            }

            insert contractOtherItems;

            if(tempDate != null) {

                LsMSalesQCService.checkValidDate(tempDate);

                if(isPersonAccount) {
                    quote.CustomerName__r.PersonBirthdate = Date.valueOf(tempDate);
                }
            }

            if(isPersonAccount) {
                // Name update시, error 피하기 위해 사용
                updateAccount = new Account(
                        Id = quote.CustomerName__r.Id,
                        PersonBirthdate = quote.CustomerName__r.PersonBirthdate,
                        BillingState = quote.CustomerName__r.BillingState,
                        BillingCity = quote.CustomerName__r.BillingCity,
                        BillingStreet = quote.CustomerName__r.BillingStreet,
                        BillingPostalCode = quote.CustomerName__r.BillingPostalCode
                );
            } else {
                updateAccount = quote.CustomerName__r;
            }

            update updateAccount;

            quote.Opportunity__r.CustomerExpectedDate__c = contract.CustomerExpectedDate__c;
            quote.Opportunity__r.StageName = '계약';
            quote.Opportunity__r.SystemStatus__c = '계약';
            update quote.Opportunity__r;
            if(campaign != null)    update campaign;

        }
        // Contract 수정.
        else {
            LsMSalesQCService.setContractDateNull(contract);
            /*for (QuoteLineItem__c qli : qliList) {
                if (qli.Product__r.Type__c == '본체') InterestModel = qli.Product__c;
            }*/
            update contract;

            quote.Opportunity__r.CustomerExpectedDate__c = contract.CustomerExpectedDate__c;
            quote.Opportunity__r.StageName = '계약';
            quote.Opportunity__r.SystemStatus__c = '계약';
            update quote.Opportunity__r;
        }
/*

        Opportunity oppty = null;
        for(Opportunity r : [
                SELECT Id, CustomerExpectedDate__c
                FROM Opportunity
                WHERE Id = :contract.Opportunity__c
        ]) {
            oppty = r;
            oppty.InterestModel__c = InterestModel;     // 관심 모델 업데이트.
        }

        if(oppty != null)   update oppty;
*/

        return contract.Id;
    }
}