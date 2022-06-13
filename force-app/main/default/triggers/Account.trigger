/**
 * Created by ms on 2020-03-31.
 */

trigger Account on Account (before insert, before update, before delete, after insert, after update, after delete) {
    new Account_tr().run();
    new i2SEMA_AutomaticNotification_tr().run();
}