@IsTest
private class OrderAutoCancelAlarm_sc_ts {
	@IsTest
	static void testBehavior() {
		OrderAutoCancelAlarm_sc.runSchedule();
		OrderAutoCancelAlarm_sc.abortSchedule();
	}
}