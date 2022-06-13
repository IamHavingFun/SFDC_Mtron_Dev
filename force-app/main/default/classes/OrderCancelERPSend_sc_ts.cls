@IsTest
private class OrderCancelERPSend_sc_ts {
	@IsTest
	static void testBehavior() {
		OrderCancelERPSend_sc.runSchedule();
		OrderCancelERPSend_sc.abortSchedule();
	}
}