/****************************************************************************************
 * @filename      : orderNewForContractHelper.js
 * @projectname   :
 * @author        : i2max_my.Seo
 * @date          : 2020-12-14 오후 2:12
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
 0.1     2020-12-14 오후 2:12    i2max_my.Seo          Create
 ****************************************************************************************/
({
    fn_init: function (component) {
        this.lacComService = component.find('lacComService');

        this.lacComService.doGetSobjectData(['Product2', 'Order__c', 'OrderLineitem__c'], function(resData) {
            component.set('v.labelMap', resData);
        });

        this.apex(
            component, 'fn_init', 'init', {}
        ).then(({resData}) => {
            component.set('v.wrapperData', resData.wrapperData);
        }).catch(({error}) => {
            this.gfn_ApexErrorHandle(error);
        });
    },

    fn_save : function (component) {
        if(this.fn_validCheck(component)) {
            return;
        }

        this.apex(
            component, 'fn_save', 'save', {
                wrapperData: component.get('v.wrapperData')
            }
        ).then(({resData}) => {
            this.gfn_toast('성공적으로 저장되었습니다.', 's');
            this.lacComService.doNaviService({
                "type": "standard__recordPage",
                "attributes": {
                    "recordId": resData,
                    "actionName": "view"
                }
            });
        }).catch(({error}) => {
            this.gfn_ApexErrorHandle(error);
        });
    },

    fn_moveSearchList : function (component) {
        if($A.util.isEmpty(component.get('v.wrapperData.order.OrderAccount__c'))) {
            this.gfn_toast('주문 고객을 선택해야 합니다.', 'w');
            return;
        }

        this.gfn_createComponent(component, 'orderProductSearchQa', {
            'wrapperData': component.getReference('v.wrapperData')
        }, 'slds-modal_medium');
    },

    fn_getSoldTo : function (component) {
        const accountId = component.find('orderAccount').get('v.value')[0];

        !$A.util.isEmpty(accountId) && this.apex(
            component, 'fn_getSoldTo', 'getTargetSoldToId', {accountId:accountId}
        ).then(({resData}) => {
            component.set('v.wrapperData.order.DeliverTo__c', resData);
        }).catch(({error}) => {
            this.gfn_ApexErrorHandle(error);
        });
    },

    fn_validCheck : function (component) {
        const wrapperData = component.get('v.wrapperData');

        if($A.util.isEmpty(wrapperData.order.DeliverTo__c)) {
            this.gfn_toast('주문 고객에 해당하는 대리점이 선택되야 합니다.', 'w');
            return true;
        }
        if($A.util.isEmpty(wrapperData.orderLineItemList[0].ProductId__c)) {
            this.gfn_toast('제품을 선택 해야 합니다.', 'w');
            return true;
        }

        return false;
    },

    lacComService: null
});