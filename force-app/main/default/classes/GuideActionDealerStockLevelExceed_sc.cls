/****************************************************************************************
  * @filename      : GuideActionDealerStockLevelExceed_sc
  * @projectname   :
  * @author        : i2max
  * @date          : 2020-05-29
  * @group         :
  * @group-content :
  * @description   :
  * @tester        : GuideActionDealerStockLevelExceed_sc_ts.cls
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2020-05-29         i2max          Create
****************************************************************************************/

public class GuideActionDealerStockLevelExceed_sc implements Schedulable {
	// Schedule 등록 배치명
	private static String batchName = '[가이드액션] 적정유통재고 초과 알림(매주/월/9시)';
	// Schedule Cron Expression (매주 월 9시)
	private static String batchCron = '0 0 9 ? * 2 *';
	// Batch 수행 Size
	private static Integer batchSize = 1;

	/**
	 * 배치 실행 멤버 함수(override)
	 *
	 * @param SC : SchedulableContext
	 */
	public void execute(SchedulableContext SC) {
		GuideActionDealerStockLevelExceed_sc.excuteBatch();
	}

	/**
	 * 배치 Schedule 등록
	 * GuideActionDealerStockLevelExceed_sc.runSchedule();
	 */
	public static void runSchedule() {
		System.schedule(batchName, batchCron, new GuideActionDealerStockLevelExceed_sc());
	}

	/**
	 *  배치 Schedule 삭제
	 *  GuideActionDealerStockLevelExceed_sc.abortSchedule();
	 */
	public static void abortSchedule() {
		for (CronTrigger t : [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = :batchName]) {
			if(!Test.isRunningTest())   System.abortJob(t.Id);
		}
	}

	/**
	 * 배치 실행(외부 바로 호출)
	 * GuideActionDealerStockLevelExceed_sc.excuteBatch();
	 */
	public static void excuteBatch() {
		Database.executeBatch(new GuideActionDealerStockLevelExceed_ba(), batchSize);
	}
}