/****************************************************************************************
  * @filename      : OrderDeliverySeqUpdate_sc
  * @author        : I2MAX
  * @date          : 2021-11-15
  * @group         : 
  * @group-content : 
  * @description   : 
  * @tester        : OrderDeliverySeqUpdate_sc_ts.cls
  * @schedule      :
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author        description
  * ===============================================================
    1.0     2021-11-15       I2MAX.YR           Create
****************************************************************************************/


public with sharing class OrderDeliverySeqUpdate_sc implements Schedulable {

    // Schedule 등록 배치명
    private static String batchName = '출하 우선순위 처리_3시';
    // Schedule Cron Expression (매일 새벽 3시)
    private static String batchCron = '0 00 3 ? * * *';
    // Batch 수행 Size
    private static Integer batchSize = 1;

    /**
     * 배치 실행 멤버 함수
     *
     * @param SC : SchedulableContext
     */
    public void execute(SchedulableContext SC) {
        OrderDeliverySeqUpdate_sc.excuteBatch();
    }

    /**
     * 배치 Schedule 등록
     * OrderDeliverySeqUpdate_sc.runSchedule();
     */
    public static void runSchedule() {
        System.schedule(batchName, batchCron, new OrderDeliverySeqUpdate_sc());
    }

    /**
     *  배치 Schedule 삭제
     *  OrderDeliverySeqUpdate_sc.abortSchedule();
     */
    public static void abortSchedule() {
        for (CronTrigger t : [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = :batchName]) {
            if(!Test.isRunningTest())   System.abortJob(t.Id);
        }
    }

    /**
     * 배치 실행(외부 바로 호출)
     * OrderDeliverySeqUpdate_sc.excuteBatch();
     */
    public static void excuteBatch() {
        Database.executeBatch(new OrderDeliverySeqUpdate_ba(), batchSize);
    }

    
}