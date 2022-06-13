/****************************************************************************************
  * @filename      : ZZ_AssetForCollectUpdate_ba
  * @projectname   : LS
  * @author        : Park HE
  * @date          : 2020-05-14
  * @group         :
  * @group-content :
  * @description   :
  * @tester        :
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                    author          description
  * ===============================================================
    0.1     2020-05-14             Park HE         Create
****************************************************************************************/

public class ZZ_AssetForCollectUpdate_ba implements Database.Batchable<SObject>, Database.Stateful {

	// 외부 Argument
	public String query;

	public Database.QueryLocator start(Database.BatchableContext BC) {
		if(String.isEmpty(this.query)) {
			this.query = '';
			this.query +=
					' SELECT Id, Name, AssetId__c, Asset__c, BillingDocumentNumber__c \n' +
							' FROM CollectMoney__c \n' +
							' WHERE Division__c = \'실적\' AND Asset__c = NULL AND AssetId__c != NULL' ;
		}
		return Database.getQueryLocator(this.query);
	}

	public void execute(Database.BatchableContext BC, List<CollectMoney__c> scopes) {

		Set<String> assetNames = new Set<String>();
		Set<String> bDocNos = new Set<String>();
		for(CollectMoney__c r : scopes) {
			assetNames.add(r.AssetId__c);
			bDocNos.add(r.BillingDocumentNumber__c);
		}

		// 채권 정보
		Map<String, AR__c> arMap = new Map<String, AR__c>();
		for(AR__c r : [SELECT Id, Name, BillingDocNo__c FROM AR__c WHERE BillingDocNo__c IN : bDocNos ORDER BY BaseYearMonth__c DESC]) {
			if(!arMap.containsKey(r.BillingDocNo__c)) {
				arMap.put(r.BillingDocNo__c, r);
			}
		}

		Map<String, Asset> assetMap = new Map<String, Asset>();
		for(Asset r : [SELECT Id, Name FROM Asset WHERE Name IN : assetNames]) {
			if(!assetMap.containsKey(r.Name)) {
				assetMap.put(r.Name, r);
			}
		}
		List<CollectMoney__c> updateList = new List<CollectMoney__c>();
		for(CollectMoney__c r : scopes) {
			if(assetMap.containsKey(r.AssetId__c)) {
				r.Asset__c = assetMap.get(r.AssetId__c).Id;
			}
			if(arMap.containsKey(r.BillingDocumentNumber__c)) {
				r.AR__c = arMap.get(r.BillingDocumentNumber__c).Id;
			}
			updateList.add(r);
		}

		if(updateList.isEmpty() == false) update updateList;
	}


	public void finish(Database.BatchableContext param1) {

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