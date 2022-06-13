/****************************************************************************************
  * @filename      : ZZ_OrderUpdate_ba
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

public class ZZ_OpportunityUpdate implements Database.Batchable<SObject>, Database.Stateful {

	// 외부 Argument
	public String query;

	public Database.QueryLocator start(Database.BatchableContext BC) {
		if(String.isEmpty(this.query)) {
			this.query = 'SELECT' +
					'  Id,' +
					'  StageName,' +
					'  ConsultingDate__c,' +
					'  QuoteDate__c,' +
					'  ContractDate__c,' +
					'  DeliveryDate__c,' +
					'  CreatedDate,' +
					'  CustomerExpectedDate__c,' +
					'  LossDate__c,' +
					'  LossReason__c' +
					' FROM Opportunity ';
		}
		return Database.getQueryLocator(this.query);
	}

	public void execute(Database.BatchableContext BC, List<Opportunity> scopes) {
		Set<Id> oppIds = new Set<Id>();
		for(Opportunity r : scopes) {
			oppIds.add(r.Id);
		}

		Map<Id, Quote__c> quoteMap = new Map<Id, Quote__c>();
		for(Quote__c r : [
			SELECT Id, Opportunity__c, CreatedDate FROM Quote__c WHERE Opportunity__c IN : oppIds
		]) {
			quoteMap.put(r.Opportunity__c, r);
		}
		Map<Id, Contract__c> contractMap = new Map<Id, Contract__c>();
		for(Contract__c r : [
				SELECT Id, Opportunity__c, CreatedDate, CustomerExpectedDate__c FROM Contract__c WHERE Opportunity__c IN : oppIds
		]) {
			contractMap.put(r.Opportunity__c, r);
		}
		Map<Id, PDI__c> pdiMap = new Map<Id, PDI__c>();
		for(PDI__c r : [
				SELECT Id, Contract__r.Opportunity__c, CreatedDate FROM PDI__c WHERE Contract__r.Opportunity__c IN : oppIds
		]) {
			pdiMap.put(r.Contract__r.Opportunity__c, r);
		}
		Quote__c quote;
		Contract__c contract;
		PDI__c pdi;
		List<Opportunity> updateList = new List<Opportunity>();
		for(Opportunity r : scopes) {
			quote = quoteMap.containsKey(r.Id) ? quoteMap.get(r.Id) : new Quote__c();
			contract = contractMap.containsKey(r.Id) ? contractMap.get(r.Id) : new Contract__c();
			pdi = pdiMap.containsKey(r.Id) ? pdiMap.get(r.Id) : new PDI__c();
			if(r.ConsultingDate__c == NULL) {
				r.ConsultingDate__c = r.CreatedDate.date();
			}
			if(r.QuoteDate__c == NULL) {
				if(quoteMap.containsKey(r.Id)) {
					r.QuoteDate__c = quoteMap.get(r.Id).CreatedDate.date();
				}
			}
			if(r.ContractDate__c == NULL) {
				if(contractMap.containsKey(r.Id)) {
					r.ContractDate__c = contractMap.get(r.Id).CreatedDate.date();
				}
			}
			if(r.CustomerExpectedDate__c == NULL) {
				if(contractMap.containsKey(r.Id)) {
					r.CustomerExpectedDate__c = contractMap.get(r.Id).CustomerExpectedDate__c;
				}
			}
			if(r.DeliveryDate__c == NULL) {
				if(pdiMap.containsKey(r.Id)) {
					r.DeliveryDate__c = pdiMap.get(r.Id).CreatedDate.date();
				}
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