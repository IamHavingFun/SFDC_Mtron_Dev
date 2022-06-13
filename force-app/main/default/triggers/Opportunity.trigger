/**
 * Created by MS on 2020-07-31.
 */

trigger Opportunity on Opportunity (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new Opportunity_tr().run();
}