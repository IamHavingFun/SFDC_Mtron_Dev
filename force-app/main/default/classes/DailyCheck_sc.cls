/****************************************************************************************
 * @filename      : DailyCheck_sc
 * @projectname   : 
 * @author        : SEOKHO LEE
 * @date          : 2020-12-17 오전 10:29
 * @group         :
 * @group-content :
 * @description   :
 * @tester        :
 * @reference     :
 * @copyright     : Copyright © I2max. All Rights Reserved.
 * @modification Log
 * ===============================================================
 * ver     date                     author              description
 * ===============================================================
 0.1     2020-12-17 오전 10:29      SEOKHO LEE          Create
 ****************************************************************************************/

public with sharing class DailyCheck_sc implements Schedulable {
    // Schedule 등록 배치명
    private static String batchName = 'I/F 점검';
    // Schedule Cron Expression (매일 8시 30분)
    private static String batchCron = '0 30 8 * * ? *';
    // Batch 수행 Size
    private static Integer batchSize = 200;

    /**
     * 배치 실행 멤버 함수(override)
     *
     * @param SC : SchedulableContext
     */
    public void execute(SchedulableContext SC) {
        DailyCheck_sc.excuteBatch();
    }

    /**
     * 배치 Schedule 등록
     */
    public static void runSchedule() {
        System.schedule(batchName, batchCron, new DailyCheck_sc());
    }

    /**
     *  배치 Schedule 삭제
     */
    public static void abortSchedule() {
        for (CronTrigger t : [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = :batchName]) {
            if(!Test.isRunningTest())   System.abortJob(t.Id);
        }
    }

    /**
     * 배치 실행(외부 바로 호출)
     */
    public static void excuteBatch() {
        Database.executeBatch(new DailyCheck_ba(), batchSize);
    }
}