/**
** @filename     : GuideActionLeadConfirm_sc
* @projectname   :
* @author        : CHOI SEONGWON
* @date          : 2020-08-18 오후 4:36
* @group         :
* @group-content :
* @description   :
* @tester        :
* @reference     :
* @copyright     : Copyright © I2max. All Rights Reserved.
* @modification Log
* ===============================================================
* ver     date             author              description
* ===============================================================
  0.1                            Create
 */
 public class GuideActionLeadConfirm_sc implements Schedulable {
    // Schedule 등록 배치명
    private static String batchName = '[가이드액션] 시승_프로모션_생성_종료_확정 알림';
    // Schedule Cron Expression (매월 8시 00분)
    private static String batchCron = '0 0 8 * * ? *';
    // Batch 수행 Size
    private static Integer batchSize = 200;

    /**
     * 배치 실행 멤버 함수(override)
     *
     * @param SC : SchedulableContext
     */
    public void execute(SchedulableContext SC) {
        GuideActionLeadConfirm_sc.excuteBatch();
    }

    /**
     * 배치 Schedule 등록
     * GuideActionLeadConfirm_sc.runSchedule();
     */
    public static void runSchedule() {
        System.schedule(batchName, batchCron, new GuideActionLeadConfirm_sc());
    }

    /**
     *  배치 Schedule 삭제
     *  GuideActionLeadConfirm_sc.abortSchedule();
     */
    public static void abortSchedule() {
        for (CronTrigger t : [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = :batchName]) {
            if(!Test.isRunningTest())   System.abortJob(t.Id);
        }
    }

    /**
     * 배치 실행(외부 바로 호출)
     * GuideActionLeadConfirm_sc.excuteBatch();
     */
    public static void excuteBatch() {
        Database.executeBatch(new GuideActionLeadConfirm_ba(), batchSize);
    }
}