/****************************************************************************************
  * @filename      : i2SEMA_IFNotificationSend_sc
  * @projectname   : i2sema
  * @author        : i2max_shlee
  * @date          : 2020/01/31 3:36 PM
  * @group         : Notification
  * @group-content :
  * @description   : Notification Batch Scheduler
  * @tester        : NotificationInterface_sc_ts.cls
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                   author            description
  * ===============================================================
    0.1     2020/01/31 3:36 PM     i2max_shlee       Create
    0.2     2020/04/13 4:17 PM     i2max_shlee       Rename  NotificationInterface_sc > i2SEMA_IFNotificationSend_sc
****************************************************************************************/
public class i2SEMA_IFNotificationSend_sc implements Schedulable {
    /*
    i2SEMA_IFNotificationSend_sc sc = new i2SEMA_IFNotificationSend_sc();
    String sch = '0 0 0 * * ?'; //Class runs every day at 12:00 AM.
    System.schedule('NFB-001 : i2SEMA_IFNotificationSend_sc', sch, sc);
     */

    /**
     * 메세지 전송 인터페이스 스케쥴 실행 함수 
     *
     * @param sc
     */
    public void execute(SchedulableContext sc) {
//        i2SEMA_IFNotificationSend_qu messageQueue = new i2SEMA_IFNotificationSend_qu(notifications);
//        Id messageJobId = System.enqueueJob(messageQueue);
        i2SEMA_IFNotificationSend_ba batch = new i2SEMA_IFNotificationSend_ba();
        if(Test.isRunningTest())
            database.executebatch(batch, 1);
        else
            database.executebatch(batch, 100);
    }
}