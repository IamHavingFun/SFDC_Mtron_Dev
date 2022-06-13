/****************************************************************************************
  * @filename      : Dummy_IF_KR_SE_LWS_0035_sc
  * @projectname   : 
  * @author        : i2max 
  * @date          : 2020-07-06
  * @group         : 
  * @group-content : 
  * @description   : 8시 부터 2시간 단위로 오후 11시까지.
  * @tester        : Dummy_IF_KR_SE_LWS_0035_sc_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author              description
  * ===============================================================
    0.1     2020-07-06               i2max                  Create
*************a***************************************************************************/
public class Dummy_IF_KR_SE_LWS_0035_sc implements Schedulable{

    // Batch 수행 Size
    private static Integer batchSize = 200;

    /**
     * 배치 실행 멤버 함수(override)
     *
     * @param SC : SchedulableContext
     */
    public void execute(SchedulableContext SC) {
        Dummy_IF_KR_SE_LWS_0035_sc.excuteBatch();
    }

    /**
     * 배치 Schedule 등록
     * Dummy_IF_KR_SE_LWS_0035_sc.runSchedule();
     */
    public static void runSchedule() {
        System.schedule('LWS로 고객정보 전송-08시', '0 0 8 * * ? *', new Dummy_IF_KR_SE_LWS_0035_sc());
        System.schedule('LWS로 고객정보 전송-10시', '0 0 10 * * ? *', new Dummy_IF_KR_SE_LWS_0035_sc());
        System.schedule('LWS로 고객정보 전송-12시', '0 0 12 * * ? *', new Dummy_IF_KR_SE_LWS_0035_sc());
        System.schedule('LWS로 고객정보 전송-14시', '0 0 14 * * ? *', new Dummy_IF_KR_SE_LWS_0035_sc());
        System.schedule('LWS로 고객정보 전송-16시', '0 0 16 * * ? *', new Dummy_IF_KR_SE_LWS_0035_sc());
        System.schedule('LWS로 고객정보 전송-18시', '0 0 18 * * ? *', new Dummy_IF_KR_SE_LWS_0035_sc());
        System.schedule('LWS로 고객정보 전송-20시', '0 0 20 * * ? *', new Dummy_IF_KR_SE_LWS_0035_sc());
        System.schedule('LWS로 고객정보 전송-23시', '0 0 23 * * ? *', new Dummy_IF_KR_SE_LWS_0035_sc());
    }

    /**
     *  배치 Schedule 삭제
     *  Dummy_IF_KR_SE_LWS_0035_sc.abortSchedule();
     */
    public static void abortSchedule() {
        for (CronTrigger t : [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name LIKE 'LWS로 고객정보 전송%']) {
            if (!Test.isRunningTest()) System.abortJob(t.Id);
        }
    }

    /**
     * 배치 실행(외부 바로 호출)
     * Dummy_IF_KR_SE_LWS_0035_sc.excuteBatch();
     */
    public static void excuteBatch() {
        Database.executeBatch(new Dummy_IF_KR_SE_LWS_0035_ba(), batchSize);
    }
}