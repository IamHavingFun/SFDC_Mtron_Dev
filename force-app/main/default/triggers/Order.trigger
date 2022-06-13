/**
 * Created by MS on 2020-06-25.
 */

trigger Order on Order__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new Order_tr().run();
}