/****************************************************************************************
  * @filename      : PartnerIncentiveApproval_sc
  * @projectname   :
  * @author        : i2max
  * @date          : 2020-04-23
  * @group         :
  * @group-content :
  * @description   : 판매장려 집계표 자동 승인 처리
  *                  매월 특정일 지정 17시30분
  * @tester        : PartnerIncentiveApproval_sc_ts.cls
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2020-04-23         i2max          Create
****************************************************************************************/
public class PartnerIncentiveApproval_sc implements Schedulable {
	// Schedule 등록 배치명
	private static String batchName = '판매장려 집계표 자동승인 및 전송-매월특정일17시30분';
	// Schedule Cron Expression (매월특정일 17시30분)
	private static String batchCron = '0 30 17 * * ? *';
	// Batch 수행 Size
	private static Integer batchSize = 20;

	/**
	 * 배치 실행 멤버 함수(override)
	 *
	 * @param SC : SchedulableContext
	 */
	public void execute(SchedulableContext SC) {
		PartnerIncentiveApproval_sc.excuteBatch();
	}

	/**
	 * 배치 Schedule 등록
	 * PartnerIncentiveApproval_sc.runSchedule();
	 */
	public static void runSchedule() {
		System.schedule(batchName, batchCron, new PartnerIncentiveApproval_sc());
	}

	/**
	 *  배치 Schedule 삭제
	 *  PartnerIncentiveApproval_sc.abortSchedule();
	 */
	public static void abortSchedule() {
		for (CronTrigger t : [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = :batchName]) {
			if(!Test.isRunningTest())   System.abortJob(t.Id);
		}
	}

	/**
	 * 배치 실행(외부 바로 호출)
	 * PartnerIncentiveApproval_sc.excuteBatch();
	 */
	public static void excuteBatch() {
		Date toDay = Date.today();
		List<IncentiveCloseDateManage__c> target = [
				SELECT Id, PartnerIcentiveERPSendDate__c FROM IncentiveCloseDateManage__c WHERE PartnerIcentiveERPSendDate__c = :toDay LIMIT 1
		];
		if(target.isEmpty() == false && toDay == target[0].PartnerIcentiveERPSendDate__c) {
			System.debug('배치 실행 : 대상');
			Database.executeBatch(new PartnerIncentiveApproval_ba(), batchSize);
		} else {
			System.debug('배치 실행 : 비 대상');
		}
	}

}