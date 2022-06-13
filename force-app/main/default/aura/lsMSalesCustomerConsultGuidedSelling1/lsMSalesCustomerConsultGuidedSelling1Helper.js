({
    /**
     * valid Check
     * @param component
     * @param helper
     * @returns {boolean}
     */
    fn_checkValid: function (component, helper) {
        if($A.util.isEmpty(component.get('v.mobileStepVO.bizData.customerVO.customer.RecordTypeId'))) {
            helper.gfn_toast('고객타입을 선택하세요.', 'w');
            return false;
        }

        if($A.util.isEmpty(component.get('v.mobileStepVO.bizData.customerVO.customer.CustomerType__c'))) {
            helper.gfn_toast('사업형태를 선택하세요.', 'w');
            return false;
        }

        if($A.util.isEmpty(component.get('v.mobileStepVO.bizData.prodSerRecStd.FarmingForm__c'))) {
            helper.gfn_toast('사용형태를 선택하세요.', 'w');
            return false;
        }

        const isLivestockBiz = component.get('v.isLivestockBiz');

        if(!isLivestockBiz) {
            if($A.util.isEmpty(component.get('v.mobileStepVO.bizData.prodSerRecStd.FarmingSize__c'))) {
                helper.gfn_toast('영농규모을 선택하세요.', 'w');
                return false;
            }
        }

        return true;
    },

    /**
     * 영농형태에 따른 영농규모 구함
     * @param component
     * @param event
     * @param helper
     */
    fn_getFarmingSizeOptions: function(component, event, helper) {
        helper.apex(
            component, 'doGetFarmingAreaOptions', 'getFarmingSizeOptions', {
                'farmingForm': component.get('v.mobileStepVO.bizData.prodSerRecStd.FarmingForm__c')
            }
        ).then($A.getCallback(function ({resData, response}) {
            component.set('v.farmingSizeOptions', resData);
        })).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error, response);
        });
    }
});