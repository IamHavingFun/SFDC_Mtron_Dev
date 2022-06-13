@IsTest
private class GuideActionDealerStockLevelExceed_sc_ts {
	@IsTest
	static void testBehavior() {
		GuideActionDealerStockLevelExceed_sc.runSchedule();
		GuideActionDealerStockLevelExceed_sc.abortSchedule();
	}
}