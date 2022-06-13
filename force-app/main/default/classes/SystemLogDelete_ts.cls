/****************************************************************************************
 * @filename      : SystemLogDelete_ts
 * @projectname   :
 * @author        : I2max
 * @date          : 2020-08-18 오후 5:16
 * @group         :
 * @group-content :
 * @description   : 로그 삭제 스케쥴,배치 테스트 케이스
 * @tester        :
 * @reference     :
 * @copyright     : Copyright © I2max. All Rights Reserved.
 * @modification Log
 * ===============================================================
 * ver     date                     author              description
 * ===============================================================
 0.1     2020-08-18 오후 5:16        SEOKHO LEE          Create
 ****************************************************************************************/

@isTest
private class SystemLogDelete_ts {
	@isTest
	static void testBatch() {
		SystemLogDelete_ba ba = new SystemLogDelete_ba();
		Database.executeBatch(ba, 1);
		try {
			String logId = 'logId';
			SystemLogDelete_ba.callWebService(logId);
		} catch (Exception e) {}
	}
	@isTest
	static void testSchedule() {
		SystemLogDelete_sc.runSchedule();
		SystemLogDelete_sc.abortSchedule();
	}
}