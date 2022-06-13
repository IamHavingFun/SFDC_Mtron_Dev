({
    /**
     * 초기거래
     * @param component
     * @param event
     * @param helper
     */
    doInit: function (component, event, helper) {
        helper.apex(
            component, 'doInit', 'init', {}
        ).then(function ({resData, response}) {

            //============================================================================
            // 공통으로 사용하는 attribute에 할당
            //============================================================================
            helper.mfn_setInitVO(component, resData);
            //============================================================================
            // bizData에 productType 할당
            //============================================================================
            const proudctType = component.get('v.productType');
            component.set('v.mobileStepVO.bizData.productType', proudctType);
            //============================================================================
            // 공통으로 사용하는 attribute에 할당
            //============================================================================
            helper.fn_createStepComponent(component, helper, 0);
        }).catch(function ({error, response}) {
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
        helper.fn_createStepComponent(component, helper, helper.mfn_getStepChangeEventMessage(event).targetStep);
    },

});