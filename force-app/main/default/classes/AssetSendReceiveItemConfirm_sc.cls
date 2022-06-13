/****************************************************************************************
  * @filename      : AssetSendReceiveItemConfirm_sc
  * @projectname   : 
  * @author        : i2max
  * @date          : 2020-04-16
  * @group         : 
  * @group-content : 
  * @description   : 
  * @tester        : AssetSendReceiveItemConfirm_sc_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2020-04-16      i2max       Create
****************************************************************************************/
public with sharing class AssetSendReceiveItemConfirm_sc implements Schedulable {

    // Schedule 등록 배치명
    private static String batchName = 'AssetAssetSendReceiveItemConfirm';
    // Schedule Cron Expression
    private static String batchCron = '0 0 8 * * ?';
    // Batch 수행 Size
    private static Integer batchSize = 2000;

    /**
     * 배치 실행 멤버 함수(override)
     *
     * @param SC : SchedulableContext
     */
    public void execute(SchedulableContext SC) {
        AssetSendReceiveItemConfirm_sc.excuteBatch();
    }

    /**
     * 배치 Schedule 등록
     * AssetSendReceiveItemConfirm_sc.runSchedule();
     */
    public static void runSchedule() {
        System.schedule(batchName, batchCron, new AssetSendReceiveItemConfirm_sc());
    }

    /**
     *  배치 Schedule 삭제
     *  AssetSendReceiveItemConfirm_sc.abortSchedule();
     */
    public static void abortSchedule() {
        for (CronTrigger t : [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = :batchName]) {
            System.abortJob(t.Id);
        }
    }

    /**
     * 배치 실행(외부 바로 호출)
     * AssetSendReceiveItemConfirm_sc.excuteBatch();
     */
    public static void excuteBatch() {
        Database.executeBatch(new AssetSendReceiveItemConfirm_ba(), batchSize);
    }

}