/**
 * Created by MS on 2020-07-02.
 */

({
    fn_checkValid: function (component, helper) {
        if($A.util.isEmpty(component.get('v.mobileStepVO.bizData.contract'))) {
            helper.gfn_toast('계약을 선택하세요.', 'w')
            return false;
        }
        return true;
    }
});