/**
 * Created by MS on 2020-06-25.
 */

trigger Lead on Lead (before insert, before update, before delete, after insert, after update, after delete) {
    new LeadPromotion_tr().run();
    new i2SEMA_AutomaticNotification_tr().run();
}