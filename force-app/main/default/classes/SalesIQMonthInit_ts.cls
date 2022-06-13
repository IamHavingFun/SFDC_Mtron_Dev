@IsTest
private class SalesIQMonthInit_ts {
	static testMethod void testBehavior_BA() {
		Test.startTest();
		SalesIQMonthInit_ba.runTest();
		Test.stopTest();
	}

	static testMethod void testBehavior_SC() {
		Test.startTest();
		SalesIQMonthInit_sc.runSchedule();
		SalesIQMonthInit_sc.abortSchedule();
		Test.stopTest();
	}
}