/****************************************************************************************
 * @filename      : lsMSalesSearchContractHelper.js
 * @projectname   :
 * @author        : i2max_my.Seo
 * @date          : 2020-06-29 오전 11:31
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
 0.1     2020-06-29 오전 11:31    i2max_my.Seo          Create
 ****************************************************************************************/
({
    /**
     * Step 업무별로 CreatedComponent 의 생성 파라미터
     * @param component
     * @param helper
     * @param step
     * @returns {{mobileStepVO: PropertyReferenceValue, "aura:id": *, step: *}}
     */
    fn_getStepParams : function (component, helper, step) {
        return {
            'aura:id': component.getName(),
            'mobileStepVO': helper.mfn_getMobileStepVO(component),
            'step': step
        }
    },

    /**
     * step 컴포넌트를 동적으로 생성
     *
     * @param component
     * @param helper
     * @param targetStep
     */
    fn_createStepComponent: function (component, helper, targetStep) {
        component.find('lsMSalesService').doCreateStepComponent(
            component.get('v.stepList')[targetStep],
            helper.fn_getStepParams(component, helper, targetStep),
            function(createdStepComponent) {
                helper.mfn_injectCreatedStepComponent(component, createdStepComponent);
            },
            component
        );
    }
});