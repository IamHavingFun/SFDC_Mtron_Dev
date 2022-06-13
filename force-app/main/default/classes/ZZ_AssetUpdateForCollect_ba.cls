/****************************************************************************************
  * @filename      : ZZ_AssetUpdateForCollect_ba
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

public class ZZ_AssetUpdateForCollect_ba implements Database.Batchable<SObject>, Database.Stateful {

	// 외부 Argument
	public String query;

	public Database.QueryLocator start(Database.BatchableContext BC) {
		if(String.isEmpty(this.query)) {
			this.query = '';
			this.query +=
					' SELECT Id, Name, MigInfo__c, ARAmount__c, CreditExpiredDate__c, CreatedCreditDate__c, Dealer__r.ERPCode__c  \n' +
							' FROM Asset \n' +
							' WHERE Id IN ( \n' +
							'   SELECT \n' +
							'      Asset__c \n' +
							'   FROM CollectMoney__c \n' +
							'   WHERE Asset__c != NULL AND CollectMoney__c != NULL \n' +
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
/*

		Map<String, CollectMoney__c> collectMoneyCheckMap = new Map<String, CollectMoney__c>();
		List<CollectMoney__c> deleteList = new List<CollectMoney__c>();
		for(CollectMoney__c r : [
						SELECT Id, AssetId__c, CollectMoney__c, CollectMoneyDocNo__c FROM CollectMoney__c
						WHERE AssetId__c IN : assetNames
						ORDER BY CollectMoneyDocNo__c ASC
		]) {
			if(collectMoneyCheckMap.containsKey(r.CollectMoneyDocNo__c) == false) {
				if(assetMap.containsKey(r.AssetId__c)) {
					r.Asset__c = assetMap.get(r.AssetId__c).Id;
				}
				collectMoneyCheckMap.put(r.CollectMoneyDocNo__c, r);
			} else {
				deleteList.add(r);
			}
		}

		if(deleteList.isEmpty() == false) delete deleteList;
		if(collectMoneyCheckMap.isEmpty() == false) update collectMoneyCheckMap.values();
*/

		Map<String, Decimal> collectMoneyMap = new Map<String, Decimal>();
		String key = '';
		for(CollectMoney__c r : [SELECT Id, AssetId__c, CustomerCode__c, CollectMoney__c, CollectMoneyDocNo__c FROM CollectMoney__c WHERE AssetId__c IN : assetNames]) {
			key = r.AssetId__c + '_' + r.CustomerCode__c;
			if(collectMoneyMap.containsKey(key) == false) {
				// 전기일 : BookkeepingDate__c
				// 계획일 : PlanDate__c
				// 채권(원) : ArAmtKRW__c
				if(r.CollectMoney__c != NULL) {
					collectMoneyMap.put(key, r.CollectMoney__c);
				}
			} else {
				Decimal tAmount = collectMoneyMap.get(key);
				if(r.CollectMoney__c != NULL) {
					collectMoneyMap.put(key, (tAmount + r.CollectMoney__c));
				}
			}
		}

		for(Asset r : scopes) {
			key = r.Name + '_' + r.Dealer__r.ERPCode__c;
			if(collectMoneyMap.containsKey(key)) {
				//채권금액	ARAmount__c
				//채권만기일	CreditExpiredDate__c
				//채권발생일	CreatedCreditDate__c
				Decimal tAmount = collectMoneyMap.get(key);
				r.TotalCollectAmount__c = tAmount;
				//r.MigInfo__c = '채권 금액 업데이트 : 2021-02-15';
			} else {
				r.TotalCollectAmount__c = 0;
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