({
    /**
     * valid Check
     * @param component
     * @param helper
     * @returns {boolean}
     */
    fn_checkValid: function (component, helper) {

/*
        if($A.util.isEmpty(component.get('v.mobileStepVO.infoData.searchProductSeries.HorsePower__c'))) {
            helper.gfn_toast('마력을 선택하세요.', 'w');
            return false;
        }
        if($A.util.isEmpty(component.get('v.mobileStepVO.infoData.searchProductSeries.Option1__c'))) {
            helper.gfn_toast('옵션1 선택하세요.', 'w');
            return false;
        }
        if($A.util.isEmpty(component.get('v.mobileStepVO.infoData.searchProductSeries.Option2__c'))) {
            helper.gfn_toast('옵션2 선택하세요.', 'w');
            return false;
        }
        if($A.util.isEmpty(component.get('v.mobileStepVO.infoData.searchProductSeries.Option3__c'))) {
            helper.gfn_toast('옵션3 선택하세요.', 'w');
            return false;
        }
        if($A.util.isEmpty(component.get('v.mobileStepVO.infoData.searchProductSeries.Option4__c'))) {
            helper.gfn_toast('옵션4 선택하세요.', 'w');
            return false;
        }
*/

        if($A.util.isEmpty(component.get('v.mobileStepVO.bizData.productVO.product'))) {
            helper.gfn_toast('제품을 선택하세요.', 'w');
            return false;
        }

        return true;
    }
});