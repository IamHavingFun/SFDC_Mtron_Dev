/****************************************************************************************
 * @filename      : orderTransferSearchQaController.js
 * @projectname   :
 * @author        : i2max_my.Seo
 * @date          : 2020-11-19 오후 1:14
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
   0.1     2020-11-19 오후 1:14    i2max_my.Seo          Create
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

    /**
     * Search
     *
     * @param component
     * @param event
     * @param helper
     */
    doSearch : function (component, event, helper) {
        helper.fn_search(component);
    },

    /**
     * Asset select
     *
     * @param component
     * @param event
     * @param helper
     */
    doSelect : function (component, event, helper) {
        helper.fn_select(component);
    },

    /**
     * Valid multi check
     *
     * @param component
     * @param event
     * @param helper
     */
    doCheckMultiSelect : function (component, event, helper) {
        helper.fn_checkMultiSelect(component, event);
    },
});