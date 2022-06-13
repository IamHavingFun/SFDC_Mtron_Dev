/****************************************************************************************
  * @filename      : Odds_sc
  * @projectname   : 
  * @author        : i2max
  * @date          : 2021-05-06
  * @group         : 
  * @group-content : 
  * @description   : 
  * @tester        : Odds_sc_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2021-05-06         i2max          Create
****************************************************************************************/
public with sharing class Odds_sc implements Schedulable {

    // Schedule 등록 배치명
    private static String batchName = '승률-예측-처리(01)';
    // Schedule Cron Expression (매일 새벽 1시)
    private static String batchCron = '0 0 1 * * ? *';
    // Batch 수행 Size
    private static Integer batchSize = 1;

    /**
     * 배치 실행 멤버 함수
     *
     * @param SC : SchedulableContext
     */
    public void execute(SchedulableContext SC) {
        Odds_sc.excuteBatch();
    }

    /**
     * 배치 Schedule 등록
     * Odds_sc.runSchedule();
     */
    public static void runSchedule() {
        System.schedule(batchName, batchCron, new Odds_sc());
    }

    /**
     *  배치 Schedule 삭제
     *  Odds_sc.abortSchedule();
     */
    public static void abortSchedule() {
        for (CronTrigger t : [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = :batchName]) {
            if(!Test.isRunningTest())   System.abortJob(t.Id);
        }
    }

    /**
     * 배치 실행(외부 바로 호출)
     * Odds_sc.excuteBatch();
     */
    public static void excuteBatch() {
        Database.executeBatch(new Odds_ba(), batchSize);
    }
    
}