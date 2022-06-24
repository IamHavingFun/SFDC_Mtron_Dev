@IsTest
private class Asset_tr_ts {
	@IsTest
	static void testBehavior() {
		TestDataBaseFactory.init();
		Asset asset = TestDataSalesFactory.baseAsset.clone(false, false);
		asset.Name = '9999999911';
		asset.BatchNo__c = '9999999911';
		insert asset;
		try {
			asset.Name = '1234567891';
			asset.BatchNo__c = '1234567891';
			update asset;
		} catch (Exception e) {}
	}
}