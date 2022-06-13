/**
 * Created by ms on 2020-05-06.
 */

@IsTest
private class DealerIncentiveInput_approval_sc_ts {
	@IsTest
	static void testBehavior() {
		DealerIncentiveInput_approval_sc.runSchedule();
		DealerIncentiveInput_approval_sc.abortSchedule();
		DealerIncentiveInput_approval_sc.excuteBatch();
	}
}