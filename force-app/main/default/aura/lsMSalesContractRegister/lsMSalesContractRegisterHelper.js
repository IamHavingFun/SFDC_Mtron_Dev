/****************************************************************************************
 * @filename      : lsMSalesContractRegisterHelper.js
 * @projectname   :
 * @author        : i2max_my.Seo
 * @date          : 2020-06-29 오후 2:40
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
 0.1     2020-06-29 오후 2:40    i2max_my.Seo          Create
 ****************************************************************************************/
({
    /**
     * 총 가격과 계약 금액의 합들이 일치 하는지 체크 하는 function.
     *
     * @param component
     * @param event
     * @param helper
     * @returns {boolean}
     */
    fn_checkPriceValid : function (component, event, helper) {
        const contract = component.get('v.mobileStepVO.bizData.contract');

        if(parseInt(contract.TotalPrice__c) !== parseInt(contract.ContractAmt__c) + parseInt(contract.LoanContractAmt__c)
                                      + parseInt(contract.SubsidyContractAmt__c) + parseInt(contract.LeaseContractAmt__c)
                                      + parseInt(contract.SelfPayContractAmt__c) + parseInt(contract.UsedUndertakingAmt__c)
        ) {
            helper.gfn_toast('총 계약 금액과 금액의 합이 일치 하지 않습니다.', 'e');
            return false;
        }

        return true;
    },

    /**
     * 기존 data에서 수정된 값이 있는지 없는지 체크 하는 function.
     * 
     * @param component
     * @returns {boolean}
     */
    fn_checkChangedData : function (component) {
        const unchangedData = component.get('v.mobileStepVO.unchangedData');
        const targetData    = component.get('v.mobileStepVO');
        let   isChanged     = false;

        // Contact 비교
        if(JSON.stringify(unchangedData.unchangedContract) !== JSON.stringify(targetData.bizData.contract)) {
            isChanged = true;
        }

        //인도 기일 비교
        if(unchangedData.unchangedTempCusYear !== targetData.dateData.tempCustomerYear) {
            isChanged = true;
        }
        if(unchangedData.unchangedTempCusMonth !== targetData.dateData.tempCustomerMonth) {
            isChanged = true;
        }
        if(unchangedData.unchangedTempCusDay !== targetData.dateData.tempCustomerDay) {
            isChanged = true;
        }

        return isChanged;
    },

    fn_calculateTotalPrice : function (component) {
        const contract = component.get('v.mobileStepVO.bizData.contract');
        let totalPrice = this.fn_checkNumber(contract.ContractAmt__c) + this.fn_checkNumber(contract.LoanContractAmt__c) + this.fn_checkNumber(contract.SubsidyContractAmt__c)
                         + this.fn_checkNumber(contract.LeaseContractAmt__c) + this.fn_checkNumber(contract.SelfPayContractAmt__c) + this.fn_checkNumber(contract.UsedUndertakingAmt__c);

        component.set('v.totalViewPrice', totalPrice);
    },

    fn_checkNumber : function (targetNumber) {
        return ($A.util.isEmpty(parseInt(targetNumber)) || isNaN(parseInt(targetNumber))) ? 0 : parseInt(targetNumber);
    },

    contractOrgData : null
});