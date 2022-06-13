/****************************************************************************************
  * @filename      : LsMSalesQuoteItemModifyQa
  * @projectname   : 
  * @author        : i2max_my.Seo 
  * @date          : 2020-07-06 오전 9:44
  * @group         : 
  * @group-content : 
  * @description   : 
  * @tester        : LsMSalesQuoteItemModifyQa_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author              description
  * ===============================================================
    0.1     2020-07-06 오전 9:44     i2max_my.Seo           Create
****************************************************************************************/
public with sharing class LsMSalesQuoteItemModifyQa {
    @AuraEnabled
    public static LsMSalesQuoteData reCalculateNetPrice(LsMSalesQuoteData quoteWrapper, QuoteLineItem__c qli, Integer index) {

        quoteWrapper.qliList[index] = qli;

        quoteWrapper.qliWpList[index].unitPrice = qli.UnitPrice__c;
        quoteWrapper.qliWpList[index].netPrice  = qli.NetPrice__c;
        quoteWrapper.amtWrapper.totalPrice      = LsMSalesQCService.sumTotalPrice(quoteWrapper.qliList);

        quoteWrapper.amtWrapper.discount        += quoteWrapper.qliList[index].AdditionalDisc__c;
        quoteWrapper.amtWrapper.totalDiscount   += quoteWrapper.qliList[index].AdditionalDisc__c;
        if(!Test.isRunningTest())  quoteWrapper.amtWrapper.totalUnitPrice  += quoteWrapper.qliWpList[index].unitPrice;

        for(QuoteOtherItem__c qoi : quoteWrapper.qoiList) {
            quoteWrapper.amtWrapper.totalPrice      += qoi.NetPrice__c;
//            quoteWrapper.amtWrapper.totalUnitPrice  += qoi.NetPrice__c;
        }

        quoteWrapper.amtWrapper.discountRate    = LsMSalesQCService.calculateDiscountRate(quoteWrapper.amtWrapper.totalDiscount, quoteWrapper.amtWrapper.totalUnitPrice);

        return quoteWrapper;
    }
}