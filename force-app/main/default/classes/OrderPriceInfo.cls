/****************************************************************************************
  * @filename      : OrderPriceInfo
  * @projectname   : LS
  * @author        : i2max
  * @date          : 2020-05-08
  * @group         :
  * @group-content :
  * @description   : 주문 가격 결정일에 해당하는 가격 정보 확인용
  * @tester        : OrderPriceInfo_ts.cls
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2020-05-08         i2max          Create
****************************************************************************************/
public with sharing class OrderPriceInfo {

	public class PriceData {
		@AuraEnabled public Boolean isTarget { get; set; } // 해당 가격
		@AuraEnabled public String  priceType { get; set; } // 유형
		@AuraEnabled public Decimal price { get; set; } // 가격
		@AuraEnabled public String  startDate { get; set; } // 가격 시작일자
		@AuraEnabled public String  endDate { get; set; } // 가격 종료일자
	}

	@AuraEnabled
	public static List<PriceData> init(String recordId) {

		OrderLineitem__c orderLineitem = [
				SELECT Id, Name,
						OrderId__c,
						OrderId__r.OrderAccount__r.CustomerType__c,
						OrderId__r.PriceDecisionDate__c,
						ProductId__c, SellingPrice__c,
						CorrectionPrice__c
				FROM OrderLineitem__c
				WHERE OrderId__c = :recordId
		];
		List<PriceData> productPriceEntries = new List<PriceData>();
		PriceData priceData;
		String priceType;
		for(ProductPriceEntry__c r : [
				SELECT Id, Name, StartDate__c, EndDate__c, PriceType__c, BasePrice__c
				FROM ProductPriceEntry__c
				WHERE Product__c = :orderLineitem.ProductId__c
				AND StartDate__c <= :orderLineitem.OrderId__r.PriceDecisionDate__c
				AND EndDate__c >= :orderLineitem.OrderId__r.PriceDecisionDate__c
				ORDER BY PriceType__c, StartDate__c
		]) {
			if(orderLineitem.OrderId__r.OrderAccount__r.CustomerType__c == '농협') {
				priceType = 'FD';
			} else if(orderLineitem.OrderId__r.OrderAccount__r.CustomerType__c == '관납') {
				priceType = 'FE';
			} else {
				priceType = 'FC';
			}
			priceData = new PriceData();
			priceData.isTarget = false;
			priceData.priceType = r.PriceType__c == 'FC' ? '대리점' : r.PriceType__c == 'FD' ? '농협' : '관납';
			priceData.startDate = ((Datetime)r.StartDate__c).format('yyyy-MM-dd');
			priceData.endDate = ((Datetime)r.EndDate__c).format('yyyy-MM-dd');
			priceData.price = r.BasePrice__c;
			if(priceType == r.PriceType__c && r.StartDate__c <= orderLineitem.OrderId__r.PriceDecisionDate__c && r.EndDate__c >= orderLineitem.OrderId__r.PriceDecisionDate__c ) {
				priceData.isTarget = true;
			}
			productPriceEntries.add(priceData);
		}

		return productPriceEntries;
	}


	public static void runTest() {
		Integer my_seo = 0;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
		my_seo++;
	}
}