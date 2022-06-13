/****************************************************************************************
  * @filename      : GuideActionOpportunityActivityCheck_sc
  * @projectname   :
  * @author        : i2max
  * @date          : 2020-05-29
  * @group         :
  * @group-content :
  * @description   :
  * @tester        : GuideActionOpportunityActivityCheck_sc_sc_ts.cls
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2020-05-29         i2max          Create
****************************************************************************************/

public class GuideActionOpportunityActivityCheck_sc implements Schedulable {
	// Schedule 등록 배치명
	private static String batchName = '[가이드액션] 판매기회_활동_90일마감_견적체크';
	// Schedule Cron Expression (매일  9시 00분)
	private static String batchCron = '0 0 9 * * ? *';
	// Batch 수행 Size
	private static Integer batchSize = 1;

	/**
	 * 배치 실행 멤버 함수(override)
	 *
	 * @param SC : SchedulableContext
	 */
	public void execute(SchedulableContext SC) {
		GuideActionOpportunityActivityCheck_sc.excuteBatch();
	}

	/**
	 * 배치 Schedule 등록
	 * GuideActionOpportunityActivityCheck_sc.runSchedule();
	 */
	public static void runSchedule() {
		System.schedule(batchName, batchCron, new GuideActionOpportunityActivityCheck_sc());
	}

	/**
	 *  배치 Schedule 삭제
	 *  GuideActionOpportunityActivityCheck_sc.abortSchedule();
	 */
	public static void abortSchedule() {
		for (CronTrigger t : [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = :batchName]) {
			if(!Test.isRunningTest())   System.abortJob(t.Id);
		}
	}

	/**
	 * 배치 실행(외부 바로 호출)
	 * GuideActionOpportunityActivityCheck_sc.excuteBatch();
	 */
	public static void excuteBatch() {
		Database.executeBatch(new GuideActionOpportunityActivityCheck_ba(), batchSize);
	}
}