/****************************************************************************************
  * @filename      : OrderAutoCancelERPSendLoan_sc
  * @projectname   :
  * @author        : i2max
  * @date          : 2021-04-15
  * @group         :
  * @group-content :
  * @description   :
  * @tester        : OrderAutoCancelERPSendLoan_sc_ts.cls
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2022-03-04      i2max          Create
****************************************************************************************/
public with sharing class OrderAutoCancelERPSendLoan_sc implements Schedulable {

	// Schedule 등록 배치명
	private static String batchName = '주문자동취소-여신입력미처리(매일,02:10)';
	// Schedule Cron Expression (매월 1일 새벽 2시)
	private static String batchCron = '0 10 2 * * ? *';
	// Batch 수행 Size
	private static Integer batchSize = 50;

	/**
	 * 배치 실행 멤버 함수
	 *
	 * @param SC : SchedulableContext
	 */
	public void execute(SchedulableContext SC) {
		OrderAutoCancelERPSendLoan_sc.excuteBatch();
	}

	/**
	 * 배치 Schedule 등록
	 * OrderAutoCancelERPSendLoan_sc.runSchedule();
	 */
	public static void runSchedule() {
		System.schedule(batchName, batchCron, new OrderAutoCancelERPSendLoan_sc());
	}

	/**
	 *  배치 Schedule 삭제
	 *  OrderAutoCancelERPSendLoan_sc.abortSchedule();
	 */
	public static void abortSchedule() {
		for (CronTrigger t : [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = :batchName]) {
			if(!Test.isRunningTest())   System.abortJob(t.Id);
		}
	}

	/**
	 * 배치 실행(외부 바로 호출)
	 * OrderAutoCancelERPSendLoan_sc.excuteBatch();
	 */
	public static void excuteBatch() {
		List<OrderAutoCancelManage__c> oacmList = [
				SELECT ProcessDate__c FROM OrderAutoCancelManage__c WHERE ProcessDate__c = TODAY
		];
		if(oacmList.isEmpty() == false) {
			Database.executeBatch(new OrderAutoCancelERPSendLoan_ba(), batchSize);
		}
	}


}