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

        /*if(component.get('v.mobileStepVO.bizData.pdi.ETC__c') ==='아니오'){
            helper.gfn_toast('상세 내용을 설명받으세요', 'w');
            return false;
        }*/
         if($A.util.isEmpty(component.get('v.mobileStepVO.bizData.pdi.ETC__c'))){
             helper.gfn_toast('상세 내용을 설명받으세요', 'w');
             return false;
         }

        return true;
    }
});