/**
 * Created by MS on 2020-08-28.
 */

trigger Contract on Contract__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	new Contract_tr().run();
	new i2SEMA_AutomaticNotification_tr().run();
}