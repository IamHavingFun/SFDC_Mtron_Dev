/****************************************************************************************
  * @filename      : OrderCancelERPSend_sc
  * @projectname   :
  * @author        : i2max
  * @date          : 2021-04-15
  * @group         :
  * @group-content :
  * @description   : 자동 취소건 ERP 전송 : 8시 30분에 전송 처리.
  * @tester        : OrderCancelERPSend_sc_ts.cls
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2021-04-15         i2max          Create
****************************************************************************************/
public with sharing class OrderCancelERPSend_sc implements Schedulable {

	// Schedule 등록 배치명
	private static String batchName = '당일 자동 주문 취소건(계약및납품기일Over)-ERP 전송처리(08:30)';
	// Schedule Cron Expression (매월 15일 오전 8시)
	private static String batchCron = '0 30 8 * * ? *';
	// Batch 수행 Size
	private static Integer batchSize = 1;
	/**
	 * 배치 실행 멤버 함수
	 *
	 * @param SC : SchedulableContext
	 */
	public void execute(SchedulableContext SC) {
		OrderCancelERPSend_sc.excuteBatch();
	}

	/**
	 * 배치 Schedule 등록
	 * OrderCancelERPSend_sc.runSchedule();
	 */
	public static void runSchedule() {
		System.schedule(batchName, batchCron, new OrderCancelERPSend_sc());
	}

	/**
	 *  배치 Schedule 삭제
	 *  OrderCancelERPSend_sc.abortSchedule();
	 */
	public static void abortSchedule() {
		for (CronTrigger t : [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = :batchName]) {
			if(!Test.isRunningTest())   System.abortJob(t.Id);
		}
	}

	/**
	 * 배치 실행(외부 바로 호출)
	 * OrderCancelERPSend_sc.excuteBatch();
	 */
	public static void excuteBatch() {
		Database.executeBatch(new OrderCancelERPSend_ba(), batchSize);
	}

}