/****************************************************************************************
  * @filename       : NotificationAutomaticTest
  * @projectname    : i2SEMA Core
  * @author         : i2max_byeon.jw
  * @date           : 2020-04-27 오전 10:02
  * @group          : 
  * @group-content  : 
  * @description    : 
  * @tester         : NotificationAutomaticTest_Test.cls
  * @reference      : 
  * @copyright      : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                author              description
  * ===============================================================
    0.1     2020-04-27 오전 10:02     i2max_byeon.jw       Create
****************************************************************************************/

trigger NotificationAutomaticTest on NotificationAutomaticTest__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new i2SEMA_AutomaticNotification_tr().run();
}