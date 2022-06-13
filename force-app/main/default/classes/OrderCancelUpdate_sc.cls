/****************************************************************************************
  * @filename      : OrderCancelUpdate_sc
  * @projectname   : 
  * @author        : i2max
  * @date          : 2021-04-15
  * @group         : 
  * @group-content : 
  * @description   : 
  * @tester        : OrderCancelUpdate_sc_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2021-04-15         i2max          Create
****************************************************************************************/
public with sharing class OrderCancelUpdate_sc implements Schedulable {

    // Schedule 등록 배치명
    private static String batchName = '주문-납품경과일 익월20일 지난건 알림(20일,08:25)';
    // Schedule Cron Expression (매월 20일 새벽 8시)
    private static String batchCron = '0 25 8 20 * ? *';
    // Batch 수행 Size
    private static Integer batchSize = 200;

    /**
     * 배치 실행 멤버 함수
     *
     * @param SC : SchedulableContext
     */
    public void execute(SchedulableContext SC) {
        OrderCancelUpdate_sc.excuteBatch();
    }

    /**
     * 배치 Schedule 등록
     * OrderCancelUpdate_sc.runSchedule();
     */
    public static void runSchedule() {
        System.schedule(batchName, batchCron, new OrderCancelUpdate_sc());
    }

    /**
     *  배치 Schedule 삭제
     *  OrderCancelUpdate_sc.abortSchedule();
     */
    public static void abortSchedule() {
        for (CronTrigger t : [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = :batchName]) {
            if(!Test.isRunningTest())   System.abortJob(t.Id);
        }
    }

    /**
     * 배치 실행(외부 바로 호출)
     * OrderCancelUpdate_sc.excuteBatch();
     */
    public static void excuteBatch() {
        Database.executeBatch(new OrderCancelUpdate_ba(), batchSize);
    }


}