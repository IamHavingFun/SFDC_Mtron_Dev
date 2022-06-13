/**
** @filename     : GuideActionCUPICheck_sc
* @projectname   :
* @author        : CHOI SEONGWON
* @date          : 2020-08-18 오후 4:09
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
public class GuideActionCUPICheck_sc implements Schedulable {
        // Schedule 등록 배치명
        private static String batchName = '[가이드액션] 고객확인_개인정보 활용 미동의건 체크';
        // Schedule Cron Expression (매월 1일 새벽 7시 )
        private static String batchCron = '0 0 7 1 * ? *';
        // Batch 수행 Size
        private static Integer batchSize = 200;

        /**
         * 배치 실행 멤버 함수(override)
         *
         * @param SC : SchedulableContext
         */
        public void execute(SchedulableContext SC) {
            GuideActionCUPICheck_sc.excuteBatch();
        }

        /**
         * 배치 Schedule 등록
         * GuideActionCUPICheck_sc.runSchedule();
         */
        public static void runSchedule() {
            System.schedule(batchName, batchCron, new GuideActionCUPICheck_sc());
        }

        /**
         *  배치 Schedule 삭제
         *  GuideActionCUPICheck_sc.abortSchedule();
         */
        public static void abortSchedule() {
            for (CronTrigger t : [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = :batchName]) {
                if(!Test.isRunningTest())   System.abortJob(t.Id);
            }
        }

        /**
         * 배치 실행(외부 바로 호출)
         * GuideActionCUPICheck_sc.excuteBatch();
         */
        public static void excuteBatch() {
            Database.executeBatch(new GuideActionCUPICheck_ba(), batchSize);
        }
}