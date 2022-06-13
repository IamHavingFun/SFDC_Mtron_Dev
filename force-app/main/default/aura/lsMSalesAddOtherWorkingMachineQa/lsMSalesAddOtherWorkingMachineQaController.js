/****************************************************************************************
 * @filename      : lsMSalesAddOtherWorkingMachineQaController.js
 * @projectname   :
 * @author        : i2max_my.Seo
 * @date          : 2020-12-18 오후 5:00
 * @group         :
 * @group-content :
 * @description   :
 * @tester        :
 * @reference     :
 * @copyright     : Copyright © I2max. All Rights Reserved.
 * @modification Log
 * ===============================================================
 * ver     date                    author              description
 * ===============================================================
 0.1     2020-12-18 오후 5:00    i2max_my.Seo          Create
 ****************************************************************************************/
({
    doInit : function (component, event, helper) {
        !$A.util.isEmpty(component.get('v.qliWrapper')) && helper.fn_init(component);
    },

    doSave : function (component, event, helper) {
        helper.fn_save(component);
    },

    doModify : function (component, event, helper) {
        helper.fn_modify(component);
    },

    doCancel : function (component, event, helper) {
        helper.fn_cancel(component);
    },
});