/****************************************************************************************
 * @filename      : orderTransferPriceEditQaController.js
 * @projectname   :
 * @author        : i2max_my.Seo
 * @date          : 2020-04-16 오후 1:36
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
 0.1     2020-04-16 오후 1:36    i2max_my.Seo          Create
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
        helper.lacComService = component.find('lacComService');
/*

        helper.lacComService.doGetSobjectData(['Product2', 'Order__c', 'Asset', 'OrderLineitem__c'], function(resData) {
            component.set('v.labelMap', resData);
        });
*/

        helper.apex(
            component, 'doInit', 'init', {
                'recordId':component.get('v.recordId')
            }
        ).then(function ({resData, response}) {
            console.log(JSON.stringify(resData));
            component.set('v.returnOrder', resData.returnOrder);
            component.set('v.isProcess', resData.isProcess);
            component.set('v.OldSellingPrice', component.get('v.returnOrder').tOrder.SellingPrice__c);
        }).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error, response);
        });
    },

    /**
     * 가격 정정 저장.
     *
     * @param component
     * @param event
     * @param helper
     */
    doErpSave : function (component, event, helper) {
        const returnOrder = component.get('v.returnOrder');

        helper.apex(
            component, 'doSave', 'erpSave', {
                'returnOrder':returnOrder
            }
        ).then($A.getCallback(function ({resData, response}) {
            if(resData.STATUS === 'Y') {
                helper.gfn_toast('ERP 주문 가격 정정이 정상 처리 되었습니다.', 's');
                helper.gfn_refresh();
                helper.gfn_closeQuickAction();
            } else {
                helper.gfn_toast('ERP 주문 가격 정정 오류 :'+resData.MESSAGE , 'e');
            }
        })).catch(function ({error, response}) {
            console.log(JSON.stringify(error));
            helper.gfn_ApexErrorHandle(error, response);
        });
    },

    doPriceChange : function (component, event, helper) {
        let CorrectionPrice = event.getSource().get('v.value');
        let BaseSellingPrice = component.find('BaseSellingPrice').get('v.value');
        let OldSellingPrice = component.get('v.OldSellingPrice');

        if($A.util.isEmpty(CorrectionPrice)) CorrectionPrice = 0;
        if(parseFloat(CorrectionPrice) >= parseFloat(BaseSellingPrice)) {
            helper.gfn_toast('기준 가격보다 낮은 금액을 입력 해주세요');
            component.find('CorrectionPrice').set('v.value', 0);
            component.find('SellingPrice').set('v.value', OldSellingPrice);
            return;
        }
        if((parseFloat(CorrectionPrice)*-1) >= BaseSellingPrice) {
            helper.gfn_toast('기준 가격보다 높은 금액은 입력할 수 없습니다.');
            component.find('CorrectionPrice').set('v.value', 0);
            component.find('SellingPrice').set('v.value', OldSellingPrice);
            return;
        }
        component.find('SellingPrice').set('v.value', (parseFloat(BaseSellingPrice)+parseFloat(CorrectionPrice)));
        event.preventDefault();
    },

});