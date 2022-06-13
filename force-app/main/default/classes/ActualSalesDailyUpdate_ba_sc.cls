/****************************************************************************************
  * @filename      : ActualSalesDailyUpdate_ba_sc
  * @projectname   :
  * @author        : i2max_my.Seo
  * @date          : 2020-08-18 오후 3:30
  * @group         :
  * @group-content :
  * @description   :
  * @tester        : ActualSalesDailyUpdate_ba_sc_ts.cls
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author              description
  * ===============================================================
    0.1     2020-08-18 오후 3:30     i2max_my.Seo           Create
****************************************************************************************/
public class ActualSalesDailyUpdate_ba_sc implements Schedulable {
	// Schedule 등록 배치명
	private static String batchName = '[판매실적] ActualSalesDailyUpdate_ba 매일 11시30분';
	// Schedule Cron Expression (매일 저녁 11시 30분)
	private static String batchCron = '0 30 23 ? * * *';
	// Batch 수행 Size
	private static Integer batchSize = 1;

	/**
	 * 배치 실행 멤버 함수(override)
	 *
	 * @param SC : SchedulableContext
	 */
	public void execute(SchedulableContext SC) {
		ActualSalesDailyUpdate_ba_sc.excuteBatch();
	}

	/**
	 * 배치 Schedule 등록
	 * ActualSalesDailyUpdate_ba_sc.runSchedule();
	 */
	public static void runSchedule() {
		System.schedule(batchName, batchCron, new ActualSalesDailyUpdate_ba_sc());
	}

	/**
	 *  배치 Schedule 삭제
	 *  ActualSalesDailyUpdate_ba_sc.abortSchedule();
	 */
	public static void abortSchedule() {
		for (CronTrigger t : [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = :batchName]) {
			if(!Test.isRunningTest())   System.abortJob(t.Id);
		}
	}

	/**
	 * 배치 실행(외부 바로 호출)
	 * ActualSalesDailyUpdate_ba_sc.excuteBatch();
	 */
	public static void excuteBatch() {
		Database.executeBatch(new ActualSalesDailyUpdate_ba(), batchSize);
	}
}