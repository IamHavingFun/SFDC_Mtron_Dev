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
        if( $A.util.isEmpty(component.get('v.mobileStepVO.bizData.pdi.Check2_1__c'))
            ||$A.util.isEmpty(component.get('v.mobileStepVO.bizData.pdi.Check2_2__c'))
            ||$A.util.isEmpty(component.get('v.mobileStepVO.bizData.pdi.Check2_3__c'))
            ||$A.util.isEmpty(component.get('v.mobileStepVO.bizData.pdi.Check2_4__c'))
            ||$A.util.isEmpty(component.get('v.mobileStepVO.bizData.pdi.Check2_5__c'))
            /*||$A.util.isEmpty(component.get('v.mobileStepVO.bizData.pdi.Check2_6__c'))*/
            ||$A.util.isEmpty(component.get('v.mobileStepVO.bizData.pdi.Check2_7__c'))
            ||$A.util.isEmpty(component.get('v.mobileStepVO.bizData.pdi.Check2_8__c'))
            ){
                helper.gfn_toast('빠진 부분을 체크해 주세요.', 'w');
                return false;
            }

        return true;
    }
});