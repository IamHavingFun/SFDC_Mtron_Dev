@IsTest
private class Asset_tr_ts {
	@IsTest
	static void testBehavior() {
		TestDataBaseFactory.init();
		Asset asset = TestDataSalesFactory.baseAsset.clone(false, true);
		asset.Name = '9999999999';
		insert asset;
		try {
			asset.Name = '1234567890';
			update asset;
		} catch (Exception e) {}
	}
}