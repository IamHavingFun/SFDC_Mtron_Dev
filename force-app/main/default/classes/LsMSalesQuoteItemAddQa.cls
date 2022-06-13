/****************************************************************************************
  * @filename      : LsMSalesQuoteItemAddQa
  * @projectname   : 
  * @author        : i2max_my.Seo 
  * @date          : 2020-07-02 오후 3:41
  * @group         : 
  * @group-content : 
  * @description   : 
  * @tester        : LsMSalesQuoteItemAddQa_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author              description
  * ===============================================================
    0.1     2020-07-02 오후 3:41     i2max_my.Seo           Create
****************************************************************************************/
public with sharing class LsMSalesQuoteItemAddQa {

    /**
     * 본체 추가 시, QuoteLineItem__c 및 계산 wrapper 세팅.
     *
     * @param quoteWrapper  : LsMSalesQuoteData
     * @param prodId        : Product2 Id
     *
     * @return LsMSalesQuoteData
     */
    @AuraEnabled
    public static LsMSalesQuoteData getMainQliDataForQuote(LsMSalesQuoteData quoteWrapper, String prodId) {
        Product2 prod = LsMSalesQCService.getProduct2ById(prodId);

        ProductPrice__c productPrice = LsMSalesQCService.getProductPrice(prod.Id);

        if(quoteWrapper.qliList.isEmpty()) {
            quoteWrapper.qliList.add(
                    new QuoteLineItem__c(
                            Product__c          = prod.Id,
                            Quantity__c         = 1,
                            Product__r          = prod,
                            ListPrice__c        = prod.ListPrice__c,
                            UnitPrice__c        = (productPrice != null) ? productPrice.DealerSupplyAmt__c : prod.ListPrice__c,
                            NetPrice__c         = (productPrice != null) ? productPrice.DealerSupplyAmt__c : prod.ListPrice__c,
                            TotalPrice__c       = (productPrice != null) ? productPrice.DealerSupplyAmt__c : prod.ListPrice__c,
                            Type__c             = prod.Type__c,
                            AdditionalDisc__c   = 0,
                            LoanLimitAmt__c     = (prod.LoanSupportLimit__c != null) ? prod.LoanSupportLimit__c : 0
                    )
            );
        }
        else {
            quoteWrapper.qliList[0].Product__c      = prod.Id;
            quoteWrapper.qliList[0].Product__r      = prod;
            quoteWrapper.qliList[0].ListPrice__c    = prod.ListPrice__c;
            quoteWrapper.qliList[0].UnitPrice__c    = (productPrice != null) ? productPrice.DealerSupplyAmt__c : prod.ListPrice__c;
            quoteWrapper.qliList[0].NetPrice__c     = (productPrice != null) ? productPrice.DealerSupplyAmt__c : prod.ListPrice__c;
            quoteWrapper.qliList[0].LoanLimitAmt__c = (prod.LoanSupportLimit__c != null) ? prod.LoanSupportLimit__c : 0;
        }

        quoteWrapper.amtWrapper.totalPrice = LsMSalesQCService.sumTotalPrice(quoteWrapper.qliList);

        quoteWrapper.quote.LastQuoteAmt__c = quoteWrapper.amtWrapper.totalPrice;
        quoteWrapper.quote.UsedUndertakingAmt__c = 0;

        LsMSalesQuoteData.qliWrapper qw = new LsMSalesQuoteData.qliWrapper();
        qw.prod         = prod;
        qw.unitPrice    = qw.netPrice =  (productPrice != null) ? productPrice.DealerSupplyAmt__c : prod.ListPrice__c;
        qw.loanSupport  = (prod.LoanSupportLimit__c != null) ? prod.LoanSupportLimit__c : 0;


        // 보여 주기 용 wrapperData 구성.
        if(quoteWrapper.qliWpList == null) {
            quoteWrapper.qliWpList = new List<LsMSalesQuoteData.qliWrapper>{qw};
        }
        else {
            if(quoteWrapper.qliWpList.size() == 0) {
                quoteWrapper.qliWpList.add(qw);
            }
            else {
                quoteWrapper.qliWpList[0] = qw;
            }
        }

        return quoteWrapper;
    }

    @AuraEnabled
    public static LsMSalesQuoteData reCalculateNetPrice(LsMSalesQuoteData quoteWrapper, Decimal discount) {

        quoteWrapper.qliList[0].TotalPrice__c   = quoteWrapper.qliList[0].UnitPrice__c - discount;
        quoteWrapper.qliList[0].NetPrice__c     = quoteWrapper.qliList[0].UnitPrice__c - discount;
        quoteWrapper.qliWpList[0].netPrice      = quoteWrapper.qliList[0].UnitPrice__c - discount;
        quoteWrapper.amtWrapper.resultPrice     = quoteWrapper.qliList[0].UnitPrice__c - discount;
        quoteWrapper.amtWrapper.totalPrice      = LsMSalesQCService.sumTotalPrice(quoteWrapper.qliList);

        quoteWrapper.amtWrapper.totalUnitPrice  += quoteWrapper.qliList[0].UnitPrice__c;
        quoteWrapper.amtWrapper.discount        += quoteWrapper.amtWrapper.totalDiscount   += discount;
        quoteWrapper.amtWrapper.discountRate    = LsMSalesQCService.calculateDiscountRate(quoteWrapper.amtWrapper.totalDiscount, quoteWrapper.amtWrapper.totalUnitPrice);

        return quoteWrapper;
    }
}