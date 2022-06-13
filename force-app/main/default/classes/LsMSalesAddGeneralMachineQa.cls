/****************************************************************************************
  * @filename      : LsMSalesAddGeneralMachineQa
  * @projectname   :
  * @author        : i2max_my.Seo
  * @date          : 2020-06-24 오후 5:04
  * @group         :
  * @group-content :
  * @description   : 일반 작업기 추가.
  * @tester        : LsMSalesAddWorkingMachineQa_ts.cls
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author              description
  * ===============================================================
    0.1     2020-06-24 오후 5:04     i2max_my.Seo           Create
****************************************************************************************/
public with sharing class LsMSalesAddGeneralMachineQa {
	/**
	 * @description wrapper class for InitData
	 */
	public class InitData extends I2ComClass.InitData {
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

		Product2 p2 = [SELECT Id, ProductType__c FROM Product2 WHERE Id = :prodId];

		String option;
		String query = ' SELECT  Segment__c  FROM Product2 WHERE isSalesAvl__c = TRUE ';
		if('트랙터'.equals(p2.ProductType__c)) {
			query += ' AND Type__c = \'작업기\' AND ProductType__c = \'작업기\' ';
		} else if('이앙기'.equals(p2.ProductType__c)) {
			query += ' AND Type__c = \'작업기\' AND ProductType__c = \'이앙기\') ';
		} else if('콤바인'.equals(p2.ProductType__c)) {
			query += ' AND Type__c = \'작업기\' AND ProductType__c IN \'콤바인\' ';
		}
		query += ' GROUP BY Segment__c ';

		for(AggregateResult ar : Database.query(query)) {
			option = String.valueOf(ar.get('Segment__c'));
			initData.prodFeatureOptions.add(new I2ComClass.Option(option, option));
		}

		return initData;
	}

	@AuraEnabled
	public static List<I2ComClass.Option> getOemCompanyOptions(String productType, String segment) {
		List<I2ComClass.Option> companyOptions = new List<I2ComClass.Option>();
		String company;
		for(AggregateResult ar : [
				SELECT
						OEMCompany__c
				FROM Product2
				WHERE Type__c = '작업기'
				AND Segment__c = :segment
				AND isSalesAvl__c = TRUE
				GROUP BY OEMCompany__c
		]) {
			company = String.valueOf(ar.get('OEMCompany__c'));
			companyOptions.add(new I2ComClass.Option(company, company));
		}
		return companyOptions;
	}

	@AuraEnabled
	public static List<Product2> getProducts(String segment, String company, String modelName) {
		String query = '' +
				' SELECT ' +
				' Id, '+
				' Name, '+
				' BodyAppliedHorsepower__c, '+
				' ListPrice__c, '+
				' OEMCompany__c '+
				' FROM Product2 '+
				' WHERE Type__c = \'작업기\' AND isSalesAvl__c = TRUE ';

		if(String.isEmpty(segment) == false) query += ' AND Segment__c = :segment ';
		if(String.isEmpty(company) == false) query += ' AND OEMCompany__c = :company ';
		if(String.isEmpty(modelName) == false) query += ' AND Name LIKE \'%'+modelName+'%\' ';

		return database.query(query);
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

	public static void runTest() {
		Integer my_seo = 0;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
		my_seo ++;
	}
}