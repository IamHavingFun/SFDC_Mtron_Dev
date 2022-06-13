/****************************************************************************************
  * @filename      : TestDataSalesFactory
  * @projectname   :
  * @author        : i2max_my.Seo
  * @date          : 2020-06-01 오후 12:38
  * @group         :
  * @group-content :
  * @description   : 
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author            description
  * ===============================================================
    0.1     2020-06-01 오후 12:38     i2max_my.Seo         Create
****************************************************************************************/
@IsTest
public class TestDataSalesFactory {

    public static void init(){}

    /**
     * @description Campaign Test Data.
     *
     * @param isInsert : Boolean
     *
     * @return Campaign
     */
    public static Campaign createCampaign(final Boolean isInsert) {
        Campaign campaign = new Campaign();

        campaign.Name = 'test Campaign';
        campaign.TestDriveOwner__c = TestDataBaseFactory.agencyUser.Id;

        if(isInsert) insert campaign;

        return campaign;
    }

    public static Campaign baseCampaign {get;set;}

    static {
        if(baseCampaign == null) {
            baseCampaign = createCampaign(true);
        }
    }

    /**
     * @description Lead Test Data.
     *
     * @param isInsert : Boolean
     *
     * @return Lead
     */
    public static Lead createLead(final Boolean isInsert) {
        Lead lead = new Lead();

        lead.LastName       = 'testing';
        lead.WebApex__c     = true;
        lead.Dealer__c      = TestDataBaseFactory.agencyAccount.Id;
        lead.MobilePhone    = '010-0000-0003';
        lead.CampaignId__c  = baseCampaign.Id;
        lead.Status         = '시승예약';

        if(isInsert) insert lead;

        return lead;
    }

    public static Lead baseLead {get;set;}

    static {
        if(baseLead == null) {
            baseLead = createLead(true);
        }
    }

    /**
     * @description Opportunity Test Data.
     *
     * @param isInsert : Boolean
     *
     * @return Opportunity
     */
    public static Opportunity createOpportunity(final Boolean isInsert) {
        Opportunity opportunity = new Opportunity();

        opportunity.AccountId           = TestDataBaseFactory.personAccount.Id;
        opportunity.Amount              = 0;
        opportunity.Name                = 'testOppty';
        opportunity.CloseDate           = TestDataUtilFactory.d;
        opportunity.StageName           = '견적';
        opportunity.SystemStatus__c     = '견적';
        opportunity.RecordTypeId        = TestDataUtilFactory.getRecordTypeId('Opportunity', 'PerFarCorp');
        opportunity.InterestModel__c    = TestDataProductFactory.baseProduct2.Id;

        if(isInsert) insert opportunity;

        return opportunity;
    }

    public static Opportunity baseOpportunity {get;set;}

    static {
        if(baseOpportunity == null) {
            baseOpportunity = createOpportunity(true);
        }
    }

    /**
     * @description Quote__c Test Data.
     *
     * @param isInsert : Boolean
     *
     * @return Quote__c
     */
    public static Quote__c createQuote(final Boolean isInsert) {
        Quote__c quote = new Quote__c();

        quote.Opportunity__c    = TestDataSalesFactory.baseOpportunity.Id;
        quote.Opportunity__r    = TestDataSalesFactory.baseOpportunity;
        quote.CustomerName__c   = TestDataBaseFactory.personAccount.Id;
        quote.CustomerName__r   = TestDataBaseFactory.personAccount;
        quote.LastQuoteAmt__c   = 0;
        quote.TotalLoanLimit__c = 0;
        quote.RecordTypeId      = TestDataUtilFactory.getRecordTypeId('Quote__c', 'PerFarCorp');

        if(isInsert) insert quote;

        return quote;
    }

    public static Quote__c baseQuote {get;set;}

    static {
        if(baseQuote == null) {
            baseQuote = createQuote(true);
        }
    }

    /**
     * @description QuoteLineItem__c Test Data.
     *
     * @param isInsert : Boolean
     *
     * @return QuoteLIneItem__c
     */
    public static QuoteLineItem__c createQuoteLineItem(final Boolean isInsert) {
        QuoteLineItem__c quoteLineItem = new QuoteLineItem__c();

        quoteLineItem.Product__c        = TestDataProductFactory.baseProduct2.Id;
        quoteLineItem.OpportunityId__c  = baseOpportunity.Id;
        quoteLineItem.Quote__c          = baseQuote.Id;
        quoteLineItem.Type__c           = '본체';
        quoteLineItem.UnitPrice__c      = 300000;
        quoteLineItem.NetPrice__c       = 100000;
        quoteLineItem.AdditionalDisc__c = 10000;
        quoteLineItem.LoanLimitAmt__c   = 1000000;

        if(isInsert) insert quoteLineItem;

        return quoteLineItem;
    }

