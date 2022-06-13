/****************************************************************************************
  * @filename      : GuideActionBondCheck_sc
  * @projectname   :
  * @author        : i2max
  * @date          : 2020-05-29
  * @group         :
  * @group-content :
  * @description   : 채권/채무 확인 준비(매월 4일 6시)
  * @tester        : GuideActionBondCheck_sc_ts.cls
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2020-05-29         i2max          Create
****************************************************************************************/

public class GuideActionBondCheck_sc implements Schedulable {
	// Schedule 등록 배치명
	private static String batchName = '[가이드액션] 채권확인_채권/채무 확인 알림';
	// Schedule Cron Expression (매월 4일 새벽 6시)
	private static String batchCron = '0 0 6 4 * ? *';
	// Batch 수행 Size
	private static Integer batchSize = 200;

	/**
	 * 배치 실행 멤버 함수(override)
	 *
	 * @param SC : SchedulableContext
	 */
	public void execute(SchedulableContext SC) {
		GuideActionBondCheck_sc.excuteBatch();
	}

	/**
	 * 배치 Schedule 등록
	 * GuideActionBondCheck_sc.runSchedule();
	 */
	public static void runSchedule() {
		System.schedule(batchName, batchCron, new GuideActionBondCheck_sc());
	}

	/**
	 *  배치 Schedule 삭제
	 *  GuideActionBondCheck_sc.abortSchedule();
	 */
	public static void abortSchedule() {
		for (CronTrigger t : [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = :batchName]) {
			if(!Test.isRunningTest())   System.abortJob(t.Id);
		}
	}

	/**
	 * 배치 실행(외부 바로 호출)
	 * GuideActionBondCheck_sc.excuteBatch();
	 */
	public static void excuteBatch() {
		Database.executeBatch(new GuideActionBondCheck_ba(), batchSize);
	}
}