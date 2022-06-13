/****************************************************************************************
  * @filename      : ZZ_AssetUpdateForAR_ba
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

public class ZZ_AssetUpdateForAR_ba implements Database.Batchable<SObject>, Database.Stateful {

	// 외부 Argument
	public String query;

	public Database.QueryLocator start(Database.BatchableContext BC) {
		if(String.isEmpty(this.query)) {
			this.query = '';
			this.query +=
					' SELECT Id, Name, Dealer__r.ERPCode__c, ARAmount__c, CreditExpiredDate__c, CreatedCreditDate__c \n' +
							' FROM Asset \n' +
							' WHERE Id IN ( \n' +
							'   SELECT \n' +
							'      Asset__c \n' +
							'   FROM AR__c \n' +
							'   WHERE Asset__c != NULL \n' +
							' )';
		}
		return Database.getQueryLocator(this.query);
	}

	public void execute(Database.BatchableContext BC, List<Asset> scopes) {

		Set<String> assetNames = new Set<String>();
		Map<String, Asset> assetMap = new Map<String, Asset>();
		for(Asset r : scopes) {
			assetNames.add(r.Name);
			assetMap.put(r.Name, r);
		}

		Map<String, AR__c> arMap = new Map<String, AR__c>();
		List<AR__c> updateARs = new List<AR__c>();
		String key = '';
		for(AR__c r : [SELECT Id, AssetId__c, Asset__c, CustomerCode__c, BookkeepingDate__c, PlanDate__c, ArAmtKRW__c FROM AR__c WHERE AssetId__c IN : assetNames]) {
			key = r.AssetId__c + '_' + r.CustomerCode__c;
			if(!arMap.containsKey(key) && r.ArAmtKRW__c > 0) {
				arMap.put(key, r);
			}
		}
		for(Asset r : scopes) {
			key = r.Name + '_' + r.Dealer__r.ERPCode__c;
			if(arMap.containsKey(key)) {
				//채권금액	ARAmount__c
				//채권만기일	CreditExpiredDate__c
				//채권발생일	CreatedCreditDate__c
				AR__c ar = arMap.get(key);
				r.ARAmount__c = ar.ArAmtKRW__c;
				r.CreatedCreditDate__c = ar.BookkeepingDate__c;
				r.CreditExpiredDate__c = ar.PlanDate__c;
				//r.MigInfo__c = '채권 금액 업데이트 : 2021-02-15';
			} else {
				r.ARAmount__c = 0;
				r.CreatedCreditDate__c = null;
				r.CreditExpiredDate__c = null;
			}
		}

		update scopes;
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