    public static QuoteLineItem__c baseQuoteLineItem {get;set;}

    static {
        if(baseQuoteLineItem == null) {
            baseQuoteLineItem = createQuoteLineItem(true);
        }
    }

    /**
     * @description QuoteOtherItem__c Test Data.
     *
     * @param isInsert : Boolean
     *
     * @return QuoteOtherItem__c
     */
    public static QuoteOtherItem__c createQuoteOtherItem(final Boolean isInsert) {
        QuoteOtherItem__c quoteOtherItem = new QuoteOtherItem__c();

        quoteOtherItem.Quote__c = TestDataSalesFactory.baseQuote.Id;
        quoteOtherItem.ProductName__c = 'TestProduct';
        quoteOtherItem.NetPrice__c = 10000;

        if(isInsert) insert quoteOtherItem;

        return quoteOtherItem;
    }

    public static QuoteOtherItem__c baseQuoteOtherItem {get;set;}

    static {
        if(baseQuoteOtherItem == null) {
            baseQuoteOtherItem = createQuoteOtherItem(true);
        }
    }


    /**
     * Order Test Data.
     *
     * @param isInsert : Boolean
     *
     * @return Order__c
     */
    public static Order__c createOrder(final Boolean isInsert) {
        Order__c order = new Order__c();

        order.RecordTypeId              = TestDataUtilFactory.getRecordTypeId('Order__c', 'PerFarCorp');
        order.SalesDocNo__c             = '123';
        order.Status__c                 = '대리점 주문 신청';
        order.Division__c               = '전수배';
        order.LoanApprovalStatus__c     = '반려';
        order.DeliveryDate__c           = TestDataUtilFactory.d;
        order.OrderScheduleDate__c      = TestDataUtilFactory.d;
        order.DealerRep__c              = TestDataBaseFactory.agencyUser.Id;
        order.Dealer__c                 = TestDataBaseFactory.agencyAccount.Id;
        order.ErpS_RESULT__c            = '';
        order.ErpS_MESSAGE__c           = '';
        order.BusinessOfficeRep__c      = TestDataBaseFactory.businessOfficeUser.Id;
        order.BusinessOffice__c         = TestDataBaseFactory.businessOfficeAccount.Id;

        if(isInsert) insert order;

        return order;
    }

    // 본체 이앙기 제품
    public static Order__c orderForPerFarCorp {get;set;}
    public static Order__c orderForNhGov      {get;set;}

    static {
        if(orderForPerFarCorp == null) {
            orderForPerFarCorp = createOrder(true);
        }
        if(orderForNhGov == null) {
            orderForNhGov                       = orderForPerFarCorp.clone(false, true);
            orderForNhGov.RecordTypeId          = TestDataUtilFactory.getRecordTypeId('Order__c', 'NhGov');
            orderForNhGov.Status__c             = '영업소 주문 검토';
            orderForNhGov.Division__c           = '공장주문';
            orderForNhGov.PurposeOfOrder__c     = '재고보충';
            orderForNhGov.OrderAccount__c       = TestDataBaseFactory.governmentOrNHAccount.Id;

            insert orderForNhGov;
        }
    }

