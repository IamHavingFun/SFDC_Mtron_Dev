@IsTest
private class OrderAutoCancelERPSend_sc_ts {
	@IsTest
	static void testBehavior() {
		OrderAutoCancelERPSend_sc.runSchedule();
		OrderAutoCancelERPSend_sc.abortSchedule();
	}
}