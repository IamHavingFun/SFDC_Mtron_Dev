/**
 * Created by ms on 2020-05-06.
 */

@IsTest
private class DealerIncentiveERPSend_sc_ts {
	@IsTest
	static void testBehavior() {
		DealerIncentiveERPSend_sc.runSchedule();
		DealerIncentiveERPSend_sc.abortSchedule();
		DealerIncentiveERPSend_sc.excuteBatch();
	}

}