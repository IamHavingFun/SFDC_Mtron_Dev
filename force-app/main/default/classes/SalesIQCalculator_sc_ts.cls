@IsTest
private class SalesIQCalculator_sc_ts {
	static testMethod void testBehavior_SC() {
		Test.startTest();
		SalesIQCalculator_sc.runSchedule();
		SalesIQCalculator_sc.abortSchedule();
		SalesIQCalculator_sc.excuteBatch();
		Test.stopTest();
	}
}