    /**
     * OrderLineItem Test Data.
     *
     * @param isInsert : Boolean
     *
     * @return OrderLineitem__c
     */
    public static OrderLineitem__c createOrderLineItem(final Boolean isInsert) {
        OrderLineitem__c oli = new OrderLineitem__c();

        oli.RecordTypeId    = TestDataUtilFactory.getRecordTypeId('OrderLineitem__c', 'PerFarCorp');
        oli.OrderId__c      = orderForPerFarCorp.Id;
        oli.ProductId__c    = TestDataProductFactory.ProductTractor.Id;
        oli.ProductId__r    = TestDataProductFactory.ProductTractor;
        oli.UnitPrice__c    = 1000000;
        // 대리점유형 수수료 및 수수료율
        oli.DTFeeMaxAmt__c  = 0;
        oli.DTFeeMinAmt__c  = 0;
        oli.DTFeeMaxRate__c = 0;
        oli.DTFeeMinRate__c = 0;
        // 서비스등급 수수료 및 수수료율
        oli.SGFeeMaxAmt__c  = 0;
        oli.SGFeeMinAmt__c  = 0;
        oli.SGFeeMaxRate__c = 0;
        oli.SGFeeMinRate__c = 0;
        // MS성과 수수료 및 수수료율
        oli.MSFeeMaxAmt__c  = 0;
        oli.MSFeeMinAmt__c  = 0;
        oli.MSFeeMaxRate__c = 0;
        oli.MSFeeMinRate__c = 0;
        // 지역차별 수수료 및 수수료율
        oli.LAFeeMaxAmt__c  = 0;
        oli.LAFeeMinAmt__c  = 0;
        oli.LAFeeMaxRate__c = 0;
        oli.LAFeeMinRate__c = 0;
        // 실판매 수수료 및 수수료율
        oli.RSFeeMaxAmt__c  = 0;
        oli.RSFeeMinAmt__c  = 0;
        oli.RSFeeMaxRate__c = 0;
        oli.RSFeeMinRate__c = 0;
        // 마케팅활동 수수료 및 수수료율
        oli.MAFeeMaxAmt__c  = 0;
        oli.MAFeeMinAmt__c  = 0;
        oli.MAFeeMaxRate__c = 0;
        oli.MAFeeMinRate__c = 0;
        // 조기결재 수수료 및 수수료율
        oli.EPFeeMaxAmt__c  = 0;
        oli.EPFeeMinAmt__c  = 0;
        oli.EPFeeMaxRate__c = 0;
        oli.EPFeeMinRate__c = 0;
        // 계절기종 수수료 및 수수료율
        oli.SPFeeMaxAmt__c  = 0;
        oli.SPFeeMinAmt__c  = 0;
        oli.SPFeeMaxRate__c = 0;
        oli.SPFeeMinRate__c = 0;
        // 제품구분 수수료 및 수수료율
        oli.PTFeeMaxAmt__c  = 0;
        oli.PTFeeMinAmt__c  = 0;

        if(isInsert) insert oli;

        return oli;
    }

    // 본체 이앙기 제품
    public static OrderLineitem__c oliForPerFarCorp {get;set;}
    public static OrderLineitem__c oliForNhGov      {get;set;}

    static {
        if(oliForPerFarCorp == null) {
            oliForPerFarCorp = createOrderLineItem(true);
        }
        if(oliForNhGov == null) {
            oliForNhGov                 = oliForPerFarCorp.clone(false, true);
            oliForNhGov.RecordTypeId    = TestDataUtilFactory.getRecordTypeId('OrderLineitem__c', 'NhGov');
            oliForNhGov.OrderId__c      = orderForNhGov.Id;
            oliForNhGov.ProductId__c    = TestDataProductFactory.ProductTractor.Id;
            oliForNhGov.ProductId__r    = TestDataProductFactory.ProductTractor;

            insert oliForNhGov;
        }
    }

    /**
     * @description SoldTo__c Test Data.
     *
     * @param isInsert : Boolean
     *
     * @return SoldTo__c
     */
    public static SoldTo__c createSoldTo(final Boolean isInsert) {
        SoldTo__c soldTo = new SoldTo__c();

        soldTo.Externalkey__c       = '001|SP|001';
        soldTo.Account__c           = TestDataBaseFactory.governmentOrNHAccount.Id;
        soldTo.Partner__c           = TestDataBaseFactory.governmentOrNHAccount.Id;

        if(isInsert) insert soldTo;

        return soldTo;
    }

    // 본체 이앙기 제품
    public static SoldTo__c baseSoldTo {get;set;}

    static {
        if(baseSoldTo == null) {
            baseSoldTo = createSoldTo(true);
        }
    }

    /**
     * @description SoldTo__c Test Data.
     *
     * @param isInsert : Boolean
     *
     * @return SoldTo__c
     */
    public static Contract__c createContract(final Boolean isInsert) {
        Contract__c contract = new Contract__c();

        contract.SelfPayDebtAmt__c              = 0;
        contract.SelfPayDueDate__c              = TestDataUtilFactory.d;
        contract.LeaseDueDate__c                = TestDataUtilFactory.d;
        contract.LoanDueDate__c                 = TestDataUtilFactory.d;
        contract.LeaseContractAmt__c            = 100000;
        contract.LoanContractAmt__c             = 100000;
        contract.Quote__c                       = baseQuote.Id;

        if(isInsert) insert contract;

        return contract;
    }

