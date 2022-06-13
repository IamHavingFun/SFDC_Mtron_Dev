/****************************************************************************************
 * @filename      : lsMSalesLeaseInspectionReportCreate0Helper.js
 * @author        : I2MAX
 * @date          : 2021-03-29
 * @group         :
 * @group-content :
 * @description   :
 * @tester        :
 * @reference     :
 * @release       : v1.0.0
 * @copyright     : Copyright © I2max. All Rights Reserved.
 * @modification Log
 * ===============================================================
 * ver     date                    author        description
 * ===============================================================
 0.1     2021-03-29         I2MAX          Create
 ****************************************************************************************/
({
    fn_checkValid: function (component, helper) {
        if($A.util.isEmpty(component.get('v.mobileStepVO.bizData.contract'))) {
            helper.gfn_toast('계약을 선택하세요.', 'w')
            return false;
        }
        return true;
    }
});