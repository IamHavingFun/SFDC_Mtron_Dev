/****************************************************************************************
  * @filename      : SalesIQCalculator_sc
  * @projectname   :
  * @author        : i2max
  * @date          : 2020-04-23
  * @group         :
  * @group-content :
  * @description   :
  * @tester        : SalesIQCalculator_ts.cls
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2020-04-23         i2max          Create
****************************************************************************************/
public class SalesIQCalculator_sc implements Schedulable {
	// Schedule 등록 배치명
	private static String batchName = 'Sales IQ 산출 처리 - 매일 23시 30분';
	// Schedule Cron Expression (매일 23시 30분)
	private static String batchCron = '0 30 23 * * ? *';
	// Batch 수행 Size
	private static Integer batchSize = 1;

	/**
	 * 배치 실행 멤버 함수(override)
	 *
	 * @param SC : SchedulableContext
	 */
	public void execute(SchedulableContext SC) {
		SalesIQCalculator_sc.excuteBatch();
	}

	/**
	 * 배치 Schedule 등록
	 * SalesIQCalculator_sc.runSchedule();
	 */
	public static void runSchedule() {
		System.schedule(batchName, batchCron, new SalesIQCalculator_sc());
	}

	/**
	 *  배치 Schedule 삭제
	 *  SalesIQCalculator_sc.abortSchedule();
	 */
	public static void abortSchedule() {
		for (CronTrigger t : [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = :batchName]) {
			if(!Test.isRunningTest())   System.abortJob(t.Id);
		}
	}

	/**
	 * 배치 실행(외부 바로 호출)
	 * SalesIQCalculator_sc.excuteBatch();
	 */
	public static void excuteBatch() {
		Database.executeBatch(new SalesIQCalculator_ba(), batchSize);
	}

}