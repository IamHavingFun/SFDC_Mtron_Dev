/****************************************************************************************
 * @filename      : lsMSalesContractAmtQaHelper.js
 * @projectname   :
 * @author        : i2max_my.Seo
 * @date          : 2020-06-27 오후 6:42
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
 0.1     2020-06-27 오후 6:42    i2max_my.Seo          Create
 ****************************************************************************************/
({
    /**
     * 금액 종류에 따라 금액 세팅.
     *
     * @param component
     */
    fn_getAmountByType : function (component) {
        const contract = component.get('v.mobileStepVO.bizData.contract');

        let totalPrice = component.get('v.totalPrice');
        let changedPrice = 0;

        let amt = 0;

        switch (component.get('v.amtType')) {
            case '계약금'  : amt = contract.ContractAmt__c;
                changedPrice = totalPrice - contract.LoanContractAmt__c - contract.SubsidyContractAmt__c
                            - contract.LeaseContractAmt__c - contract.SelfPayContractAmt__c - contract.UsedUndertakingAmt__c;
                            break;
            case '융자금'  : amt = contract.LoanContractAmt__c;
                changedPrice = totalPrice - contract.ContractAmt__c - contract.SubsidyContractAmt__c - contract.LeaseContractAmt__c
                            - contract.SelfPayContractAmt__c - contract.UsedUndertakingAmt__c;
                            break;
            case '보조금'  : amt = contract.SubsidyContractAmt__c;
                changedPrice = totalPrice - contract.ContractAmt__c - contract.LoanContractAmt__c - contract.LeaseContractAmt__c
                            - contract.SelfPayContractAmt__c - contract.UsedUndertakingAmt__c;
                            break;
            case '리스'    : amt = contract.LeaseContractAmt__c;
                changedPrice = totalPrice - contract.ContractAmt__c - contract.LoanContractAmt__c - contract.SubsidyContractAmt__c
                            - contract.SelfPayContractAmt__c - contract.UsedUndertakingAmt__c;
                            break;
            case '자부담'  : amt = contract.SelfPayContractAmt__c;
                changedPrice = totalPrice - contract.ContractAmt__c - contract.LoanContractAmt__c - contract.SubsidyContractAmt__c
                            - contract.LeaseContractAmt__c - contract.UsedUndertakingAmt__c;
                            break;
            case '중고인수' : amt = contract.UsedUndertakingAmt__c;
                changedPrice = totalPrice - contract.ContractAmt__c - contract.LoanContractAmt__c - contract.SubsidyContractAmt__c
                            - contract.LeaseContractAmt__c - contract.SelfPayContractAmt__c;
                            break;
            default : return;
        }

        component.set('v.amount', amt);
        component.set('v.mobileStepVO.bizData.contract', contract);
        component.set('v.changedPrice', changedPrice);
    },

    /**
     * 금액 종류에 따른 실제 계약 금액 세팅.
     *
     * @param component
     */
    fn_setAmountByType : function (component) {
        let tempAmt = component.get('v.amount');

        const contract = component.get('v.mobileStepVO.bizData.contract');

        tempAmt = $A.util.isEmpty(tempAmt) ? 0 : parseInt(tempAmt);

        switch (component.get('v.amtType')) {
            case '계약금'      : contract.ContractAmt__c = tempAmt; break;
            case '융자금'      : contract.LoanContractAmt__c = tempAmt; break;
            case '보조금'      : contract.SubsidyContractAmt__c = tempAmt; break;
            case '리스'       : contract.LeaseContractAmt__c = tempAmt; break;
            case '자부담'      : contract.SelfPayContractAmt__c = tempAmt; break;
            case '중고인수'     : contract.UsedUndertakingAmt__c = tempAmt; break;
            default : return;
        }
    },

    /**
     * 각 금액의 변화 되기 전 값을 세팅 하기 위한 function.
     *
     * @param component
     */
    fn_getInitAmountByType : function (component) {
        let tempAmt = 0;

        const contract = component.get('v.mobileStepVO.bizData.contract');

        switch (component.get('v.amtType')) {
            case '계약금'      : tempAmt = contract.ContractAmt__c; break;
            case '융자금'      : tempAmt = contract.LoanContractAmt__c; break;
            case '보조금'      : tempAmt = contract.SubsidyContractAmt__c; break;
            case '리스'       : tempAmt = contract.LeaseContractAmt__c; break;
            case '자부담'      : tempAmt = contract.SelfPayContractAmt__c; break;
            case '중고인수'     : tempAmt = contract.UsedUndertakingAmt__c; break;
            default : return;
        }

        component.set('v.initAmount', tempAmt);
    },

    /**
     * 취소 버튼 시, 변화 되기 전 초기 값을 다시 세팅 하는 function.
     *
     * @param component
     */
    fn_setInitAmountByType : function (component) {
        let tempAmt = component.get('v.initAmount');

        const contract = component.get('v.mobileStepVO.bizData.contract');

        switch (component.get('v.amtType')) {
            case '계약금'      : contract.ContractAmt__c = tempAmt; break;
            case '융자금'      : contract.LoanContractAmt__c = tempAmt; break;
            case '보조금'      : contract.SubsidyContractAmt__c = tempAmt; break;
            case '리스'       : contract.LeaseContractAmt__c = tempAmt; break;
            case '자부담'      : contract.SelfPayContractAmt__c = tempAmt; break;
            case '중고인수'     : contract.UsedUndertakingAmt__c = tempAmt; break;
            default : return;
        }

        component.set('v.mobileStepVO.bizData.contract', contract);
    },

    fn_checkValidByType : function (component, event, helper, amtType) {

        const amt = component.get('v.amount');
        const mobileStepVO = component.get('v.mobileStepVO');

        if(amt < 0) {
            helper.gfn_toast('금액이 0보다 작을 수 없습니다.', 'w');
            return true;
        }

        if(amtType === '중고인수') {
            // Valid Check.
            if((!$A.util.isEmpty(amt) && parseInt(amt) !== 0) && ($A.util.isEmpty(mobileStepVO.bizData.contract.Company__c) || $A.util.isEmpty(mobileStepVO.bizData.contract.UsedUndertakingModel__c) || $A.util.isEmpty(mobileStepVO.bizData.contract.UsedUndertakingYear__c))) {
                helper.gfn_toast('제조사 또는 연식 또는 모델명을 입력해주세요.', 'w');
                return true;
            }

            if($A.util.isEmpty(amt) || parseInt(amt) === 0) {
                mobileStepVO.bizData.contract.Company__c                = '';
                mobileStepVO.bizData.contract.UsedUndertakingModel__c   = '';
                mobileStepVO.bizData.contract.UsedUndertakingYear__c    = '';
            }
        }
        else {
            // Valid Check.
            if ((!$A.util.isEmpty(amt) && parseInt(amt) !== 0) &&
                ($A.util.isEmpty(mobileStepVO.dateData.tempAmtYear)
                || $A.util.isEmpty(mobileStepVO.dateData.tempAmtMonth)
                || $A.util.isEmpty(mobileStepVO.dateData.tempAmtDay))) {
                helper.gfn_toast('날짜를 입력해 주세요.', 'w');
                return true;
            }

            if($A.util.isEmpty(amt) || parseInt(amt) === 0) {
                mobileStepVO.dateData.tempAmtYear = '';
                mobileStepVO.dateData.tempAmtMonth = '';
                mobileStepVO.dateData.tempAmtDay = '';
            }

            if(amtType === '융자금') {
                mobileStepVO.bizData.quote.TotalLoanLimit__c = mobileStepVO.bizData.quote.TotalLoanLimit__c || 0;

                if(mobileStepVO.bizData.quote.TotalLoanLimit__c === 0) {
                    return false;
                }

                if(amt - mobileStepVO.bizData.quote.TotalLoanLimit__c > 0) {
                    helper.gfn_toast('융자한도가 초과하였습니다.', 'w');
                    return true;
                }
            }
        }

        return false;
    },

    fn_setTotalViewPrice : function (component, resData) {
        let totalPrice = this.fn_checkNumber(resData.ContractAmt__c) + this.fn_checkNumber(resData.LoanContractAmt__c) + this.fn_checkNumber(resData.SubsidyContractAmt__c)
                       + this.fn_checkNumber(resData.LeaseContractAmt__c) + this.fn_checkNumber(resData.SelfPayContractAmt__c) + this.fn_checkNumber(resData.UsedUndertakingAmt__c);

        component.set('v.totalViewPrice', totalPrice);
    },

    fn_checkNumber : function (targetNumber) {
        return ($A.util.isEmpty(parseInt(targetNumber)) || isNaN(parseInt(targetNumber))) ? 0 : parseInt(targetNumber);
    },
});