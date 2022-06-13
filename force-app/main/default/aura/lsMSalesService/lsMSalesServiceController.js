/****************************************************************************************
 * @filename      : lsMSalesServiceController.js
 * @projectname   :
 * @author        : i2max_my.Seo
 * @date          : 2020-06-05 오전 11:26
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
 0.1     2020-06-05 오전 11:26    i2max_my.Seo          Create
 ****************************************************************************************/
({
    /**
     * Step Component 생성
     * @param component
     * @param event
     * @param helper
     */
    doCreateStepComponent: function (component, event, helper) {
        const params = event.getParam('arguments');

        helper.log(component, 'lsMSalesService doCreateStepComponent params : ', JSON.stringify(params));

        if (params && !$A.util.isEmpty(params)) {
            let createName, componentParams, callback, targetComponent;

            createName = params.createName;
            // 실제 컴포넌트 추가 params
            componentParams = params.createParams.componentParams || params.createParams;
            callback = params.callback;
            //============================================================================
            // Target이 되는 Component
            // 1. spinner 영역지정용도
            //============================================================================
            targetComponent = params.targetComponent;

            const self = helper;

            //!$A.util.isEmpty(targetComponent) && self.gfn_showSpinner(targetComponent, null);

            $A.createComponents([
                    [
                        "c:" + createName,
                        componentParams
                    ]
                ],
                $A.getCallback(function(components, status, errorMessage){

                    //!$A.util.isEmpty(targetComponent) && self.gfn_hideSpinner(targetComponent, null);

                    if (status === "SUCCESS") {
                        if(callback && components.length > 0)    callback(components[0]);
                    }
                    else if (status === "INCOMPLETE") {
                        helper.gfn_ApexErrorHandle(Error("No response from server or client is offline."));
                    }
                    else if (status === "ERROR") {
                        helper.gfn_ApexErrorHandle(Error(errorMessage));
                    }
                })
            );
        }

    },
});