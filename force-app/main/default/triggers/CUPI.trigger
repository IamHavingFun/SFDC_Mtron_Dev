/**
 * Created by MS on 2020-08-21.
 */

trigger CUPI on CUPI__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	new i2SEMA_AutomaticNotification_tr().run();
}