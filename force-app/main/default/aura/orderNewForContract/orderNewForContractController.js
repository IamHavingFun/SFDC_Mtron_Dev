/****************************************************************************************
 * @filename      : orderNewForContractController.js
 * @projectname   :
 * @author        : i2max_my.Seo
 * @date          : 2020-12-14 오후 2:12
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
 0.1     2020-12-14 오후 2:12    i2max_my.Seo          Create
 ****************************************************************************************/
({
    /**
     * Init
     *
     * @param component
     * @param event
     * @param helper
     */
    doInit: function (component, event, helper) {
        helper.fn_init(component);
    },

    doSave : function (component, event, helper) {
        helper.fn_save(component);
    },

    doMoveSearchList : function (component, event, helper) {
        helper.fn_moveSearchList(component);
    },

    doGetSoldTo : function (component, event, helper) {
        helper.fn_getSoldTo(component);
    },
});