/****************************************************************************************
 * @filename      : lsMSalesContractAmtQaController.js
 * @projectname   :
 * @author        : i2max_my.Seo
 * @date          : 2020-06-27 오후 5:28
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
 0.1     2020-06-27 오후 5:28    i2max_my.Seo          Create
 ****************************************************************************************/
({
    /**
     * Init.
     *
     * @param component
     * @param event
     * @param helper
     */
    doInit: function (component, event, helper) {
        component.set('v.amtType', component.get('v.amtType'));
        component.set('v.initTotalPrice', component.get('v.mobileStepVO.bizDatcontract.TotalPrice__c'));
        helper.fn_getInitAmountByType(component);
        helper.fn_getAmountByType(component);

        helper.apex(
            component, 'doInit', 'init', {
                'contract':component.get('v.mobileStepVO.bizData.contract'),
                'amtType':component.get('v.amtType')
            }
        ).then(function ({resData, response}) {
            component.set('v.mobileStepVO.dateData.tempAmtYear', resData.tempYear);
            component.set('v.mobileStepVO.dateData.tempAmtMonth', resData.tempMonth);
            component.set('v.mobileStepVO.dateData.tempAmtDay', resData.tempDay);
            component.set('v.resData', resData);
        }).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error, response);
        });
    },

    /**
     * 입력 금액이 변경 되었을 때, method.
     *
     * @param component
     * @param event
     * @param helper
     */
    doChange : function (component, event, helper) {
        helper.fn_setAmountByType(component);
    },

    /**
     * 각 금액 저장 눌렀을 때, method.
     *
     * @param component
     * @param event
     * @param helper
     */
    doSave : function (component, event, helper) {
        const type = component.get('v.amtType');
        const mobileStepVO = component.get('v.mobileStepVO');
        const amt = $A.util.isEmpty(component.get('v.amount')) ? 0 : component.get('v.amount');
        let changedPrice = component.get('v.changedPrice');

        changedPrice = parseInt(changedPrice) - parseInt(amt);

        //==============================================================================
        // Validation Check.
        //==============================================================================
        if(changedPrice < 0) {
            helper.gfn_toast('차감 후 잔액이 0보다 작을 수 없습니다.', 'w');
            helper.fn_setInitAmountByType(component);
            return;
        }

        if(helper.fn_checkValidByType(component, event, helper, type)) {
            return;
        }

        //==============================================================================
        // 로직 처리 후 창 닫기.
        //==============================================================================
        if(type === '중고인수') {
            component.set('v.mobileStepVO', mobileStepVO);
            helper.fn_setTotalViewPrice(component, mobileStepVO.bizData.contract);
            helper.gfn_closeQuickActionModal(component);
        }
        else {
            const tempDate = (!$A.util.isEmpty(mobileStepVO.dateData.tempAmtYear) && !$A.util.isEmpty(mobileStepVO.dateData.tempAmtMonth) && !$A.util.isEmpty(mobileStepVO.dateData.tempAmtDay)) ? mobileStepVO.dateData.tempAmtYear + '-' + mobileStepVO.dateData.tempAmtMonth + '-' + mobileStepVO.dateData.tempAmtDay : '';

            helper.apex(
                component, 'doSave', 'setContractDate', {
                    'contract':mobileStepVO.bizData.contract,
                    'tempDate':tempDate,
                    'amtType':component.get('v.amtType'),
                }
            ).then(function ({resData, response}) {
                mobileStepVO.bizData.contract = resData;
                component.set('v.mobileStepVO', mobileStepVO);
                helper.fn_setTotalViewPrice(component, resData);
                helper.gfn_closeQuickActionModal(component);
            }).catch(function ({error, response}) {
                helper.gfn_ApexErrorHandle(error, response);
            });
        }
    },

    doCancel : function (component, event, helper) {
        helper.fn_setInitAmountByType(component);
        helper.gfn_closeQuickActionModal(component);
    },
});