@IsTest
private class CUPI_tr_ts {
	@IsTest
	static void testBehavior() {
		TestDataBaseFactory.init();

		CUPI__c cupi = new CUPI__c();
		cupi.PromotionFK__c = 'TEST';
		cupi.ConsentedAccount__c = TestDataBaseFactory.personAccount.Id;
		cupi.IsCUPI__c = true;
		cupi.ReceiveSMS__c = true;
		cupi.IsCUPIThirdParty__c = true;
		cupi.ConsentDate__c = Date.Today();
		cupi.NextConsentScheduledDate__c = Date.Today().addYears(2);

		insert cupi;
	}

}