/****************************************************************************************
  * @filename      : LsMSalesQCService
  * @projectname   : 
  * @author        : i2max_my.Seo 
  * @date          : 2020-07-02 오후 3:54
  * @group         : 
  * @group-content : 
  * @description   : 모바일 Quote & Contract 관련 Service.
  * @tester        : LsMSalesQCService_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author              description
  * ===============================================================
    0.1     2020-07-02 오후 3:54     i2max_my.Seo           Create
****************************************************************************************/
public without sharing class LsMSalesQCService {

    /**
     * 견적 Id에 따른 견적 Data return.
     *
     * @param quoteId : Quote__c Id.
     *
     * @return Quote__c
     */
    public static Quote__c getQuoteById(String quoteId) {
        return [
                SELECT CustomerName__r.PersonBirthdate, CustomerName__r.LastName, CustomerName__r.PersonMobilePhone,
                        CustomerName__r.BillingPostalCode, CustomerName__r.BillingState, CustomerName__r.BillingCity, CustomerName__r.BillingStreet, CustomerName__r.RecordType.DeveloperName,
                        CustomerName__r.Mobile__c, CustomerName__r.Name,
                        LastQuoteAmt__c, UsedUndertakingAmt__c, fm_UsedUndertakingDiscountAmt__c, fm_Discount__c, fm_DiscountAmt__c,
                        Opportunity__r.StageName, Opportunity__r.CustomerExpectedDate__c, Opportunity__r.Dealer__c, Opportunity__r.BusinessOffice__c, TotalLoanLimit__c,
                (
                        SELECT Id, Type__c, Product__c, OpportunityId__c, ListPrice__c, UnitPrice__c, NetPrice__c, TotalPrice__c, AdditionalDisc__c, LoanLimitAmt__c,
                                Product__r.Name, Product__r.ProductType__c, Product__r.ListPrice__c, Product__r.Type__c,
                                Product__r.Option1__c, Product__r.Option2__c, Product__r.Option3__c, Product__r.Option4__c
                        FROM QuoteLineItems__r
                ),
                (
                        SELECT Id, ProductName__c, NetPrice__c
                        FROM QuoteOtherItem__r
                )
                FROM Quote__c
                WHERE Id = :quoteId
        ];
    }

    /**
     * 계약 Id에 따른 계약 Data return.
     *
     * @param contractId : Contract__c Id.
     *
     * @return Contract__c
     */
    public static Contract__c getContractById(String contractId) {
        return [
                SELECT Id, Name, Quote__c, eFormsignStatus__c, CustomerExpectedDate__c, LoanApplyDate__c, LeaseApplyDate__c,
                        TotalPrice__c, Company__c, ContractAmtCollectDueDate__c, SubsidyCollectDueDate__c, SelfPayCollectDueDate__c, UsedUndertakingModel__c,
                        ContractAmt__c, LoanContractAmt__c,
                        SubsidyContractAmt__c, LeaseContractAmt__c,
                        SelfPayContractAmt__c, UsedUndertakingAmt__c, isLWSRegistration__c, UsedUndertakingYear__c,
                        Remarks__c, AdditionalTerms__c, CustomerReviewCheck__c
                FROM Contract__c
                WHERE Id = :contractId
        ];
    }

    /**
     * 견적 제품을 생성 하기 위해 필요한 Product return.
     *
     * @param prodId : Product2 Id.
     *
     * @return Product2
     */
    public static Product2 getProduct2ById(String prodId) {
        return [
                SELECT Id, Name, Type__c, ProductType__c, HorsePowerStandard__c, Segment__c,
                       Option1__c, Option2__c, Option3__c, Option4__c,
                       DealerListPrice__c, ListPrice__c, LoanSupportLimit__c
                FROM Product2
                WHERE Id = :prodId
        ];
    }

    /**
     * 해당 제품 Id에 따른 대리점 가격표 구함.
     *
     * @param prodId : ProductId
     *
     * @return ProductPrice__c
     */
    public static ProductPrice__c getProductPrice(final String prodId) {
        // 무조건 한 건이 나와야 함.
        List<ProductPrice__c> productPriceList = [
                SELECT Id, DealerSupplyAmt__c
                FROM ProductPrice__c
                WHERE Dealer__c = :ModelUser.getUserData().AccountId
                AND Product__c = :prodId
                ORDER BY LastModifiedDate DESC
                LIMIT 1
        ];

//        if(productPriceList.size() == 0) {
//            throw new AuraHandledException('해당 제품의 대리점 가격표가 없습니다.');
//        }

        return productPriceList.size() == 0 ? null : productPriceList[0];
    }

    /**
     * quoteLineItem__c 의 NetPrice__c 총합을 return.
     *
     * @param qliList List<QuoteLineItem__c>
     *
     * @return Decimal
     */
    public static Decimal sumTotalPrice(final List<QuoteLineItem__c> qliList) {
        Decimal totalPrice = 0;

        for(QuoteLineItem__c qli : qliList) {
            if(qli.NetPrice__c == null) {
                throw new AuraHandledException('견적 품목에 판매가 값이 없습니다.');
            }

            totalPrice += qli.NetPrice__c;
        }

        return totalPrice;
    }

    /**
     * @param qliList : List<QuoteLineItem__c>
     *
     * @return Decimal
     */
    public static Decimal sumTotalUnitPrice(final List<QuoteLineItem__c> qliList) {
        Decimal totalPrice = 0;

        for(QuoteLineItem__c qli : qliList) {
            totalPrice += (qli.UnitPrice__c == null ? 0 : qli.UnitPrice__c);
        }

        return totalPrice;
    }

    /**
     * @param qliList : List<QuoteLineItem__c>
     *
     * @return Decimal
     */
    public static Decimal sumTotalProductDiscount(final List<QuoteLineItem__c> qliList) {
        Decimal totalPrice = 0;

        for(QuoteLineItem__c qli : qliList) {
            totalPrice += (qli.AdditionalDisc__c == null ? 0 : qli.AdditionalDisc__c);
        }

        return totalPrice;
    }

    /**
     * @param totalDiscount     : Decimal
     * @param totalUnitPrice    : Decimal
     *
     * @return Decimal
     */
    public static Decimal calculateDiscountRate(final Decimal totalDiscount, final Decimal totalUnitPrice) {
        return ((totalDiscount/totalUnitPrice) * 100).round();
    }

    /**
     * 정상적인 날짜 여부 판단.
     *
     * @param targetDate : Date
     */
    public static void checkValidDate(String targetDate) {
        List<String> dateList = targetDate.split('-');

        Date targetDt = Date.newInstance(Integer.valueOf(dateList[0]), Integer.valueOf(dateList[1]), Integer.valueOf(dateList[2]));

        if(Integer.valueOf(dateList[1]) != targetDt.month()) {
            throw new AuraHandledException('날짜 선택이 잘못되었습니다. 다시 선택해주세요');
        }
    }


    public static void checkWorkingMachine(List<QuoteLineItem__c> qliList, Product2 prod) {
        for(QuoteLineItem__c qli : qliList) {
            if(qli.Product__c == prod.Id) {
                throw new AuraHandledException('동일한 작업기를 선택할 수 없습니다.');
            }

            if(qli.Product__r.Segment__c == prod.Segment__c) {
                throw new AuraHandledException('동일한 옵션의 작업기를 선택할 수 없습니다.');
            }
        }
    }

    /**
     * 해당 필드가 null인 경우, 서버로 보낼 때, 해당 필드 자체가 넘어 오지 않기 때문에
     * check 해서 null값으로 세팅.
     *
     * @param contract : Contract__c
     */
    public static void setContractDateNull(Contract__c contract) {
        if(!contract.isSet('ContractAmtCollectDueDate__c')) {
            contract.ContractAmtCollectDueDate__c = null;
        }
        if(!contract.isSet('LoanApplyDate__c')) {
            contract.LoanApplyDate__c = null;
        }
        if(!contract.isSet('SubsidyCollectDueDate__c')) {
            contract.SubsidyCollectDueDate__c = null;
        }
        if(!contract.isSet('LeaseApplyDate__c')) {
            contract.LeaseApplyDate__c = null;
        }
        if(!contract.isSet('SelfPayCollectDueDate__c')) {
            contract.SelfPayCollectDueDate__c = null;
        }
    }

    /**
     * Opportunity Name 생성.
     *
     * @param lastName : Account.LastName
     * @param prodName : Product.Name
     *
     * @return String => Account.LastName - Product.Name -  CloseDate
     */
    public static String getOpptyName(final String lastName, final String prodName) {
        return getOpptyName(lastName, prodName, System.now().addDays(30).format('yyyyMMdd'));
    }

    /**
     * Opportunity Name 생성.
     *
     * @param lastName : Account.LastName
     * @param prodName : Product.Name
     * @param formatDate : String
     *
     * @return String => Account.LastName - Product.Name -  CloseDate
     */
    public static String getOpptyName(final String lastName, final String prodName, final String formatDate) {
        return String.join(new List<String>{
            lastName,
            prodName,
            formatDate
        }, '-');
    }

    /**
     * Opportunity에 연결되 있는 Campaign or null return.
     *
     * @param opptyId : Opportunity Id
     *
     * @return Campaign or null
     */
    public static Campaign getCampaign(final String opptyId) {

        Opportunity oppty = [
            SELECT Id,
                   CampaignId, Campaign.AssignNumber__c
            FROM Opportunity
            WHERE Id = :opptyId
        ];

        if(oppty.CampaignId != null && String.isBlank(String.valueOf(oppty.Campaign.AssignNumber__c))) {
            oppty.Campaign.AssignNumber__c = 0;
        }

        return (oppty.CampaignId != null) ? oppty.Campaign : null;
    }
}