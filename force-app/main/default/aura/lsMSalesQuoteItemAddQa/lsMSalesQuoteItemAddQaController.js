/****************************************************************************************
 * @filename      : lsMSalesQuoteItemAddQaController.js
 * @projectname   :
 * @author        : i2max_my.Seo
 * @date          : 2020-06-30 오후 3:29
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
 0.1     2020-06-30 오후 3:29    i2max_my.Seo          Create
 ****************************************************************************************/
({
    doProductSearch : function (component, event, helper) {
        helper.gfn_createComponent(
            component,
            'lsMSalesProductSearchQa',
            {
                // 바인딩 되는 선택 제품
                'product': component.getReference('v.quoteWp.product'),
                // 바인딩 되는 선택 제품시리즈
                'productSeries': null,
                // 바인딩 선택시 수행 Action
                'finalAction': component.get('c.doFinalAction'),
                // 트랙터 제품만 여부
                'isOnlyTractor': false
            },
            'slds-modal_large'
        );
    },

    doFinalAction: function (component, event, helper) {
        const quoteWp = component.get('v.quoteWp');
        const prodId = quoteWp.product.Id;

        if(!$A.util.isEmpty(prodId)) {
            helper.apex(
                component, 'doFinalAction', 'getMainQliDataForQuote', {
                    'quoteWrapper':quoteWp,
                    'prodId':prodId
                }
            ).then(function ({resData, response}) {
                component.set('v.quoteWp', resData);
            }).catch(function ({error, response}) {
                helper.gfn_ApexErrorHandle(error, response);
            });
        }
    },

    doChange : function (component) {
        const quoteWp   = component.get('v.quoteWp');
        const unitPrice = component.find('unitPrice').get('v.value');
        const discount  = $A.util.isEmpty(component.get('v.initDiscount')) ? 0 : component.get('v.initDiscount');

        let tempPrice   = unitPrice - discount;

        quoteWp.qliWpList[0].unitPrice          = unitPrice;
        quoteWp.qliList[0].AdditionalDisc__c    = discount;
        quoteWp.quote.LastQuoteAmt__c           = tempPrice;
        quoteWp.qliList[0].NetPrice__c          = tempPrice;
        quoteWp.qliWpList[0].netPrice           = tempPrice;

        component.set('v.quoteWp', quoteWp);
        (discount === 0) && component.set('v.initDiscount', discount);
    },

    doMoveRegister : function (component, event, helper) {
        helper.fn_checkValid(component, event, helper) && helper.fn_calculateWithServer(component, event, helper);
    },
});