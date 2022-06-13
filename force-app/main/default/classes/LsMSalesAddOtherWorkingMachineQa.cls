/****************************************************************************************
  * @filename      : LsMSalesAddOtherWorkingMachineQa
  * @author        : i2max_my.Seo 
  * @date          : 2020-12-21 오전 8:38
  * @group         : 
  * @group-content : 
  * @description   : 
  * @tester        : LsMSalesAddOtherWorkingMachineQa_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author              description
  * ===============================================================
    0.1     2020-12-21 오전 8:38     i2max_my.Seo           Create
****************************************************************************************/
public with sharing class LsMSalesAddOtherWorkingMachineQa {
    @AuraEnabled
    public static LsMSalesQuoteData setQuoteOtherItem(LsMSalesQuoteData quoteWrapper) {
        Integer lastIndex = quoteWrapper.qoiList.size() - 1;

        quoteWrapper.amtWrapper.totalPrice      = LsMSalesQCService.sumTotalPrice(quoteWrapper.qliList);

        quoteWrapper.amtWrapper.totalUnitPrice = 0;

        if(quoteWrapper.qliList.size() > 0) {
            for(QuoteLineItem__c qli : quoteWrapper.qliList) {
                quoteWrapper.amtWrapper.totalUnitPrice += qli.UnitPrice__c;
            }
        }

        if(quoteWrapper.qoiList.size() > 0) {
            for(QuoteOtherItem__c qoi : quoteWrapper.qoiList) {
                quoteWrapper.amtWrapper.totalUnitPrice += qoi.NetPrice__c;
                quoteWrapper.amtWrapper.totalPrice += qoi.NetPrice__c;
            }
        }

        quoteWrapper.amtWrapper.discountRate    = LsMSalesQCService.calculateDiscountRate(quoteWrapper.amtWrapper.totalDiscount, quoteWrapper.amtWrapper.totalUnitPrice);

        LsMSalesQuoteData.qliWrapper qw = new LsMSalesQuoteData.qliWrapper();
        qw.netPrice = quoteWrapper.qoiList[lastIndex].NetPrice__c;
        qw.qliName = quoteWrapper.qoiList[lastIndex].ProductName__c;
        qw.isOtherWorkingMachine = true;
        qw.qliProductType = '기타 작업기';

        //보여 주기 용 wrapperData 구성.
        quoteWrapper.qliWpList.add(qw);

        return quoteWrapper;
    }

    @AuraEnabled
    public static LsMSalesQuoteData modifyQuoteOtherItem(LsMSalesQuoteData quoteWrapper, QuoteOtherItem__c qoi, LsMSalesQuoteData.qliWrapper qliWrapper) {
        List<QuoteOtherItem__c> quoteOtherItems = new List<QuoteOtherItem__c>();

        quoteWrapper.amtWrapper.totalPrice      = LsMSalesQCService.sumTotalPrice(quoteWrapper.qliList);

        quoteWrapper.amtWrapper.totalUnitPrice = 0;

        if(quoteWrapper.qliList.size() > 0) {
            for(QuoteLineItem__c qli : quoteWrapper.qliList) {
                quoteWrapper.amtWrapper.totalUnitPrice += qli.NetPrice__c;
            }
        }

        if(quoteWrapper.qoiList.size() > 0) {
            for(QuoteOtherItem__c qoitem : quoteWrapper.qoiList) {
                if(qoitem.ProductName__c == qliWrapper.qliName && qoitem.NetPrice__c == qliWrapper.netPrice) {
                    qoitem.ProductName__c = qoi.ProductName__c;
                    qoitem.NetPrice__c = qoi.NetPrice__c;

                    quoteWrapper.amtWrapper.totalUnitPrice += qoitem.NetPrice__c;
                    quoteWrapper.amtWrapper.totalPrice += qoitem.NetPrice__c;
                }
            }
        }

        quoteWrapper.amtWrapper.discountRate = LsMSalesQCService.calculateDiscountRate(quoteWrapper.amtWrapper.totalDiscount, quoteWrapper.amtWrapper.totalUnitPrice);

        for(LsMSalesQuoteData.qliWrapper wrapper : quoteWrapper.qliWpList) {
            if(JSON.serialize(wrapper) == JSON.serialize(qliWrapper)) {
                wrapper.netPrice = qoi.NetPrice__c;
                wrapper.qliName = qoi.ProductName__c;
            }
        }

        return quoteWrapper;
    }
}