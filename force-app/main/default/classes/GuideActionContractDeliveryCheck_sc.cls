/****************************************************************************************
 * @filename      : GuideActionContractDeliveryCheck_sc
 * @projectname   : 
 * @author        : SEOKHO LEE
 * @date          : 2020-08-18 오후 4:58
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
 0.1     2020-08-18 오후 4:58        SEOKHO LEE          Create
 ****************************************************************************************/

public class GuideActionContractDeliveryCheck_sc implements Schedulable {
    // Schedule 등록 배치명
    private static String batchName = '[가이드액션] 계약확인_PDI_리스_융자금';
    // Schedule Cron Expression (매일 새벽 8시 30분)
    private static String batchCron = '0 30 8 * * ? *';
    // Batch 수행 Size
    private static Integer batchSize = 200;

    /**
     * 배치 실행 멤버 함수(override)
     *
     * @param SC : SchedulableContext
     */
    public void execute(SchedulableContext SC) {
        GuideActionContractDeliveryCheck_sc.excuteBatch();
    }

    /**
     * 배치 Schedule 등록
     */
    public static void runSchedule() {
        System.schedule(batchName, batchCron, new GuideActionContractDeliveryCheck_sc());
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
     * Dummy_IF_KR_ERP_SE_0014_sc.excuteBatch();
     */
    public static void excuteBatch() {
        Database.executeBatch(new GuideActionContractDeliveryCheck_ba(), batchSize);
    }
}