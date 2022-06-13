/****************************************************************************************
  * @filename      : LsMSalesQuoteData
  * @projectname   : 
  * @author        : i2max_my.Seo 
  * @date          : 2020-07-02 오후 3:51
  * @group         : 
  * @group-content : 
  * @description   : 모바일 Quote Data.
  * @tester        : LsMSalesQuoteData_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author              description
  * ===============================================================
    0.1     2020-07-02 오후 3:51     i2max_my.Seo           Create
****************************************************************************************/
public with sharing class LsMSalesQuoteData {

    @AuraEnabled public Quote__c                    quote       {get;set;}
    @AuraEnabled public Opportunity                 oppty       {get;set;}
    @AuraEnabled public List<QuoteLineItem__c>      qliList     {
        get {
            if(this.qliList == null) {
                this.qliList = new List<QuoteLineItem__c>();
            }
            return this.qliList;
        }
        set;
    }
    @AuraEnabled public List<QuoteOtherItem__c>      qoiList     {
        get {
            if(this.qoiList == null) {
                this.qoiList = new List<QuoteOtherItem__c>();
            }
            return this.qoiList;
        }
        set;
    }

    @AuraEnabled public Product2                    product     {
        get {
            if(this.product == null) {
                this.product = new Product2();
            }
            return this.product;
        }
        set;
    }

    @AuraEnabled public List<qliWrapper> qliWpList {get;set;}
    @AuraEnabled public quoteAmtWrapper amtWrapper {
        get {
            if(this.amtWrapper == null) {
                this.amtWrapper = new quoteAmtWrapper();
                this.amtWrapper.totalPrice      = 0;
                this.amtWrapper.discount        = 0;
                this.amtWrapper.discountRate    = 0;
                this.amtWrapper.resultPrice     = 0;
                this.amtWrapper.totalDiscount   = 0;
                this.amtWrapper.totalUnitPrice  = 0;
            }
            return this.amtWrapper;
        }
        set;
    }

    //==============================================================================
    // Inner Class
    //==============================================================================
    public class qliWrapper {
        @AuraEnabled public Product2 prod       {get;set;}
        @AuraEnabled public String qliProductType {
            get {
                if(this.qliProductType == null) {
                    this.qliProductType = this.prod.ProductType__c;
                }
                return this.qliProductType;
            }
            set;
        }
        @AuraEnabled public String   qliName    {
            get {
                if(this.qliName == null) {
                    this.qliName = this.prod.Name;
                }
                return this.qliName;
            }
            set;
        }
        @AuraEnabled public String   option1    {
            get {
                if(this.option1 == null) {
                    this.option1 = this.prod.Option1__c;
                }
                return this.option1;
            }
            private set;
        }
        @AuraEnabled public String   option2    {
            get {
                if(this.option2 == null) {
                    this.option2 = this.prod.Option2__c;
                }
                return this.option2;
            }
            private set;
        }
        @AuraEnabled public String   option3    {
            get {
                if(this.option3 == null) {
                    this.option3 = this.prod.Option3__c;
                }
                return this.option3;
            }
            private set;
        }
        @AuraEnabled public String   option4    {
            get {
                if(this.option4 == null) {
                    this.option4 = this.prod.Option4__c;
                }
                return this.option4;
            }
            private set;
        }
        @AuraEnabled public Decimal   listPrice    {
            get {
                if(this.listPrice == null) {
                    this.listPrice = this.prod.ListPrice__c;
                }
                return this.listPrice;
            }
            private set;
        }
        @AuraEnabled public Decimal   unitPrice    {get;set;}
        @AuraEnabled public Decimal   netPrice     {get;set;}
        @AuraEnabled public Decimal   loanSupport  {get;set;}
        @AuraEnabled public Boolean   isOtherWorkingMachine {
            get {
                return (this.isOtherWorkingMachine == null) ? false : this.isOtherWorkingMachine;
            }
            set;
        }
    }

    public class quoteAmtWrapper {
        // 합계 금액 -> object에 없는 필드.
        @AuraEnabled public Decimal totalPrice          {get;set;}
        // 할인율 -> 수식.
        @AuraEnabled public Decimal discountRate        {get;set;}
        // 차감후 금액 -> 수식.
        @AuraEnabled public Decimal resultPrice         {get;set;}
        // 총 할인 금액
        @AuraEnabled public Decimal totalDiscount       {get;set;}
        // 변동 없는 할인 금액
        @AuraEnabled public Decimal discount            {get;set;}
        // 총 대리점가 합계
        @AuraEnabled public Decimal totalUnitPrice      {get;set;}
    }
}