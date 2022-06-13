/****************************************************************************************
 * @filename      : lsMSalesQuoteItemModifyQaHelper.js
 * @projectname   :
 * @author        : i2max_my.Seo
 * @date          : 2020-07-06 오전 9:34
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
 0.1     2020-07-06 오전 9:34    i2max_my.Seo          Create
 ****************************************************************************************/
({
    fn_calculateWithServer : function (component, event, helper) {
        const quoteWp       = component.get('v.quoteWp');
        const qli           = component.get('v.qli');
        const initDiscount  = component.get('v.initDiscount');
        const initUnitPrice = component.get('v.initUnitPrice');

        if(qli.NetPrice__c < 0) {
            helper.gfn_toast('판매 가격이 0보다 작을 수 없습니다.', 'e');
            return;
        }

        quoteWp.amtWrapper.totalDiscount  -= initDiscount;
        quoteWp.amtWrapper.discount       -= initDiscount;
        quoteWp.amtWrapper.totalUnitPrice -= initUnitPrice;

        helper.apex(component, 'fn_calculateWithServer', 'reCalculateNetPrice', {
            'quoteWrapper': component.get('v.quoteWp'),
            'qli':qli,
            'index':component.get('v.index')
        }
        ).then(function ({resData, response}) {
            helper.fn_initAmt(component, resData);
            helper.gfn_closeQuickActionModal(component);
        }).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error, response);
        });
    },

    fn_initAmt : function (component, quoteWp) {

        quoteWp.quote.LastQuoteAmt__c           = quoteWp.amtWrapper.resultPrice = quoteWp.amtWrapper.totalPrice;
        quoteWp.quote.UsedUndertakingAmt__c     = 0;
        quoteWp.amtWrapper.totalDiscount        = quoteWp.amtWrapper.totalUnitPrice - quoteWp.amtWrapper.totalPrice;
        quoteWp.amtWrapper.discountRate         = Math.round((quoteWp.amtWrapper.totalDiscount/quoteWp.amtWrapper.totalUnitPrice) * 100);

        component.set('v.quoteWp', quoteWp);
    },

    fn_checkValid : function (component, event, helper) {
        const qli = component.get('v.qli');
        let isValid = true;

        // valid Check.
        if(qli.Product__r.Type__c === '본체' && ($A.util.isEmpty(qli.UnitPrice__c) || parseInt(qli.UnitPrice__c) === 0 || qli.UnitPrice__c < 0)) {
            helper.gfn_toast('올바른 대리점 가격을 입력해 주세요.', 'w');
            isValid = false;
        }

        if(qli.AdditionalDisc__c < 0) {
            helper.gfn_toast('올바른 할인 가격을 입력해 주세요.', 'w');
            isValid = false;
        }

        return isValid;
    },
});