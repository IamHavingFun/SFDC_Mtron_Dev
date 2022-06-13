/****************************************************************************************
 * @filename      : lsMSalesLeaseInspectionReportCreate3Controller.js
 * @author        : I2MAX
 * @date          : 2021-04-15
 * @group         :
 * @group-content :
 * @description   :
 * @tester        :
 * @reference     :
 * @release       : v1.0.0
 * @copyright     : Copyright © I2max. All Rights Reserved.
 * @modification Log
 * ===============================================================
 * ver     date                    author         description
 * ===============================================================
 1.0     2021-04-15         I2MAX            Create
 ****************************************************************************************/
({
    /**
     * Init
     *
     * @param component
     * @param event
     * @param helper
     */
    doAfterUploadFinished: function (component, event, helper) {
        helper.fn_afterUploadFinished(component, event);
    },

    doClose : function (component, event, helper) {
        helper.fn_close(component);
    },
});