/****************************************************************************************
  * @filename      : InterfaceLogDelete_sc
  * @projectname   : LS
  * @author        : ldb3100
  * @date          : 2020-09-03    
  * @group         :
  * @group-content :
  * @description   :
  * @tester        : InterfaceLogDelete_sc_ts
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log  
  * ===============================================================
  * ver     date                    author          description
  * ===============================================================
    0.1     2020-09-03              ldb3100         Create
****************************************************************************************/
global without sharing class InterfaceLogDelete_sc implements Schedulable {
	
	// Schedule 등록 배치명
    private static String batchName = '[IFLOG] 30일 지난 IF LOG 삭제';
    // Schedule Cron Expression (매일 저녁 11시 30분)
    private static String batchCron = '0 30 23 * * ? *';
    // Batch 수행 Size
    private static Integer batchSize = 2000;
    
    global void execute(SchedulableContext SC) {
        InterfaceLogDelete_sc.excuteBatch();
    }
    
    /**
     * 배치 Schedule 등록
     * InterfaceLogDelete_sc.runSchedule();
     */
    public static void runSchedule() {
        System.schedule(batchName, batchCron, new InterfaceLogDelete_sc());
    }

    /**
     *  배치 Schedule 삭제
     *  InterfaceLogDelete_sc.abortSchedule();
     */
    public static void abortSchedule() {
        for (CronTrigger t : [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = :batchName]) {
            if(!Test.isRunningTest())   System.abortJob(t.Id);
        }
    }

    /**
     * 배치 실행(외부 바로 호출)
     * InterfaceLogDelete_sc.excuteBatch();
     */
    
    public static void excuteBatch() {
        Database.executeBatch(new InterfaceLogDelete_ba(), batchSize);
    }
}