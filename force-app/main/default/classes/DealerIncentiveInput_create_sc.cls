/****************************************************************************************
  * @filename      : DealerIncentiveInput_create_sc
  * @projectname   :
  * @author        : i2max
  * @date          : 2020-04-23
  * @group         :
  * @group-content :
  * @description   :
  * @tester        : DealerIncentiveInput_create_sc_ts.cls
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2020-04-23         i2max          Create
****************************************************************************************/
public class DealerIncentiveInput_create_sc implements Schedulable {
	// Schedule 등록 배치명
	private static String batchName = '판매장려 기표 생성-매월1일04시';
	// Schedule Cron Expression (매일 새벽 4시)
	private static String batchCron = '0 0 4 1 * ? *';
	// Batch 수행 Size
	private static Integer batchSize = 100;

	/**
	 * 배치 실행 멤버 함수(override)
	 *
	 * @param SC : SchedulableContext
	 */
	public void execute(SchedulableContext SC) {
		DealerIncentiveInput_create_sc.excuteBatch();
	}

	/**
	 * 배치 Schedule 등록
	 * DealerIncentiveInput_create_sc.runSchedule();
	 */
	public static void runSchedule() {
		System.schedule(batchName, batchCron, new DealerIncentiveInput_create_sc());
	}

	/**
	 *  배치 Schedule 삭제
	 *  DealerIncentiveInput_create_sc.abortSchedule();
	 */
	public static void abortSchedule() {
		for (CronTrigger t : [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = :batchName]) {
			if(!Test.isRunningTest())   System.abortJob(t.Id);
		}
	}

	/**
	 * 배치 실행(외부 바로 호출)
	 * DealerIncentiveERPSend_sc.excuteBatch();
	 */
	public static void excuteBatch() {
		Database.executeBatch(new DealerIncentiveInput_create_ba(), batchSize);
	}

}