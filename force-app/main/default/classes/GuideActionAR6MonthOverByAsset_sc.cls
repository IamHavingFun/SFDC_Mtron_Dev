/****************************************************************************************
 * @filename      : GuideActionAR6MonthOverByAsset_sc
 * @projectname   : 
 * @author        : SEOKHO LEE
 * @date          : 2020-08-18 오후 4:48
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
 0.1     2020-08-18 오후 4:48        SEOKHO LEE          Create
 ****************************************************************************************/

public class GuideActionAR6MonthOverByAsset_sc implements Schedulable {
    // Schedule 등록 배치명
    private static String batchName = '[가이드액션] 채권확인_6개월_만기초과';
    // Schedule Cron Expression (매월 6일 새벽 6시)
    private static String batchCron = '0 0 6 6 * ? *';
    // Batch 수행 Size
    private static Integer batchSize = 200;

    /**
     * 배치 실행 멤버 함수(override)
     *
     * @param SC : SchedulableContext
     */
    public void execute(SchedulableContext SC) {
        GuideActionAR6MonthOverByAsset_sc.excuteBatch();
    }

    /**
     * 배치 Schedule 등록
     */
    public static void runSchedule() {
        System.schedule(batchName, batchCron, new GuideActionAR6MonthOverByAsset_sc());
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
        Database.executeBatch(new GuideActionAR6MonthOverByAsset_ba(), batchSize);
    }
}