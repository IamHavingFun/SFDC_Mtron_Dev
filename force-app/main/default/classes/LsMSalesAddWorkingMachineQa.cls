/****************************************************************************************
  * @filename      : LsMSalesAddWorkingMachineQa
  * @projectname   : 
  * @author        : i2max_my.Seo 
  * @date          : 2020-06-24 오후 5:04
  * @group         : 
  * @group-content : 
  * @description   : 
  * @tester        : LsMSalesAddWorkingMachineQa_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author              description
  * ===============================================================
    0.1     2020-06-24 오후 5:04     i2max_my.Seo           Create
****************************************************************************************/
public with sharing class LsMSalesAddWorkingMachineQa {
    /**
     * @description wrapper class for InitData
     */
    public class InitData extends I2ComClass.InitData {
        @AuraEnabled
        public List<prodWrapperData>         wrapperDataList      {
            get {
                if(this.wrapperDataList == null) {
                    this.wrapperDataList = new List<prodWrapperData>();
                }
                return this.wrapperDataList;
            }
            set;
        }

        @AuraEnabled
        public List<I2ComClass.Option>       prodFeatureOptions   {
            get {
                if(this.prodFeatureOptions == null) {
                    this.prodFeatureOptions = new List<I2ComClass.Option>();
                }

                return this.prodFeatureOptions;
            }
            set;
        }

        @AuraEnabled
        public Map<String, List<I2ComClass.Option>> oemCompanyOptionsByFeature {
            get {
                if(this.oemCompanyOptionsByFeature == null) {
                    this.oemCompanyOptionsByFeature = new Map<String, List<I2ComClass.Option>>();
                }

                return this.oemCompanyOptionsByFeature;
            }
            set;
        }
    }


    /**
     * @description init method
     *
     * @return I2ComClass.InitData
     */
    @AuraEnabled
    public static I2ComClass.InitData init(String prodId) {
        InitData initData = new InitData();

        Set<String> dupCheckSet;

        for(ProductFeature__c pf : [
                SELECT Name,
                (
                        SELECT Id, Feature__r.Name, Product__r.Name,
                                OptionalProduct__r.Name,
                                OptionalProduct__r.BodyAppliedHorsepower__c,
                                OptionalProduct__r.ListPrice__c,
                                OptionalProduct__r.OEMCompany__c,
                                ProductCode__c
                        FROM ProductOptions__r
                        WHERE Product__r.isSalesAvl__c = TRUE
                        ORDER BY OptionalProduct__r.Name
                )
                FROM ProductFeature__c
                WHERE Product__c = :prodId
                ORDER BY Name
        ]) {
            if(pf.ProductOptions__r.size() != 0) {
                initData.wrapperDataList.add(new prodWrapperData(pf));
                initData.prodFeatureOptions.add(new I2ComClass.Option(pf.Name, pf.Name));

                dupCheckSet = new Set<String>();

                for(ProductOption__c po : pf.ProductOptions__r) {

                    if(dupCheckSet.add(po.OptionalProduct__r.OEMCompany__c)) {
                        if (initData.oemCompanyOptionsByFeature.containsKey(po.Feature__r.Name)) {
                            initData.oemCompanyOptionsByFeature.get(po.Feature__r.Name).add(new I2ComClass.Option(po.OptionalProduct__r.OEMCompany__c, po.OptionalProduct__r.OEMCompany__c));
                        } else {
                            initData.oemCompanyOptionsByFeature.put(po.Feature__r.Name, new List<I2ComClass.Option>{
                                    new I2ComClass.Option(po.OptionalProduct__r.OEMCompany__c, po.OptionalProduct__r.OEMCompany__c)
                            });
                        }
                    }
                }
            }
        }

        return initData;
    }

    @AuraEnabled
    public static LsMSalesQuoteData getQliDataForQuote(LsMSalesQuoteData quoteWrapper, String prodId) {
        Boolean isNotAdded = true;
        Product2 prod = LsMSalesQCService.getProduct2ById(prodId);

        ProductPrice__c productPrice = LsMSalesQCService.getProductPrice(prodId);

        LsMSalesQCService.checkWorkingMachine(quoteWrapper.qliList, prod);

        quoteWrapper.qliList.add(
                new QuoteLineItem__c(
                        Product__c          = prod.Id,
                        Product__r          = prod,
                        Quantity__c         = 1,
                        ListPrice__c        = prod.ListPrice__c,
                        NetPrice__c         = (productPrice != null) ? productPrice.DealerSupplyAmt__c : prod.ListPrice__c,
                        UnitPrice__c        = (productPrice != null) ? productPrice.DealerSupplyAmt__c : prod.ListPrice__c,
                        TotalPrice__c       = (productPrice != null) ? productPrice.DealerSupplyAmt__c : prod.ListPrice__c,
                        Type__c             = prod.Type__c,
                        AdditionalDisc__c   = 0,
                        LoanLimitAmt__c     = (prod.LoanSupportLimit__c != null) ? prod.LoanSupportLimit__c : 0
                )
        );

        quoteWrapper.amtWrapper.totalPrice      = LsMSalesQCService.sumTotalPrice(quoteWrapper.qliList);

        //==============================================================================
        // 작업기를 삭제 후 다시 추가 시에, 기존 값이 더해지므로,
        // 초기화 후, List를 돌려 다시 다 더해준다.
        //==============================================================================
        quoteWrapper.amtWrapper.totalUnitPrice = 0;

        for(QuoteLineItem__c qli : quoteWrapper.qliList) {
            quoteWrapper.amtWrapper.totalUnitPrice  += qli.UnitPrice__c;
        }

        for(QuoteOtherItem__c qoi : quoteWrapper.qoiList) {
            quoteWrapper.amtWrapper.totalPrice += qoi.NetPrice__c;
            quoteWrapper.amtWrapper.totalUnitPrice += qoi.NetPrice__c;
        }

        quoteWrapper.amtWrapper.discountRate    = LsMSalesQCService.calculateDiscountRate(quoteWrapper.amtWrapper.totalDiscount, quoteWrapper.amtWrapper.totalUnitPrice);

        LsMSalesQuoteData.qliWrapper qw = new LsMSalesQuoteData.qliWrapper();
        qw.prod = prod;
        qw.unitPrice = qw.netPrice =  (productPrice != null) ? productPrice.DealerSupplyAmt__c : prod.ListPrice__c;
        qw.loanSupport  = (prod.LoanSupportLimit__c != null) ? prod.LoanSupportLimit__c : 0;

        for(Integer i = 0 ; i < quoteWrapper.qliWpList.size() ; i++) {
            if(quoteWrapper.qliWpList[i].qliProductType.equals('기타 작업기')) {
                quoteWrapper.qliWpList.add(i, qw);
                isNotAdded = false;
                break;
            }
        }

        //보여 주기 용 wrapperData 구성.
        if(isNotAdded)    quoteWrapper.qliWpList.add(qw);

        return quoteWrapper;
    }

    public class prodWrapperData {
        @AuraEnabled public ProductFeature__c prodFeature         {get;set;}
        @AuraEnabled public List<ProductOption__c> prodOptionList {
            get {
                if(this.prodOptionList == null) {
                    this.prodOptionList = this.prodFeature.ProductOptions__r;
                }
                return this.prodOptionList;
            }
            set;
        }

        public prodWrapperData(ProductFeature__c productFeature) {
            this.prodFeature = productFeature;
        }
    }
}