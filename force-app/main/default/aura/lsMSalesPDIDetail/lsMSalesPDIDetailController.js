/**
 * Created by MS on 2020-06-24.
 */
/****************************************************************************************
 * @filename      : lsMSalesPDICreateController.js
 * @projectname   : LS_PS
 * @author        : MS
 * @date          : 2020-06-24 10 55
 * @group         :
 * @group-content :
 * @description   :
 * @tester        :
 * @reference     :
 * @copyright     : Copyright © I2max. All Rights Reserved.
 * @modification Log
 * ===============================================================
 * ver     date                    author          description
 * ===============================================================
 0.1     2020-06-24 10 55       Park He         Create
 ****************************************************************************************/
({
    /**
     * 초기거래
     * @param component
     * @param event
     * @param helper
     */
    doInit: function (component, event, helper) {
        console.log('-----------');
        console.log(component.get('v.recordId'));
        console.log('-----------');
        helper.apex(
            component, 'doInit', 'init', {
                "contractId" : component.get('v.recordId')
            }
        ).then(function ({resData, response}) {
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
        }).catch(function ({error, response}) {
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