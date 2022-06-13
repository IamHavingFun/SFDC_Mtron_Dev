/****************************************************************************************
  * @filename      : AccountSalesIQUpdate_sc
  * @projectname   : 
  * @author        : i2max_my.Seo 
  * @date          : 2020-08-18 오후 3:30
  * @group         : 
  * @group-content : 
  * @description   : 
  * @tester        : AccountSalesIQUpdate_sc_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author              description
  * ===============================================================
    0.1     2020-08-18 오후 3:30     i2max_my.Seo           Create
****************************************************************************************/
public class AccountSalesIQUpdate_sc implements Schedulable {
    // Schedule 등록 배치명
    private static String batchName = '[Sales IQ] 고객 점수 업데이트 및 순위 지정';
    // Schedule Cron Expression (매월 1일 새벽 5시 30분)
    private static String batchCron = '0 30 5 ? * SUN *';
    // Batch 수행 Size
    private static Integer batchSize = 1;

    /**
     * 배치 실행 멤버 함수(override)
     *
     * @param SC : SchedulableContext
     */
    public void execute(SchedulableContext SC) {
        AccountSalesIQUpdate_sc.excuteBatch();
    }

    /**
     * 배치 Schedule 등록
     * AccountSalesIQUpdate_sc.runSchedule();
     */
    public static void runSchedule() {
        System.schedule(batchName, batchCron, new AccountSalesIQUpdate_sc());
    }

    /**
     *  배치 Schedule 삭제
     *  AccountSalesIQUpdate_sc.abortSchedule();
     */
    public static void abortSchedule() {
        for (CronTrigger t : [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = :batchName]) {
            if(!Test.isRunningTest())   System.abortJob(t.Id);
        }
    }

    /**
     * 배치 실행(외부 바로 호출)
     * AccountSalesIQUpdate_sc.excuteBatch();
     */
    public static void excuteBatch() {
        Database.executeBatch(new AccountSalesIQUpdate_ba(), batchSize);
    }
}