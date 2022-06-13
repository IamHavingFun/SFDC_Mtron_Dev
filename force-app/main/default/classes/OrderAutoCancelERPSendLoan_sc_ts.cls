@IsTest
private class OrderAutoCancelERPSendLoan_sc_ts {
	@IsTest
	static void testBehavior() {
		OrderAutoCancelERPSendLoan_sc.runSchedule();
		OrderAutoCancelERPSendLoan_sc.abortSchedule();
	}
}