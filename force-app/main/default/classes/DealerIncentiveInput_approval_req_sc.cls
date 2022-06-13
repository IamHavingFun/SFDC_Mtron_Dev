/****************************************************************************************
  * @filename      : DealerIncentiveInput_approval_req_sc
  * @projectname   :
  * @author        : i2max
  * @date          : 2020-04-23
  * @group         :
  * @group-content : 판매장려 기표 승인 요청
  *                  매월 1일 7시
  * @description   :
  * @tester        : DealerIncentiveInput_approval_req_sc_ts.cls
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2020-04-23         i2max          Create
****************************************************************************************/
public class DealerIncentiveInput_approval_req_sc implements Schedulable {
	// Schedule 등록 배치명
	private static String batchName = '판매장려 기표 승인요청-매월1일07시';
	// Schedule Cron Expression (매일 새벽 2시)
	private static String batchCron = '0 0 7 1 * ? *';
	// Batch 수행 Size
	private static Integer batchSize = 20;

	/**
	 * 배치 실행 멤버 함수(override)
	 *
	 * @param SC : SchedulableContext
	 */
	public void execute(SchedulableContext SC) {
		DealerIncentiveInput_approval_req_sc.excuteBatch();
	}

	/**
	 * 배치 Schedule 등록
	 * DealerIncentiveInput_approval_req_sc.runSchedule();
	 */
	public static void runSchedule() {
		System.schedule(batchName, batchCron, new DealerIncentiveInput_approval_req_sc());
	}

	/**
	 *  배치 Schedule 삭제
	 *  DealerIncentiveInput_approval_req_sc.abortSchedule();
	 */
	public static void abortSchedule() {
		for (CronTrigger t : [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = :batchName]) {
			if(!Test.isRunningTest())   System.abortJob(t.Id);
		}
	}

	/**
	 * 배치 실행(외부 바로 호출)
	 * DealerIncentiveInput_approval_req_sc.excuteBatch();
	 */
	public static void excuteBatch() {
		Database.executeBatch(new DealerIncentiveInput_approval_req_ba(), batchSize);
	}

}