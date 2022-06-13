/**
 * Created by MS on 2020-06-24.
 */

({
    /**
     * valid Check
     * @param component
     * @param helper
     * @returns {boolean}
     */
    fn_checkValid: function (component, helper) {

        if( $A.util.isEmpty(component.get('v.mobileStepVO.bizData.pdi.Check1_1__c'))
            ||$A.util.isEmpty(component.get('v.mobileStepVO.bizData.pdi.Check1_2__c'))
            ||$A.util.isEmpty(component.get('v.mobileStepVO.bizData.pdi.Check1_3__c'))
            ||$A.util.isEmpty(component.get('v.mobileStepVO.bizData.pdi.Check1_4__c'))
            ||$A.util.isEmpty(component.get('v.mobileStepVO.bizData.pdi.Check1_5__c'))
            ||$A.util.isEmpty(component.get('v.mobileStepVO.bizData.pdi.Check1_6__c'))
            ||$A.util.isEmpty(component.get('v.mobileStepVO.bizData.pdi.Check1_7__c'))
            ||$A.util.isEmpty(component.get('v.mobileStepVO.bizData.pdi.Check1_8__c'))
            ||$A.util.isEmpty(component.get('v.mobileStepVO.bizData.pdi.Check1_9__c'))
            ){
                helper.gfn_toast('빠진 부분을 체크해 주세요.', 'w');
                return false;
            }

        return true;
    }
});