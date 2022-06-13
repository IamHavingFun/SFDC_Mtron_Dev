/**
 * Created by ms on 2020-05-06.
 */

@IsTest
private class PartnerIncentiveApproval_sc_ts {
	@IsTest
	static void testBehavior() {
		PartnerIncentiveApproval_sc.runSchedule();
		PartnerIncentiveApproval_sc.abortSchedule();
		PartnerIncentiveApproval_sc.excuteBatch();
	}
}