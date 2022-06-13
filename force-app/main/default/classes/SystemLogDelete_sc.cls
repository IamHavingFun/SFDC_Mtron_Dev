/****************************************************************************************
 * @filename      : SystemLogDelete_sc
 * @projectname   :
 * @author        : I2max
 * @date          : 2020-08-18 오후 4:48
 * @group         :
 * @group-content :
 * @description   : 로그 삭제 스케쥴 : 매일 0:10
 * @tester        :
 * @reference     :
 * @copyright     : Copyright © I2max. All Rights Reserved.
 * @modification Log
 * ===============================================================
 * ver     date                     author              description
 * ===============================================================
 0.1     2020-08-18 오후 4:48        SEOKHO LEE          Create
 ****************************************************************************************/

public class SystemLogDelete_sc implements Schedulable {
	// Schedule 등록 배치명
	private static String batchName = '[로그관리] 3일지난 로그 삭제';
	// Schedule Cron Expression (매일 새벽 6시)
	private static String batchCron = '0 10 0 * * ? *';
	// Batch 수행 Size
	private static Integer batchSize = 100;

	/**
	 * 배치 실행 멤버 함수(override)
	 *
	 * @param SC : SchedulableContext
	 */
	public void execute(SchedulableContext SC) {
		SystemLogDelete_sc.excuteBatch();
	}

	/**
	 * 배치 Schedule 등록
	 */
	public static void runSchedule() {
		System.schedule(batchName, batchCron, new SystemLogDelete_sc());
	}

	/**
	 *  배치 Schedule 삭제
	 */
	public static void abortSchedule() {
		for (CronTrigger t : [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = :batchName]) {
			if(!Test.isRunningTest())   System.abortJob(t.Id);
		}
	}

	/**
	 * 배치 실행(외부 바로 호출)
	 */
	public static void excuteBatch() {
		Database.executeBatch(new SystemLogDelete_ba(), batchSize);
	}
}