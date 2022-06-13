/****************************************************************************************
  * @filename      : OrderCancelAlarm_sc
  * @projectname   : 
  * @author        : i2max
  * @date          : 2021-04-15
  * @group         : 
  * @group-content : 
  * @description   : 
  * @tester        : OrderCancelAlarm_sc_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2021-04-15         i2max          Create
****************************************************************************************/
public with sharing class OrderCancelAlarm_sc implements Schedulable {

    // Schedule 등록 배치명
    private static String batchName = '주문-납품경과일 익월15일 지난건 알림(15일,08:20)';
    // Schedule Cron Expression (매월 15일 오전 8시)
    private static String batchCron = '0 20 8 15 * ? *';
    // Batch 수행 Size
    private static Integer batchSize = 200;

    /**
     * 배치 실행 멤버 함수
     *
     * @param SC : SchedulableContext
     */
    public void execute(SchedulableContext SC) {
        OrderCancelAlarm_sc.excuteBatch();
    }

    /**
     * 배치 Schedule 등록
     * OrderCancelAlarm_sc.runSchedule();
     */
    public static void runSchedule() {
        System.schedule(batchName, batchCron, new OrderCancelAlarm_sc());
    }

    /**
     *  배치 Schedule 삭제
     *  OrderCancelAlarm_sc.abortSchedule();
     */
    public static void abortSchedule() {
        for (CronTrigger t : [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = :batchName]) {
            if(!Test.isRunningTest())   System.abortJob(t.Id);
        }
    }

    /**
     * 배치 실행(외부 바로 호출)
     * OrderCancelAlarm_sc.excuteBatch();
     */
    public static void excuteBatch() {
        Database.executeBatch(new OrderCancelAlarm_ba(), batchSize);
    }

}