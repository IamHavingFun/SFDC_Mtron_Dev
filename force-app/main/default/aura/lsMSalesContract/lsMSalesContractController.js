/****************************************************************************************
 * @filename      : lsMSalesContractController.js
 * @projectname   :
 * @author        : i2max_my.Seo
 * @date          : 2020-06-24 오전 7:31
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
 0.1     2020-06-24 오전 7:31    i2max_my.Seo          Create
 ****************************************************************************************/
({
    /**
     * 초기거래
     * @param component
     * @param event
     * @param helper
     */
    doInit: function (component, event, helper) {
        helper.apex(
            component, 'doInit', 'getDataForNewContract', {
                'quoteId' : component.get('v.recordId')
            }
        ).then(function ({resData, response}) {
            //============================================================================
            // 공통으로 사용하는 attribute에 할당
            //============================================================================
            helper.mfn_setInitVO(component, resData);
            //============================================================================
            // 공통으로 사용하는 attribute에 할당
            //============================================================================
            helper.fn_createStepComponent(component, helper, 0);
        }).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error, response);
        });
        // console.log('==============> enter contract init');
        // const pageReference = helper.fn_getUrlParams();
        // console.log('==============> pageReference : ' + pageReference.c__quoteId);
        // // console.log('==============> ' + pageReference.state.c__quoteId);
        // helper.fn_createStepComponent(component, helper, 0);
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