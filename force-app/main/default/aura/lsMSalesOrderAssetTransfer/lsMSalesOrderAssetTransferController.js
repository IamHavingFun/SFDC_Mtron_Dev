/**
 * Created by MS on 2020-07-01.
 */

({
    doInit : function (component, event, helper) {
        const pageReference = helper.fn_getUrlParams();
        !$A.util.isEmpty(pageReference.tabName) && component.set('v.tabName', pageReference.tabName);
    },

    doTabChange : function (component, event, helper) {
        const tabName = event.currentTarget.dataset.tabid;
        component.set('v.tabName', tabName);
    },
});