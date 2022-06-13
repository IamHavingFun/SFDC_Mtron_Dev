/****************************************************************************************
 * @filename      : lsMSalesAddOtherWorkingMachineQaHelper.js
 * @projectname   :
 * @author        : i2max_my.Seo
 * @date          : 2020-12-18 오후 5:00
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
 0.1     2020-12-18 오후 5:00    i2max_my.Seo          Create
 ****************************************************************************************/
({
    fn_init : function (component) {
        const qliWrapper = component.get('v.qliWrapper');
        let qoi = component.get('v.quoteOtherItem');

        qoi.ProductName__c = qliWrapper.qliName;
        qoi.NetPrice__c = qliWrapper.netPrice;

        component.set('v.quoteOtherItem', qoi);
    },

    fn_save: function (component) {
        const quoteWp = component.get('v.quoteWp');
        quoteWp.qoiList.push(component.get('v.quoteOtherItem'));

        this.fn_validCheck(component) && this.apex(
            component, 'fn_save', 'setQuoteOtherItem', {
                quoteWrapper: quoteWp
            }
        ).then(({resData}) => {
            this.fn_initAmt(component, resData);
            this.fn_cancel(component);
        }).catch(({error}) => {
            this.gfn_ApexErrorHandle(error);
        });
    },

    fn_modify : function (component) {
        this.apex(
            component, 'fn_modify', 'modifyQuoteOtherItem', {
                quoteWrapper: component.get('v.quoteWp'),
                qoi: component.get('v.quoteOtherItem'),
                qliWrapper: component.get('v.qliWrapper')
            }
        ).then(({resData}) => {
            this.fn_initAmt(component, resData);
            this.fn_cancel(component);
        }).catch(({error}) => {
            this.gfn_ApexErrorHandle(error);
        });
    },

    fn_initAmt : function (component, quoteWp) {

        quoteWp.quote.LastQuoteAmt__c       = quoteWp.amtWrapper.resultPrice = quoteWp.amtWrapper.totalPrice;
        quoteWp.quote.UsedUndertakingAmt__c = 0;
        quoteWp.amtWrapper.totalDiscount    = quoteWp.amtWrapper.discount;

        component.set('v.quoteWp', quoteWp);
    },

    fn_validCheck : function (component) {
        const qoi = component.get('v.quoteOtherItem');

        if($A.util.isEmpty(qoi.ProductName__c)) {
            this.gfn_toast('제품명을 입력해주세요.', 'w');
            return false;
        }

        if($A.util.isEmpty(qoi.NetPrice__c)) {
            this.gfn_toast('판매가를 입력해주세요.', 'w');
            return false;
        }

        return true;
    },

    fn_cancel : function (component) {
        this.gfn_closeQuickActionModal(component);
    },
});