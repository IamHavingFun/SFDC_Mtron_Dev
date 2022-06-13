/**
 * Created by MS on 2020-08-07.
 */

trigger CaseTrigger on Case (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	new i2SEMA_AutomaticNotification_tr().run();
}