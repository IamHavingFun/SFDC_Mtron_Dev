/****************************************************************************************
  * @filename       : i2SEMA_Notification
  * @projectname    : i2SEMA Core
  * @author         : i2max_byeon.jw
  * @date           : 2020-04-14 오후 4:16
  * @group          : 
  * @group-content  : 
  * @description    : 
  * @tester         : i2SEMA_Notification_ts.cls
  * @reference      : 
  * @copyright      : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                author              description
  * ===============================================================
    0.1     2020-04-14 오후 4:16     i2max_byeon.jw       Create
****************************************************************************************/

trigger i2SEMA_Notification on Notification__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new i2SEMA_Notification_tr().run();
}