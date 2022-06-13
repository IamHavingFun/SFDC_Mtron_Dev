/****************************************************************************************
 * @filename      : lsMSalesLeaseInspectionReportController.js
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
     * 초기거래
     * @param component
     * @param event
     * @param helper
     */
    doInit: function (component, event, helper) {
        const assetName = helper.gfn_getQueryStringValue('name');

        helper.apex(
            component, 'doInit', 'init', {
                "assetName" : assetName
            }
        ).then($A.getCallback(function ({resData, response}) {
            //============================================================================
            // 공통으로 사용하는 attribute에 할당
            //============================================================================
            console.log('===========================');
            helper.mfn_setInitVO(component, resData);
            console.log('===========================');
            //============================================================================
            // 공통으로 사용하는 attribute에 할당
            //============================================================================
            console.log('===========================4');
            helper.fn_createStepComponent(component, helper, 0);
            console.log('===========================5');

        })).catch(function ({error, response}) {
            console.log('error ===========================');
            helper.log(error);
            console.log('error ===========================');
            helper.gfn_ApexErrorHandle(error, response);
        });
    },

    /**
     * step change event 핸들러
     *
     * @param component
     * @param event
     * @param helper
     */
    doChangeStep: function (component, event, helper) {
        const message = helper.mfn_getStepChangeEventMessage(event);

        helper.fn_createStepComponent(
            component,
            helper,
            message.targetStep,
            message.componentParams
        );
    },
});