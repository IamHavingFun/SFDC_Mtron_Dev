/****************************************************************************************
 * @filename      : lsMSalesLeaseInspectionReportCreate1Controller.js
 * @author        : I2MAX
 * @date          : 2021-03-29
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
 1.0     2021-03-29         I2MAX            Create
 ****************************************************************************************/
({
    /**
     * 다음
     * @param component
     * @param event
     * @param helper
     */
    doNextSelf: function (component, event, helper) {
        helper.fn_validCheck(component) ? $A.enqueueAction(component.get('c.doNext')) : helper.gfn_toast('모든 값에 체크를 해주세요', 'w');
    },
});