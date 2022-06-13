/****************************************************************************************
 * @filename      : lsMSalesQuoteRegisterHelper.js
 * @projectname   :
 * @author        : i2max_my.Seo
 * @date          : 2020-06-25 오전 10:27
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
 0.1     2020-06-25 오전 10:27    i2max_my.Seo          Create
 ****************************************************************************************/
({
    /**
     * V/D 체크.
     *
     * @param component
     * @param event
     * @param helper
     * @returns {boolean}
     */
    fn_checkValid : function (component, event, helper) {
        const quoteWp = component.get('v.quoteWp');

        if($A.util.isEmpty(quoteWp.qliList[0])) {
            helper.gfn_toast('본체가 먼저 선택 되어야 합니다.', 'w');
            return false;
        }

        if($A.util.isEmpty(quoteWp.quote.CustomerName__c)) {
            helper.gfn_toast('매수자가 선택 되어야 합니다.', 'w');
            return false;
        }

        if(quoteWp.amtWrapper.resultPrice < 0 || quoteWp.amtWrapper.totalDiscount < 0) {
            helper.gfn_toast('차감 금액 또는 할인 금액이 0보다 작을 수 없습니다.', 'e');
            return false;
        }

        if(quoteWp.amtWrapper.totalPrice < quoteWp.quote.LastQuoteAmt__c) {
            helper.gfn_toast('최종견적가가 합계 금액보다 클 수 없습니다.', 'e');
            return false;
        }

        if(quoteWp.quote.LastQuoteAmt__c <= 0) {
            helper.gfn_toast('최종견적가를 입력해 주세요.', 'e');
            return false;
        }

        return true;
    },

    /**
     * 입력 시, 실시간 계산.
     *
     * @param component
     */
    fn_calculate : function (component, isInit, helper) {
        const quoteWp           = component.get('v.quoteWp');
        const amtWrapper        = quoteWp.amtWrapper;

        quoteWp.quote.LastQuoteAmt__c = quoteWp.quote.LastQuoteAmt__c || 0;

        // 할인 금액
        if(!isInit) {
            if(parseInt(amtWrapper.totalPrice) - parseInt(quoteWp.quote.LastQuoteAmt__c) >= 0) {
                amtWrapper.totalDiscount = ($A.util.isEmpty(quoteWp.quote.LastQuoteAmt__c) || quoteWp.quote.LastQuoteAmt__c === 0) ? 0 : amtWrapper.discount + (parseInt(amtWrapper.totalPrice) - parseInt(quoteWp.quote.LastQuoteAmt__c));
            }
            else {
                amtWrapper.totalDiscount = 0;
                amtWrapper.discountRate  = 0;
                this.gfn_toast('최종견적가가 합계 금액보다 클 수 없습니다.', 'e');
                component.set('v.quoteWp.amtWrapper', amtWrapper);
                return;
            }
        }

        // 할인율
        amtWrapper.discountRate     = Math.round((amtWrapper.totalDiscount/amtWrapper.totalUnitPrice) * 100);
        // 차감 후 금액
        quoteWp.quote.UsedUndertakingAmt__c = quoteWp.quote.UsedUndertakingAmt__c || 0;
        amtWrapper.resultPrice      = ($A.util.isEmpty(quoteWp.quote.LastQuoteAmt__c)) ? 0 : quoteWp.quote.LastQuoteAmt__c - quoteWp.quote.UsedUndertakingAmt__c;

        component.set('v.isInit', false);
        component.set('v.quoteWp.amtWrapper', amtWrapper);
    },

    /**
     * 매수자 조회 QuickAction.
     *
     * @param component
     */
    fn_setCustomerName : function (component) {
        $A.util.isEmpty(component.get('v.quoteWp.quote.CustomerName__c'))
        && component.set('v.quoteWp.quote.CustomerName__c', component.get('v.quoteWp.quote.CustomerName__r.Id'));
    },

    /**
     * QuoteLineItem__c 변경 후, Amount Wrapper 초기화
     *
     * @param component
     * @param event
     * @param helper
     */
    fn_initAmt : function (component, event, helper) {
        const quoteWp = component.get('v.quoteWp');

        quoteWp.quote.LastQuoteAmt__c = quoteWp.amtWrapper.resultPrice = quoteWp.amtWrapper.totalPrice;
        quoteWp.quote.UsedUndertakingAmt__c = 0;

        component.set('v.quoteWp', quoteWp);
    },

    /**
     * Navigate to List
     *
     * @param component
     * @param event
     * @param helper
     */
    fn_navigateToList : function (component, event, helper) {
        helper.lacComService.doNaviService({
            "type": component.get('v.isCommunity') ? "comm__namedPage" : "standard__namedPage",
            "attributes": {
                "name": "lsMSalesQuoteContractList__c"
            }
        })
    },

    /**
     * Navigate to Contract 등록.
     *
     * @param component
     * @param event
     * @param helper
     * @param quoteId
     */
    fn_navigateToContract : function (component, event, helper, quoteId) {
        helper.lacComService.doNaviService({
            "type": component.get('v.isCommunity') ? "comm__namedPage" : "standard__namedPage",
            "attributes": {
                "name": "lsMSalesContract__c"
            },
            "state": {
                "recordId": quoteId
            }
        });
    },

    fn_checkChangedData : function (component) {
        const unchangedData = component.get('v.unchangedData');
        const targetData    = component.get('v.quoteWp');
        let   isChanged     = false;

        // Quote 비교
        if(JSON.stringify(unchangedData.unchangedQuote) !== JSON.stringify(targetData.quote)) {
            isChanged = true;
        }

        // 견적 제품 Wrapper 비교
        if(JSON.stringify(unchangedData.unchangedQliWrapperList) !== JSON.stringify(targetData.qliWpList)) {
            isChanged = true;
        }

        return isChanged;
    },

    lacComService : null
});