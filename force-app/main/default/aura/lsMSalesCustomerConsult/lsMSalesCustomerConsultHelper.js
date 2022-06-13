({
    /**
     * Step 업무별로 CreatedComponent 의 생성 파라미터
     * @param component
     * @param helper
     * @param step
     * @param componentParams
     * @returns {{mobileStepVO: PropertyReferenceValue, "aura:id": *, step: *, componentParams: *}}
     */
    fn_getStepParams : function (component, helper, step, componentParams) {
        return {
            'aura:id': component.getName(),
            'mobileStepVO': helper.mfn_getMobileStepVO(component),
            'step': step,
            //============================================================================
            // step 컴포넌트 생성에 필요한 요소를 전달
            // componentParams key로 사용할 것
            //============================================================================
            'componentParams': componentParams
        }
    },

    /**
     * step 컴포넌트를 동적으로 생성
     * @param component
     * @param helper
     * @param targetStep
     * @param componentParams
     */
    fn_createStepComponent: function (component, helper, targetStep, componentParams) {
        helper.log(component, 'fn_createStepComponent componentParams : ', componentParams);
        component.find('lsMSalesService').doCreateStepComponent(
            component.get('v.stepList')[targetStep],
            helper.fn_getStepParams(component, helper, targetStep, componentParams),
            function(createdStepComponent) {
                helper.log(component, 'createdStepComponent : ', createdStepComponent);
                !$A.util.isEmpty(createdStepComponent) && helper.mfn_injectCreatedStepComponent(component, createdStepComponent);
            },
            component
        );
    }
});