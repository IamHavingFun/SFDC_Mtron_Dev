/****************************************************************************************
 * @filename      : lsMSalesQuoteItemAddQaHelper.js
 * @projectname   :
 * @author        : i2max_my.Seo
 * @date          : 2020-07-02 오후 4:54
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
 0.1     2020-07-02 오후 4:54    i2max_my.Seo          Create
 ****************************************************************************************/
({
    fn_calculateWithServer : function (component, event, helper) {
        const discount = component.find('discount').get('v.value');
        const netPrice = component.get('v.quoteWp.qliList[0].NetPrice__c');

        if(netPrice < 0) {
            helper.gfn_toast('판매 가격이 0보다 작을 수 없습니다.', 'e');
            return;
        }

        helper.apex(
            component, 'fn_calculateWithServer', 'reCalculateNetPrice', {
                'quoteWrapper': component.get('v.quoteWp'),
                'discount': discount
            }
        ).then(function ({resData, response}) {
            component.set('v.quoteWp', resData);
            helper.gfn_closeQuickActionModal(component);
        }).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error, response);
        });
    },

    fn_checkValid : function (component, event, helper) {
        const quoteWp = component.get('v.quoteWp');
        let isValid = true;

        // valid Check.
        if($A.util.isEmpty(quoteWp.product.Id)) {
            helper.gfn_toast('제품을 선택해 주세요.', 'w');
            isValid = false;
        }

        if($A.util.isEmpty(quoteWp.qliWpList[0].unitPrice) || parseInt(quoteWp.qliWpList[0].unitPrice) === 0 || quoteWp.qliWpList[0].unitPrice < 0) {
            helper.gfn_toast('올바른 대리점 가격을 입력해 주세요.', 'w');
            isValid = false;
        }

        if($A.util.isEmpty(quoteWp.qliList[0].AdditionalDisc__c)) {
            helper.gfn_toast('올바른 할인 가격을 입력해 주세요.', 'w');
            isValid = false;
        }

        return isValid;
    },
});