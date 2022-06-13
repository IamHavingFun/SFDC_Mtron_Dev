/****************************************************************************************
  * @filename      : AssetSendReceiveSpecifiedDate_sc
  * @projectname   :
  * @author        : i2max
  * @date          : 2020-07-08
  * @group         :
  * @group-content :
  * @description   :
  * @tester        : AssetSendReceiveSpecifiedDate_sc_ts.cls
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author              description
  * ===============================================================
    0.1     2020-07-08               i2max                  Create
*************a***************************************************************************/
public with sharing class AssetSendReceiveSpecifiedDate_sc implements Schedulable {
    // Schedule 등록 배치명
    private static String batchName = '전수배 지정 스케줄';
    // Schedule Cron Expression (매일 새벽 5시)
    private static String batchCron = '0 0 5 * * ? *';
    // Batch 수행 Size
    private static Integer batchSize = 200;


    /**
     * 배치 실행 멤버 함수(override)
     *
     * @param SC : SchedulableContext
     */
    public void execute(SchedulableContext SC) {
        AssetSendReceiveSpecifiedDate_sc.excuteBatch();
    }

    /**
     * 배치 Schedule 등록
     * AssetSendReceiveSpecifiedDate_sc.runSchedule();
     */
    public static void runSchedule() {
        System.schedule(batchName, batchCron, new AssetSendReceiveSpecifiedDate_sc());
    }

    /**
     *  배치 Schedule 삭제
     *  AssetSendReceiveSpecifiedDate_sc.abortSchedule();
     */
    public static void abortSchedule() {
        for (CronTrigger t : [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = :batchName]) {
            if(!Test.isRunningTest())   System.abortJob(t.Id);
        }
    }

    /**
     * 배치 실행(외부 바로 호출)
     * AssetSendReceiveSpecifiedDate_sc.excuteBatch();
     */
    public static void excuteBatch() {
        Database.executeBatch(new AssetSendReceiveSpecifiedDate_ba(), batchSize);
    }

}