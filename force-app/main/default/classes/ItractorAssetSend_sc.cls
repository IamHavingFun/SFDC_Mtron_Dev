/****************************************************************************************
  * @filename      : ItractorAssetSend_sc
  * @projectname   : LS
  * @author        : ldb3100
  * @date          : 2020-09-03
  * @group         :
  * @group-content :
  * @description   :
  * @tester        : ItractorAssetSend_sc_ts
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                    author          description
  * ===============================================================
    0.1     2020-09-03              ldb3100         Create
****************************************************************************************/
global without sharing class ItractorAssetSend_sc implements Schedulable {

	// Schedule 등록 배치명
	private static String batchName = '[아이트랙터] 판매 정보 전송(매일 5시)';
	// Schedule Cron Expression (매일 오전 5시 0분)
	private static String batchCron = '0 0 5 * * ? *';
	// Batch 수행 Size
	private static Integer batchSize = 2000;

	global void execute(SchedulableContext SC) {
		ItractorAssetSend_sc.excuteBatch();
	}

	/**
	 * 배치 Schedule 등록
	 * ItractorAssetSend_sc.runSchedule();
	 */
	public static void runSchedule() {
		System.schedule(batchName, batchCron, new ItractorAssetSend_sc());
	}

	/**
	 *  배치 Schedule 삭제
	 *  ItractorAssetSend_sc.abortSchedule();
	 */
	public static void abortSchedule() {
		for (CronTrigger t : [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = :batchName]) {
			if(!Test.isRunningTest())   System.abortJob(t.Id);
		}
	}

	/**
	 * 배치 실행(외부 바로 호출)
	 * ItractorAssetSend_sc.excuteBatch();
	 */

	public static void excuteBatch() {
		Database.executeBatch(new ItractorAssetSend_ba(), batchSize);
	}
}