({
    /**
     * valid Check
     * @param component
     * @param helper
     * @returns {boolean}
     */
    fn_checkValid: function (component, helper) {
        if($A.util.isEmpty(component.get('v.product'))) {
            helper.gfn_toast('제품을 선택하세요.', 'w');
            return false;
        }

        return true;
    }
});