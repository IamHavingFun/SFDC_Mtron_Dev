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

        if( $A.util.isEmpty(component.get('v.mobileStepVO.bizData.pdi.Education1__c'))
            ||$A.util.isEmpty(component.get('v.mobileStepVO.bizData.pdi.Education2__c'))
            ||$A.util.isEmpty(component.get('v.mobileStepVO.bizData.pdi.Education3__c'))
            ||$A.util.isEmpty(component.get('v.mobileStepVO.bizData.pdi.Education4__c'))
            ||$A.util.isEmpty(component.get('v.mobileStepVO.bizData.pdi.Education5__c'))
            ||$A.util.isEmpty(component.get('v.mobileStepVO.bizData.pdi.Education6__c'))
            ||$A.util.isEmpty(component.get('v.mobileStepVO.bizData.pdi.Education7__c'))
            ||$A.util.isEmpty(component.get('v.mobileStepVO.bizData.pdi.Education8__c'))
            ||$A.util.isEmpty(component.get('v.mobileStepVO.bizData.pdi.Education9__c'))
            ){
                helper.gfn_toast('빠진 부분을 체크해 주세요.', 'w');
                return false;
            }
        /*if($A.util.isEmpty(component.get('v.mobileStepVO.bizData.pdi.Education1__c'))) {
            helper.gfn_toast('빠진 부분 체크.', 'w');
            return false;
        }
        if($A.util.isEmpty(component.get('v.mobileStepVO.bizData.pdi.Education2__c'))) {
            helper.gfn_toast('빠진 부분 체크.', 'w');
            return false;
        }
        if($A.util.isEmpty(component.get('v.mobileStepVO.bizData.pdi.Education3__c'))) {
            helper.gfn_toast('빠진 부분 체크.', 'w');
            return false;
        }
        if($A.util.isEmpty(component.get('v.mobileStepVO.bizData.pdi.Education4__c'))) {
            helper.gfn_toast('빠진 부분 체크.', 'w');
            return false;
        }
        if($A.util.isEmpty(component.get('v.mobileStepVO.bizData.pdi.Education5__c'))) {
            helper.gfn_toast('빠진 부분 체크.', 'w');
            return false;
        }
        if($A.util.isEmpty(component.get('v.mobileStepVO.bizData.pdi.Education6__c'))) {
            helper.gfn_toast('빠진 부분 체크.', 'w');
            return false;
        }
        if($A.util.isEmpty(component.get('v.mobileStepVO.bizData.pdi.Education7__c'))) {
            helper.gfn_toast('빠진 부분 체크.', 'w');
            return false;
        }
        if($A.util.isEmpty(component.get('v.mobileStepVO.bizData.pdi.Education8__c'))) {
            helper.gfn_toast('빠진 부분 체크.', 'w');
            return false;
        }
        if($A.util.isEmpty(component.get('v.mobileStepVO.bizData.pdi.Education9__c'))) {
            helper.gfn_toast('빠진 부분 체크.', 'w');
            return false;
        }*/

        return true;
    }
});