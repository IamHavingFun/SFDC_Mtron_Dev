/****************************************************************************************
  * @filename      : DealerIncentiveERPSend_sc
  * @projectname   :
  * @author        : i2max
  * @date          : 2020-04-23
  * @group         :
  * @group-content :
  * @description   :
  * @tester        : DealerIncentiveERPSend_sc_ts.cls
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2020-04-23         i2max          Create
****************************************************************************************/
public class DealerIncentiveERPSend_sc implements Schedulable {
	// Schedule 등록 배치명
	private static String batchName = '판매장려 기표 ERP 전송-새벽5시';
	// Schedule Cron Expression (매일 새벽 2시)
	//private static String batchCron = '0 0 2 * * ? *';
	private static String batchCron = '0 0 5 * * ? *';
	// Batch 수행 Size
	private static Integer batchSize = 20;

	/**
	 * 배치 실행 멤버 함수(override)
	 *
	 * @param SC : SchedulableContext
	 */
	public void execute(SchedulableContext SC) {
		DealerIncentiveERPSend_sc.excuteBatch();
	}

	/**
	 * 배치 Schedule 등록
	 * DealerIncentiveERPSend_sc.runSchedule();
	 */
	public static void runSchedule() {
		System.schedule(batchName, batchCron, new DealerIncentiveERPSend_sc());
	}

	/**
	 *  배치 Schedule 삭제
	 *  DealerIncentiveERPSend_sc.abortSchedule();
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
		Date toDay = Date.today();
		List<IncentiveCloseDateManage__c> target = [
				SELECT Id, SendDate__c FROM IncentiveCloseDateManage__c WHERE SendDate__c = :toDay LIMIT 1
		];
		if(target.isEmpty() == false && toDay == target[0].SendDate__c) {
			System.debug('배치 실행 : 대상');
			Database.executeBatch(new DealerIncentiveUnpaidERPSend_ba(), batchSize);
		} else {
			System.debug('배치 실행 : 비 대상');
		}
	}

}