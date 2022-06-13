/****************************************************************************************
  * @filename      : OpportunityLossStageAlarmContract_sc
  * @projectname   : 
  * @author        : i2max
  * @date          : 2021-04-19
  * @group         : 
  * @group-content : 
  * @description   : 
  * @tester        : OpportunityLossStageAlarmContract_sc_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2021-04-19         i2max          Create
****************************************************************************************/
public with sharing class OpportunityLossStageAlarmContract_sc implements Schedulable {

    // Schedule 등록 배치명
    private static String batchName = '판매기회(계약)-15일 지난건 실주 예고 알람(08:05)';
    // Schedule Cron Expression (매일 새벽 8시)
    private static String batchCron = '0 5 8 * * ? *';
    // Batch 수행 Size
    private static Integer batchSize = 200;

    /**
     * 배치 실행 멤버 함수
     *
     * @param SC : SchedulableContext
     */
    public void execute(SchedulableContext SC) {
        OpportunityLossStageAlarmContract_sc.excuteBatch();
    }

    /**
     * 배치 Schedule 등록
     * OpportunityLossStageAlarmContract_sc.runSchedule();
     */
    public static void runSchedule() {
        System.schedule(batchName, batchCron, new OpportunityLossStageAlarmContract_sc());
    }

    /**
     *  배치 Schedule 삭제
     *  OpportunityLossStageAlarmContract_sc.abortSchedule();
     */
    public static void abortSchedule() {
        for (CronTrigger t : [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = :batchName]) {
            if(!Test.isRunningTest())   System.abortJob(t.Id);
        }
    }

    /**
     * 배치 실행(외부 바로 호출)
     * OpportunityLossStageAlarmContract_sc.excuteBatch();
     */
    public static void excuteBatch() {
        Database.executeBatch(new OpportunityLossStageAlarmContract_ba(), batchSize);
    }

}