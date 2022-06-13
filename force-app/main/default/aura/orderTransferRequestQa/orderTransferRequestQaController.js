/****************************************************************************************
 * @filename      : orderTransferRequestQaController.js
 * @projectname   :
 * @author        : i2max_my.Seo
 * @date          : 2020-11-19 오후 12:29
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
   0.1     2020-11-19 오후 12:29    i2max_my.Seo          Create
 ****************************************************************************************/
({
    /**
     * Init
     *
     * @param component
     * @param event
     * @param helper
     */
    doInit : function (component, event, helper) {
        helper.fn_init(component);
    },

    /**
     * Save
     *
     * @param component
     * @param event
     * @param helper
     */
    doSave : function (component, event, helper) {
        helper.fn_save(component);
    },

    /**
     * Create orderTransferSearchQa modal pop-up
     *
     * @param component
     * @param event
     * @param helper
     */
    doCreateOrderTransferSearchQa : function (component, event, helper) {
        helper.fn_createOrderTransferSearchQa(component);
    },
});