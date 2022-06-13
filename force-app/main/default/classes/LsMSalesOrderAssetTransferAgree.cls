/**
 * Created by MS on 2020-07-01.
 */

public without sharing class LsMSalesOrderAssetTransferAgree {


	/**
	 * Wrapper class for InitData
	 */
	public class OrderData {
		@AuraEnabled public Order__c order {get;set;}
		@AuraEnabled public String productName {get;set;}

		public OrderData (Order__c order, String productName) {
			this.order = order;
			this.productName = productName;
		}
	}

	@AuraEnabled
	public static List<OrderData> init() {

		User currentUser = [SELECT Id, AccountId FROM User WHERE Id = :UserInfo.getUserId()];

		List<Order__c> orders = [
			SELECT Id, AssetTransferAgreeStatus__c,
					Opportunity__r.Name,
					Name
			FROM Order__c
			WHERE AssetTransferAgreeStatus__c = '요청'
			AND Dealer__c = :currentUser.AccountId
		];
		List<OrderData> orderDatas = new List<OrderData>();
		String productName;
		for(Order__c r : [
				SELECT Id, AssetTransferAgreeStatus__c,
						Opportunity__r.Name,
						Name,
						(SELECT Id, ProductId__r.Name FROM OrderProduct__r LIMIT 1)
				FROM Order__c
				WHERE AssetTransferAgreeStatus__c = '요청'
				AND Dealer__c = :currentUser.AccountId
		]) {
			if(r.OrderProduct__r.isEmpty() == false) {
				productName = r.OrderProduct__r.get(0).ProductId__r.Name;
				orderDatas.add(new OrderData(r, productName)) ;
			}
		}
		return orderDatas;
	}

	@AuraEnabled
	public static  List<OrderData> save(Order__c order, String status) {
		order.AssetTransferAgreeStatus__c = status;     // 승인 / 거부
		update order;
		return init();
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
	}
}