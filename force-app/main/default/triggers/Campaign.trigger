/**
 * Created by MS on 2020-08-11.
 */

trigger Campaign on Campaign (before update, after update) {
    new Campaign_tr().run();
}