/****************************************************************************************
 * @filename      : lsMSalesStepContainerBaseHelper.js
 * @projectname   :
 * @author        : i2max_my.Seo
 * @date          : 2020-06-05 오후 12:54
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
 0.1     2020-06-05 오후 12:54    i2max_my.Seo          Create
 ****************************************************************************************/
({
    /**
     * 공통 MobileStepVO Reference
     * @param component
     * @returns {PropertyReferenceValue}
     */
    mfn_getMobileStepVO: function (component) {
        return component.getReference('v.mobileStepVO');
    },

    /**
     * 공통 attribute에 데이터 세팅
     * @param component
     * @param resData
     */
    mfn_setInitVO: function (component, resData) {
        component.set('v.mobileStepVO', resData);
    },

    /**
     * 공통 : Step 변경 이벤트시 공통 파라미터 구함
     * @param event
     * @returns {Object}
     */
    mfn_getStepChangeEventMessage: function (event) {
        return event.getParam('message');
    },

    /**
     * Step Container에 생성된 Step Component를 주입
     * @param component
     * @param createdStepComponent
     * @param stepContainerId
     */
    mfn_injectCreatedStepComponent: function (component, createdStepComponent, stepContainerId) {
        const targetStepContainerId = stepContainerId || 'stepContainer';
        component.find(targetStepContainerId).set("v.body", createdStepComponent);
    }
});