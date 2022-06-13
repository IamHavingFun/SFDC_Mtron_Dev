@IsTest
private class OrderAutoCancelAlarmLoan_sc_ts {
	@IsTest
	static void testBehavior() {
		OrderAutoCancelAlarmLoan_sc.runSchedule();
		OrderAutoCancelAlarmLoan_sc.abortSchedule();
	}
}