    // 본체 이앙기 제품
    public static Contract__c baseContract {get;set;}

    static {
        if(baseContract == null) {
            baseContract = createContract(true);
        }
    }

    /**
     * 자산 생성
     *
     * @param isInsert : insert 여부
     *
     * @return Asset
     */
    public static Asset createAsset(final Boolean isInsert) {
        Asset asset = new Asset();

        asset.Name              = '1234567890';
        asset.BatchNo__c        = '1234567890';
        asset.Product2Id        = TestDataProductFactory.baseProduct2.Id;
//        asset.Customer__c       = agencyAccount.Id;
        asset.Contract__c       = TestDataSalesFactory.baseContract.Id;
        asset.Dealer__c         = TestDataBaseFactory.agencyAccount.Id;
        asset.AccountId         = TestDataBaseFactory.governmentOrNHAccount.Id;
        asset.InventoryType__c  = '대리점재고';
        asset.Product2          = TestDataProductFactory.baseProduct2;

        if(isInsert) insert asset;

        return asset;
    }

    public static Asset baseAsset {get;set;}

    static {
        if(baseAsset == null) {
            baseAsset = createAsset(true);
        }
    }

    public static AssetPrice__c createAssetPrice(final Boolean isInsert) {
        AssetPrice__c assetPrice = new AssetPrice__c();

        assetPrice.AssetId__c = baseAsset.Id;
        assetPrice.SalePrice__c = 1000;

        if(isInsert)    insert assetPrice;

        return assetPrice;
    }

    // 자산 가격
    public static AssetPrice__c baseAssetPrice {get;set;}

    static {
        if(baseAssetPrice == null) {
            baseAssetPrice = createAssetPrice(true);
        }
    }

    /**
     * 전배요청 생성
     *
     * @param isInsert : insert 여부
     *
     * @return AssetTransferRequest__c
     */
    public static AssetTransferRequest__c createAssetTransferRequest(final Boolean isInsert) {
        AssetTransferRequest__c assetTransferRequest = new AssetTransferRequest__c();

        assetTransferRequest.Order__c = orderForPerFarCorp.Id;
        assetTransferRequest.AssetNo__c = baseAsset.Id;
        assetTransferRequest.Status__c = '요청';
        assetTransferRequest.Model__c = TestDataProductFactory.baseProduct2.Id;

        if(isInsert) insert assetTransferRequest;

        return assetTransferRequest;
    }

    public static AssetTransferRequest__c baseAssetTransferRequest {get;set;}
    public static AssetTransferRequest__c approvalAssetTransferRequest {get;set;}
    public static AssetTransferRequest__c rejectAssetTransferRequest {get;set;}

    static {
        if(baseAssetTransferRequest == null) {
            baseAssetTransferRequest = createAssetTransferRequest(true);
        }
    }

    /**
     * @description ContractLineItem__c Test Data.
     *
     * @param isInsert : Boolean
     *
     * @return ContractLineItem__c
     */
    public static ContractLineItem__c createContractLineItem(final Boolean isInsert) {
        ContractLineItem__c cli = new ContractLineItem__c();

        cli.Contract__c       = baseContract.Id;
        cli.NetPrice__c       = 100000;
        cli.AssetId__c        = baseAsset.Id;
        cli.LoanLimitAmt__c   = 1000000;

        if(isInsert) insert cli;

        return cli;
    }

    // 본체 이앙기 제품
    public static ContractLineItem__c baseCli {get;set;}

    static {
        if(baseCli == null) {
            baseCli = createContractLineItem(true);
        }
    }

    public static Fee__c createFee(final Boolean isInsert) {
        Fee__c fee = new Fee__c();

        fee.isActive__c             = true;
        fee.DealerType__c           = 'ALL';
        fee.ProductDivision__c      = '계절기종';
        fee.SG__c                   = 'ALL';
        fee.ProductType__c          = '이앙기';
        fee.MaxFeeRateFieldAPI__c   = 'DTFeeMaxRate__c';
        fee.MaxFeeRate__c           = 10;
        fee.MinFeeRateFieldAPI__c   = 'DTFeeMinRate__c';
        fee.MinFeeRate__c           = 3;

        if(isInsert) insert fee;

        return fee;
    }

    public static Fee__c baseFee {get;set;}

    static {
        if(baseFee == null) {
            baseFee = createFee(true);
        }
    }
}