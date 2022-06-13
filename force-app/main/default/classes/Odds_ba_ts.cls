@IsTest
private class Odds_ba_ts {
	@IsTest
	static void testBehavior() {
		TestDataProductFactory.init();

		Account account = TestDataBaseFactory.agencyAccount.clone(false, true);
		account.BusinessOffice__c = TestDataBaseFactory.businessOfficeAccount.Id;

		insert account;

		Opportunity opportunity = TestDataSalesFactory.baseOpportunity.clone(false, true);
		opportunity.Dealer__c = account.Id;

		Opportunity opportunity2 = opportunity.clone(false, true);
		opportunity2.StageName = opportunity2.SystemStatus__c = '실주';
		opportunity2.LossReason__c = '실패...';

		insert new List<Opportunity>{
			opportunity, opportunity2
		};

		Database.executeBatch(new Odds_ba(), 1);
	}
}