/**
 * Created by MS on 2020-06-24.
 */

trigger User on User (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new User_tr().run();
}