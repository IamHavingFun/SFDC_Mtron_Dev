({
    /**
     * 초기거래
     * @param component
     * @param event
     * @param helper
     */
    doInit: function (component, event, helper) {
        helper.apex(
            component, 'doInit', 'init', {}, false, true
        ).then($A.getCallback(function ({resData, response}) {
            //============================================================================
            // 공통으로 사용하는 attribute에 할당
            //============================================================================
            helper.mfn_setInitVO(component, resData);
            //============================================================================
            // 공통으로 사용하는 attribute에 할당
            //============================================================================
            helper.fn_createStepComponent(component, helper, 0);
        })).catch(function ({error, response}) {
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

        helper.log(component, 'message : ', JSON.stringify(message));

        helper.fn_createStepComponent(
            component,
            helper,
            message.targetStep,
            message.componentParams
        );
    },

});