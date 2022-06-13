/**
 * Created by ms on 2020-05-06.
 */

@IsTest
private class DealerIncentiveCalculate_sc_ts {
	@IsTest
	static void testBehavior() {
		DealerIncentiveCalculate_sc.runSchedule();
		DealerIncentiveCalculate_sc.abortSchedule();
		DealerIncentiveCalculate_sc.excuteBatch();
	}

}