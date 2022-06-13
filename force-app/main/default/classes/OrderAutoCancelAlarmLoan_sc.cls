/****************************************************************************************
  * @filename      : OrderAutoCancelAlarmLoan_sc
  * @projectname   :
  * @author        : i2max
  * @date          : 2021-04-15
  * @group         :
  * @group-content :
  * @description   :
  * @tester        : OrderAutoCancelAlarmLoan_sc_ts.cls
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2021-04-15         i2max          Create
****************************************************************************************/
public with sharing class OrderAutoCancelAlarmLoan_sc implements Schedulable {

	// Schedule 등록 배치명
	private static String batchName = '주문경고알림-여신입력미처리(매월1일,07:10)';
	// Schedule Cron Expression (매월 1일 새벽 7시 10분)
	private static String batchCron = '0 10 7 1 * ? *';
	// Batch 수행 Size
	private static Integer batchSize = 200;

	/**
	 * 배치 실행 멤버 함수
	 *
	 * @param SC : SchedulableContext
	 */
	public void execute(SchedulableContext SC) {
		OrderAutoCancelAlarmLoan_sc.excuteBatch();
	}

	/**
	 * 배치 Schedule 등록
	 * OrderAutoCancelAlarmLoan_sc.runSchedule();
	 */
	public static void runSchedule() {
		System.schedule(batchName, batchCron, new OrderAutoCancelAlarmLoan_sc());
	}

	/**
	 *  배치 Schedule 삭제
	 *  OrderAutoCancelAlarmLoan_sc.abortSchedule();
	 */
	public static void abortSchedule() {
		for (CronTrigger t : [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = :batchName]) {
			if(!Test.isRunningTest())   System.abortJob(t.Id);
		}
	}

	/**
	 * 배치 실행(외부 바로 호출)
	 * OrderAutoCancelAlarmLoan_sc.excuteBatch();
	 */
	public static void excuteBatch() {
		Database.executeBatch(new OrderAutoCancelAlarmLoan_ba(), batchSize);
	}


}