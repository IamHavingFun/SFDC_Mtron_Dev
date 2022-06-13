/**
 * Created by MS on 2020-07-03.
 */

({
    doInit : function(component, event, helper){
        const assetName = helper.gfn_getQueryStringValue('name');
        helper.apex(
            component, 'doInit', 'init', {
                'assetName': assetName
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
            if(resData.bizData.isUnkwonCustomer === true) {
                console.log('===========================4');
                helper.fn_createStepComponent(component, helper, 0);
            } else {
                console.log('===========================5');
                helper.fn_createStepComponent(component, helper, 1);
            }
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
        const message = helper.mfn_getStepChangeEventMessage(event);

        helper.fn_createStepComponent(
            component,
            helper,
            message.targetStep,
            message.componentParams
        );
    },

});