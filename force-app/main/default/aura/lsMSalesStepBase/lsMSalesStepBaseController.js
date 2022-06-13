/****************************************************************************************
 * @filename      : lsMSalesStepBaseController.js
 * @projectname   :
 * @author        : i2max_my.Seo
 * @date          : 2020-06-05 오후 12:51
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
 0.1     2020-06-05 오후 12:51    i2max_my.Seo          Create
 ****************************************************************************************/
({
    /**
     * 공통 : step 단계별 컴포넌트 이전 컴포넌트 호출
     * @param component
     * @param event
     * @param helper
     */
    doPrev: function (component, event, helper) {
        component.getEvent('changeStep').setParams({
            message: {
                'targetStep': component.get('v.step')-1
            }
        }).fire();
    },

    /**
     * 공통 : step 단계별 컴포넌트 다음 컴포넌트 호출
     *
     * @param component
     * @param event
     * @param helper
     */
    doNext: function (component, event, helper) {
        component.getEvent('changeStep').setParams({
            message: {
                'targetStep': component.get('v.step')+1
            }
        }).fire();
    },
});