/****************************************************************************************
 * @filename      : lsMSalesAccDetailUpdateHelper.js
 * @projectname   :
 * @author        : i2max_my.Seo
 * @date          : 2020-08-14 오후 3:26
 * @group         :
 * @group-content :
 * @description   :
 * @tester        :
 * @reference     :
 * @copyright     : Copyright © I2max. All Rights Reserved.
 * @modification Log
 * ===============================================================
 * ver     date                    author              description
 * ===============================================================
 0.1     2020-08-14 오후 3:26    i2max_my.Seo          Create
 ****************************************************************************************/
({
    fn_checkValid : function (component, event, helper) {
        let isValid = true;
        const mobileStepVO = component.get('v.mobileStepVO');
        // Birthdate Valid Check.
        if($A.util.isEmpty(mobileStepVO.dateData.tempYear) || $A.util.isEmpty(mobileStepVO.dateData.tempMonth) || $A.util.isEmpty(mobileStepVO.dateData.tempDay)) {
            helper.gfn_toast('생년월일을 입력해 주세요.', 'w');
            isValid = false;
        }

        // Address Valid Check.
        if($A.util.isEmpty(mobileStepVO.bizData.quote.CustomerName__r.BillingPostalCode)) {
            helper.gfn_toast('주소를 입력해 주세요.', 'w');
            isValid = false;
        }

        return isValid;
    },
});