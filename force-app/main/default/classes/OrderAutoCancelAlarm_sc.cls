/****************************************************************************************
  * @filename      : OrderAutoCancelAlarm_sc
  * @projectname   :
  * @author        : i2max
  * @date          : 2021-04-15
  * @group         :
  * @group-content :
  * @description   :
  * @tester        : OrderAutoCancelAlarm_sc_ts.cls
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2022-03-04      i2max          Create
****************************************************************************************/
public with sharing class OrderAutoCancelAlarm_sc implements Schedulable {

	// Schedule 등록 배치명
	private static String batchName = '주문경고알림-ERP주문미처리(매월25일,07:00)';
	// Schedule Cron Expression (매월 25일 새벽 7시)
	private static String batchCron = '0 0 7 25 * ? *';
	// Batch 수행 Size
	private static Integer batchSize = 200;

	/**
	 * 배치 실행 멤버 함수
	 *
	 * @param SC : SchedulableContext
	 */
	public void execute(SchedulableContext SC) {
		OrderAutoCancelAlarm_sc.excuteBatch();
	}

	/**
	 * 배치 Schedule 등록
	 * OrderAutoCancelAlarm_sc.runSchedule();
	 */
	public static void runSchedule() {
		System.schedule(batchName, batchCron, new OrderAutoCancelAlarm_sc());
	}

	/**
	 *  배치 Schedule 삭제
	 *  OrderAutoCancelAlarm_sc.abortSchedule();
	 */
	public static void abortSchedule() {
		for (CronTrigger t : [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = :batchName]) {
			if(!Test.isRunningTest())   System.abortJob(t.Id);
		}
	}

	/**
	 * 배치 실행(외부 바로 호출)
	 * OrderAutoCancelAlarm_sc.excuteBatch();
	 */
	public static void excuteBatch() {
		Database.executeBatch(new OrderAutoCancelAlarm_ba(), batchSize);
	}


}