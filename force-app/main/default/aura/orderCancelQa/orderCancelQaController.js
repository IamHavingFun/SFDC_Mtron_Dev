/****************************************************************************************
 * @filename      : orderCancelQaController.js
 * @author        : I2MAX
 * @date          : 2021-05-10
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
 1.0     2021-05-10         I2MAX            Create
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
     * Save
     *
     * @param component
     * @param event
     * @param helper
     */
    doSave : function (component, event, helper) {
        const order = component.get('v.order');

        if($A.util.isEmpty(order.SalesDocNo__c) === true) {
            helper.fn_CancelSave(component, helper);
        } else {
            if(order.Division__c == '전수배') {
                // 전수배 주문 ZORT, ZRET, Save
                helper.fn_ZortToSave(component, helper);
            } else {
                // 공장주문 : OR, Save
                helper.fn_OrToSave(component, helper);
            }
        }
    },

});