/****************************************************************************************
  * @filename      : LsMSalesQuoteRegister
  * @projectname   : 
  * @author        : i2max_my.Seo 
  * @date          : 2020-07-01 오전 9:09
  * @group         : 
  * @group-content : 
  * @description   : 
  * @tester        : LsMSalesQuoteRegister_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author              description
  * ===============================================================
    0.1     2020-07-01 오전 9:09     i2max_my.Seo           Create
****************************************************************************************/
public without sharing class LsMSalesQuoteRegister {

    private static Id recordTypeIdForQuote;
    private static Id recordTypeIdForOppty;
    private static Date todayDate;

    static {
        recordTypeIdForQuote = I2ComUtil.getRecordType('Quote__c', 'PerFarCorp');
        recordTypeIdForOppty = I2ComUtil.getRecordType('Opportunity', 'PerFarCorp');
        todayDate = System.today();
    }

    /**
     * @description wrapper class for InitData
     */
    public class InitData extends I2ComClass.InitData {
        @AuraEnabled public LsMSalesQuoteData quoteWp {
            get {
                if(this.quoteWp == null) {
                    this.quoteWp = new LsMSalesQuoteData();
                }
                return this.quoteWp;
            }
            set;
        }
        @AuraEnabled public UnchangedData unchangedData {get;set;}
    }

    /**
     * @description init method
     *
     * @return I2ComClass.InitData
     */
    @AuraEnabled
    public static I2ComClass.InitData init(String type, String opptyId, String quoteId) {
        InitData initData = new InitData();
        Product2 product;
        final User currenctUser = ModelUser.getUserData();

        //==============================================================================
        //  단순 조회 시, initData.
        //==============================================================================
        if(type == 'v') {
            initData.quoteWp.quote = LsMSalesQCService.getQuoteById(quoteId);

            initData.quoteWp.qliWpList = new List<LsMSalesQuoteData.qliWrapper>();

            for(QuoteLineItem__c qli : initData.quoteWp.quote.QuoteLineItems__r) {
                LsMSalesQuoteData.qliWrapper qw = new LsMSalesQuoteData.qliWrapper();
                qw.prod         = qli.Product__r;
                qw.unitPrice    = qli.UnitPrice__c;
                qw.netPrice     = qli.NetPrice__c;
                qw.loanSupport  = (qli.LoanLimitAmt__c == null) ? 0 : qli.LoanLimitAmt__c;

                initData.quoteWp.qliWpList.add(qw);
            }

            initData.quoteWp.amtWrapper.totalPrice = LsMSalesQCService.sumTotalPrice(initData.quoteWp.quote.QuoteLineItems__r);
        }
        else {
            //==============================================================================
            //  수정 시, initData.
            //==============================================================================
            if(type == 'm') {
                // 견적.
                initData.quoteWp.quote = LsMSalesQCService.getQuoteById(quoteId);
                initData.quoteWp.quote.UsedUndertakingAmt__c    = (initData.quoteWp.quote.UsedUndertakingAmt__c == null) ? 0 : initData.quoteWp.quote.UsedUndertakingAmt__c;
                initData.quoteWp.quote.TotalLoanLimit__c        = (initData.quoteWp.quote.TotalLoanLimit__c == null) ? 0 : initData.quoteWp.quote.TotalLoanLimit__c;

                // 기회.
                initData.quoteWp.oppty = initData.quoteWp.quote.Opportunity__r;

                // 견적 제품.
                initData.quoteWp.qliList = initData.quoteWp.quote.QuoteLineItems__r;

                // 견적 기타 제품.
                initData.quoteWp.qoiList = initData.quoteWp.quote.QuoteOtherItem__r;

                // 견적 제품 Wrapper.
                initData.quoteWp.qliWpList = new List<LsMSalesQuoteData.qliWrapper>();

                for(QuoteLineItem__c qli : initData.quoteWp.quote.QuoteLineItems__r) {
                    if(qli.Product__r.Type__c == '본체') initData.quoteWp.product = qli.Product__r;

                    LsMSalesQuoteData.qliWrapper qw = new LsMSalesQuoteData.qliWrapper();

                    qw.prod         = qli.Product__r;
                    qw.unitPrice    = qli.UnitPrice__c;
                    qw.netPrice     = qli.NetPrice__c;
                    qw.loanSupport  = (qli.LoanLimitAmt__c == null) ? 0 : qli.LoanLimitAmt__c;

                    initData.quoteWp.qliWpList.add(qw);
                }

                // 견적 관련 금액 Wrapper.
                initData.quoteWp.amtWrapper.totalPrice      = LsMSalesQCService.sumTotalPrice(initData.quoteWp.quote.QuoteLineItems__r);
                initData.quoteWp.amtWrapper.discount        = LsMSalesQCService.sumTotalProductDiscount(initData.quoteWp.quote.QuoteLineItems__r);
                initData.quoteWp.amtWrapper.totalDiscount   = initData.quoteWp.quote.fm_DiscountAmt__c;
                initData.quoteWp.amtWrapper.discountRate    = initData.quoteWp.quote.fm_Discount__c;
                initData.quoteWp.amtWrapper.totalUnitPrice  = LsMSalesQCService.sumTotalUnitPrice(initData.quoteWp.quote.QuoteLineItems__r);

                initData.unchangedData = new UnchangedData(initData.quoteWp.quote, initData.quoteWp.qliWpList);

                for(QuoteOtherItem__c qoi : initData.quoteWp.quote.QuoteOtherItem__r) {
                    LsMSalesQuoteData.qliWrapper qw = new LsMSalesQuoteData.qliWrapper();

                    qw.qliProductType = '기타 작업기';
                    qw.netPrice = qoi.NetPrice__c;
                    qw.qliName = qoi.ProductName__c;
                    qw.isOtherWorkingMachine = true;

                    initData.quoteWp.qliWpList.add(qw);

                    initData.quoteWp.amtWrapper.totalPrice += qoi.NetPrice__c;
                }
            }
            //==============================================================================
            //  생성 시, initData.
            //==============================================================================
            else {
                //==============================================================================
                // 고객상담에서 opptyId가 넘어 왔을 시, initData.
                //==============================================================================
                if(opptyId != null) {
                    Opportunity oppty = [
                        SELECT Id, AccountId, InterestModel__c, StageName, Account.Name, Account.LastName, SystemStatus__c
                        FROM Opportunity
                        WHERE Id = :opptyId
                    ];

                    oppty.StageName = '견적';
                    oppty.SystemStatus__c = '견적';

                    if (oppty.InterestModel__c != null) {
                        product = LsMSalesQCService.getProduct2ById(oppty.InterestModel__c);
                    }

                    ProductPrice__c productPrice = LsMSalesQCService.getProductPrice(product.Id);

                    initData.quoteWp.quote = new Quote__c(
                            CustomerName__c = oppty.AccountId,
                            CustomerName__r = oppty.Account,
                            Opportunity__c = oppty.Id,
                            RecordTypeId = recordTypeIdForQuote,
                            IsPrimary__c = true
                    );

                    initData.quoteWp.quote.Opportunity__c   = opptyId;
                    initData.quoteWp.oppty                  = oppty;

                    if(product != null) {
                        initData.quoteWp.product = product;

                        initData.quoteWp.qliList = new List<QuoteLineItem__c>{
                                new QuoteLineItem__c(
                                        Product__c      = product.Id,
                                        Product__r      = product,
                                        Quantity__c     = 1,
                                        ListPrice__c    = product.ListPrice__c,
                                        UnitPrice__c    = (productPrice == null) ? ((product.ListPrice__c == null) ? 0 : product.ListPrice__c) : productPrice.DealerSupplyAmt__c,
                                        NetPrice__c     = (productPrice == null) ? ((product.ListPrice__c == null) ? 0 : product.ListPrice__c) : productPrice.DealerSupplyAmt__c,
                                        TotalPrice__c   = (productPrice == null) ? ((product.ListPrice__c == null) ? 0 : product.ListPrice__c) : productPrice.DealerSupplyAmt__c,
                                        Type__c         = product.Type__c,
                                        LoanLimitAmt__c = (product.LoanSupportLimit__c == null) ? 0 : product.LoanSupportLimit__c
                                )
                        };

                        initData.quoteWp.amtWrapper.totalPrice      = LsMSalesQCService.sumTotalPrice(initData.quoteWp.qliList);
                        initData.quoteWp.amtWrapper.resultPrice     = initData.quoteWp.amtWrapper.totalPrice;
                        initData.quoteWp.amtWrapper.totalUnitPrice  = initData.quoteWp.amtWrapper.totalPrice;
                        initData.quoteWp.amtWrapper.discount        = 0;
                        initData.quoteWp.amtWrapper.discountRate    = 0;

                        // 최종견적가 세팅.
                        initData.quoteWp.quote.LastQuoteAmt__c           = initData.quoteWp.amtWrapper.totalPrice;
                        initData.quoteWp.quote.UsedUndertakingAmt__c     = 0;

                        LsMSalesQuoteData.qliWrapper qw = new LsMSalesQuoteData.qliWrapper();
                        qw.prod         = product;
                        qw.unitPrice    = (productPrice == null) ? product.ListPrice__c : productPrice.DealerSupplyAmt__c;
                        qw.netPrice     = (productPrice == null) ? product.ListPrice__c : productPrice.DealerSupplyAmt__c;
                        qw.loanSupport  = (product.LoanSupportLimit__c == null) ? 0 : product.LoanSupportLimit__c;

                        if(initData.quoteWp.qliWpList == null) {
                            initData.quoteWp.qliWpList = new List<LsMSalesQuoteData.qliWrapper>{qw};
                        }
                        else {
                            initData.quoteWp.qliWpList.add(qw);
                        }
                    }
                }
                //==============================================================================
                // 견적서 작성 시,  initData.
                //==============================================================================
                else {
                    initData.quoteWp.quote = new Quote__c(
                            RecordTypeId            = recordTypeIdForQuote,
                            IsPrimary__c            = true,
                            TotalLoanLimit__c       = 0,
                            UsedUndertakingAmt__c   = 0
                    );

                    initData.quoteWp.oppty = new Opportunity(
                            StageName = '견적',
                            RecordTypeId = recordTypeIdForOppty,
                            BusinessOffice__c = currenctUser.Account.ParentId,
                            Dealer__c = currenctUser.AccountId,
                            CloseDate = todayDate.addDays(30)
                    );
                }
            }
        }

        return initData;
    }

    @AuraEnabled
    public static String save(Opportunity oppty, Quote__c quote, List<QuoteLineItem__c> qliList, List<QuoteOtherItem__c> qoiList, List<String> deleteIds) {
        Set<Id> prodIdSet = new Set<Id>();
        List<Product2> prodListForMain;

        if(deleteIds.size() != 0) {
            System.debug('@@@@@@@@@@@@@ deleteIds : ' + deleteIds);
            delete [SELECT Id FROM QuoteLineItem__c WHERE Id IN :deleteIds];
            delete [SELECT Id FROM QuoteOtherItem__c WHERE Id IN :deleteIds];
        }

        // 수정 시 필요한 값 초기화.
        quote.TotalLoanLimit__c = 0;

        for(QuoteLineItem__c qli : qliList) {
            // 더블 체크를 위해 product id를 담음.
            prodIdSet.add(qli.Product__c);
            quote.TotalLoanLimit__c += (qli.LoanLimitAmt__c != null) ? qli.LoanLimitAmt__c : 0;
        }

        //================================================================================================================
        // 본체 체크를 위한 로직.
        //================================================================================================================
        prodListForMain = [
                SELECT Id
                FROM Product2
                WHERE Id IN :prodIdSet
                AND Type__c = '본체'
        ];

        if(prodListForMain.size() == 0) {
            throw new AuraHandledException('선택된 본체가 없습니다.');
        } else {
            // 관심 모델..
            oppty.InterestModel__c = prodListForMain[0].Id;
            System.debug('관심모델 : ' + oppty.InterestModel__c);
        }

        //==============================================================================
        //  기회.
        //==============================================================================
        // 제목은 트리거로 대체
        //oppty.Name          = LsMSalesQCService.getOpptyName(quote.CustomerName__r.LastName, mainProd.Name);
        oppty.AccountId     = quote.CustomerName__c;
        oppty.Amount        = quote.LastQuoteAmt__c;
        oppty.StageName         = '견적';
        oppty.SystemStatus__c   = '견적';
        // TODO : 2020-12-01    본체 qli dealerlistPrice oppty의 dealerlistprice 에 할당.

        System.debug('--------------');
        System.debug('quote.LastQuoteAmt__c ==> ' + quote.LastQuoteAmt__c);
        System.debug('oppty.Amount ==> ' + oppty.Amount);
        System.debug('--------------');
        System.debug(JSON.serialize(oppty));
        System.debug('--------------');
        upsert oppty;



        //==============================================================================
        //  견적.
        //==============================================================================
        quote.Opportunity__c = oppty.Id;

        upsert quote;

        //==============================================================================
        //  견적 제품.
        //==============================================================================
        for(QuoteLineItem__c qli : qliList) {
            if(String.isEmpty(qli.Quote__c))            qli.Quote__c            = quote.Id;
            if(String.isEmpty(qli.OpportunityId__c))    qli.OpportunityId__c    = oppty.Id;
            qli.RecordTypeId = I2ComUtil.getRecordType('QuoteLineItem__c', 'PerFarCorp');
            qli.Product__r = null;
        }

        upsert qliList;

        for(QuoteOtherItem__c qoi : qoiList) {
            if(String.isBlank(qoi.Quote__c))    qoi.Quote__c = quote.Id;
        }

        upsert qoiList;

        return quote.Id;
    }

    @AuraEnabled
    public static LsMSalesQuoteData getQliDataForDelete(LsMSalesQuoteData quoteWrapper) {
        quoteWrapper.amtWrapper.totalPrice      = LsMSalesQCService.sumTotalPrice(quoteWrapper.qliList);

        quoteWrapper.amtWrapper.discount        = 0;
        quoteWrapper.amtWrapper.totalDiscount   = 0;
        quoteWrapper.amtWrapper.totalUnitPrice  = 0;

        for(QuoteLineItem__c qli : quoteWrapper.qliList) {
            quoteWrapper.amtWrapper.discount       += (qli.AdditionalDisc__c != null) ? qli.AdditionalDisc__c : 0;
            quoteWrapper.amtWrapper.totalDiscount  += (qli.AdditionalDisc__c != null) ? qli.AdditionalDisc__c : 0;
            quoteWrapper.amtWrapper.totalUnitPrice += qli.UnitPrice__c;
        }

        for(QuoteOtherItem__c qoi : quoteWrapper.qoiList) {
            quoteWrapper.amtWrapper.totalPrice += qoi.NetPrice__c;
            quoteWrapper.amtWrapper.totalUnitPrice += qoi.NetPrice__c;
        }

        quoteWrapper.amtWrapper.discountRate = (quoteWrapper.amtWrapper.totalUnitPrice != 0) ? LsMSalesQCService.calculateDiscountRate(quoteWrapper.amtWrapper.totalDiscount, quoteWrapper.amtWrapper.totalUnitPrice) : 0;

        return quoteWrapper;
    }

    public class UnchangedData {
        @AuraEnabled public Quote__c                           unchangedQuote          {get;private set;}
        @AuraEnabled public List<LsMSalesQuoteData.qliWrapper> unchangedQliWrapperList {get;private set;}

        public UnchangedData(Quote__c quote, List<LsMSalesQuoteData.qliWrapper> qliWrapperList) {
            this.unchangedQuote          = quote;
            this.unchangedQliWrapperList = qliWrapperList;
        }
    }
}