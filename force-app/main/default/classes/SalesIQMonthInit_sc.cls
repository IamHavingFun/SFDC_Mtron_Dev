/****************************************************************************************
  * @filename      : SalesIQMonthInit_ts
  * @projectname   :
  * @author        : i2max
  * @date          : 2020-04-23
  * @group         :
  * @group-content :
  * @description   :
  * @tester        : SalesIQMonthInit_ts.cls
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2020-04-23         i2max          Create
****************************************************************************************/
public class SalesIQMonthInit_sc implements Schedulable {
	// Schedule 등록 배치명
	private static String batchName = 'Sales IQ 초기화 처리 - 매월1일 0시 10분';
	// Schedule Cron Expression (매월1일 0시 10분)
	private static String batchCron = '0 10 0 1 * ? *';
	// Batch 수행 Size
	private static Integer batchSize = 200;

	/**
	 * 배치 실행 멤버 함수(override)
	 *
	 * @param SC : SchedulableContext
	 */
	public void execute(SchedulableContext SC) {
		SalesIQMonthInit_sc.excuteBatch();
	}

	/**
	 * 배치 Schedule 등록
	 * Dummy_IF_KR_ERP_SE_0001_sc.runSchedule();
	 */
	public static void runSchedule() {
		System.schedule(batchName, batchCron, new SalesIQMonthInit_sc());
	}

	/**
	 *  배치 Schedule 삭제
	 *  SalesIQMonthInit_sc.abortSchedule();
	 */
	public static void abortSchedule() {
		for (CronTrigger t : [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = :batchName]) {
			if(!Test.isRunningTest())   System.abortJob(t.Id);
		}
	}

	/**
	 * 배치 실행(외부 바로 호출)
	 * SalesIQMonthInit_sc.excuteBatch();
	 */
	public static void excuteBatch() {
		Database.executeBatch(new SalesIQMonthInit_ba(), batchSize);
	}

}