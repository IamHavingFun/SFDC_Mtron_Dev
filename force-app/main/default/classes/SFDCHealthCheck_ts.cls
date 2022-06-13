@IsTest
private class SFDCHealthCheck_ts {
	@IsTest
	static void testBehavior() {
		SFDCHealthCheck ts = new SFDCHealthCheck();
		System.debug('currentDatetime : ' + ts.currentDatetime);
	}
}