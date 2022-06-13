/**
 * Created by ms on 2020-05-06.
 */

@IsTest
private class DealerIncentiveInput_create_sc_ts {
	@IsTest
	static void testBehavior() {
		DealerIncentiveInput_create_sc.runSchedule();
		DealerIncentiveInput_create_sc.abortSchedule();
		DealerIncentiveInput_create_sc.excuteBatch();
	}
}