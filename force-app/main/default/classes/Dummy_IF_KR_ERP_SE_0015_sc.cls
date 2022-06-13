/****************************************************************************************
  * @filename      : Dummy_IF_KR_ERP_SE_0015_sc
  * @projectname   : 
  * @author        : i2max
  * @date          : 2020-04-23
  * @group         : 
  * @group-content : 
  * @description   : 
  * @tester        : Dummy_IF_KR_ERP_SE_0015_sc_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2020-04-23         i2max          Create
****************************************************************************************/
public class Dummy_IF_KR_ERP_SE_0015_sc implements Schedulable {

    // Schedule 등록 배치명
    private static String batchName = 'DummyBatch_IF_KR_ERP_SE_0015';
    // Schedule Cron Expression (매월 4일 새벽 3시)
    private static String batchCron = '0 0 3 4 * ? *';
    // Batch 수행 Size
    private static Integer batchSize = 200;

    /**
     * 배치 실행 멤버 함수(override)
     *
     * @param SC : SchedulableContext
     */
    public void execute(SchedulableContext SC) {
        Dummy_IF_KR_ERP_SE_0015_sc.excuteBatch();
    }

    /**
     * 배치 Schedule 등록
     * Dummy_IF_KR_ERP_SE_0015_sc.runSchedule();
     */
    public static void runSchedule() {
        System.schedule(batchName, batchCron, new Dummy_IF_KR_ERP_SE_0015_sc());
    }

    /**
     *  배치 Schedule 삭제
     *  Dummy_IF_KR_ERP_SE_0015_sc.abortSchedule();
     */
    public static void abortSchedule() {
        for (CronTrigger t : [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = :batchName]) {
            if(!Test.isRunningTest())   System.abortJob(t.Id);
        }
    }

    /**
     * 배치 실행(외부 바로 호출)
     * Dummy_IF_KR_ERP_SE_0015_sc.excuteBatch();
     */
    public static void excuteBatch() {
        Database.executeBatch(new Dummy_IF_KR_ERP_SE_0015_ba(), batchSize);
    }

}