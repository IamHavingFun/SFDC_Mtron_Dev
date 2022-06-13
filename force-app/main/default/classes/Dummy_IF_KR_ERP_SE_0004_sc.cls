/****************************************************************************************
  * @filename      : Dummy_IF_KR_ERP_SE_0004_sc
  * @projectname   : 
  * @author        : i2max
  * @date          : 2020-04-23
  * @group         : 
  * @group-content : 
  * @description   : 
  * @tester        : Dummy_IF_KR_ERP_SE_0004_sc_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2020-04-23         i2max          Create
****************************************************************************************/
public class Dummy_IF_KR_ERP_SE_0004_sc implements Schedulable {
    // Schedule 등록 배치명
    private static String batchName = 'DummyBatch_IF_KR_ERP_SE_0004';
    // Schedule Cron Expression (매 30분 단위, 당일 발생 데이터 전체 전송)
    private static String batchCron = '0 {0} * * * ? *';
    // Batch 수행 Size
    private static Integer batchSize = 200;

    /**
     * 배치 실행 멤버 함수(override)
     *
     * @param SC : SchedulableContext
     */
    public void execute(SchedulableContext SC) {
        Dummy_IF_KR_ERP_SE_0004_sc.excuteBatch();
    }

    /**
     * 배치 Schedule 등록
     * 30분 간격 처리
     * Dummy_IF_KR_ERP_SE_0004_sc.runSchedule();
     */
    public static void runSchedule() {
        System.schedule(batchName + ' : 15분', String.format(batchCron, new List<String>{'15'}), new Dummy_IF_KR_ERP_SE_0004_sc());
        System.schedule(batchName + ' : 45분', String.format(batchCron, new List<String>{'45'}), new Dummy_IF_KR_ERP_SE_0004_sc());
    }

    /**
     *  배치 Schedule 삭제
     *  Dummy_IF_KR_ERP_SE_0004_sc.abortSchedule();
     */
    public static void abortSchedule() {
        for (CronTrigger t : [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name LIKE :(batchName + '%')]) {
            if(!Test.isRunningTest())   System.abortJob(t.Id);
        }
    }

    /**
     * 배치 실행(외부 바로 호출)
     * Dummy_IF_KR_ERP_SE_0004_sc.excuteBatch();
     */
    public static void excuteBatch() {
        Database.executeBatch(new Dummy_IF_KR_ERP_SE_0004_ba(), batchSize);
    }
}