/****************************************************************************************
 * @filename      : orderNewQaHelper.js
 * @projectname   :
 * @author        : i2max_my.Seo
 * @date          : 2020-04-17 오전 7:35
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
 0.1     2020-04-17 오전 7:35    i2max_my.Seo          Create
 ****************************************************************************************/

({
    /**
     * WrapperData 초기화.
     *
     * @param component
     */
    fn_InitWrapperData : function (component) {
        const wrapperData = component.get('v.wrapperData');

        wrapperData.orderLineItemList[0].ProductId__c       = null;
        wrapperData.orderLineItemList[0].ProductId__r       = null;
        wrapperData.orderLineItemList[0].UnitPrice__c       = null;
        wrapperData.orderLineItemList[0].ListPrice__c       = null;
        wrapperData.supplyHighAmt                           = 0;
        wrapperData.supplyLowAmt                            = 0;
        wrapperData.order.Opportunity__c                    = null;
        wrapperData.order.Campaign__c                       = null;
        wrapperData.order.OrderScheduleDate__c              = null;
        wrapperData.order.DeliveryDate__c                   = null;
        wrapperData.strCloseDate                            = null;

        if(!$A.util.isEmpty(wrapperData.asset)) wrapperData.asset.Name = null;

        component.set('v.wrapperData', wrapperData);
    },

    /**
     * 저장 하기 전, V/D Check.
     *
     * @param component
     * @param event
     * @param helper
     * @returns {boolean}
     */
    fn_ValidationCheckForSave : function (component, event, helper) {
        const wd = component.get('v.wrapperData');

        //==============================================================================
        // order 주문 시, 필수인 orderLineItem의 productId가 null일 경우 V/D
        //==============================================================================

        if(wd.isPerFarCorp === true) {
            // 개인 / 영농
            if(wd.order.PurposeOfOrder__c === '실판매기회') {
                console.log('판매기회를 선택 해야 합니다.');
                if($A.util.isEmpty(wd.order.Opportunity__c)) {
                    helper.gfn_toast('판매기회를 선택 해야 합니다.', 'w');
                    return false;
                }
            }
            if($A.util.isEmpty(wd.order.OrderScheduleDate__c)) {
                helper.gfn_toast('납품요청일자를 선택 해야 합니다.', 'w');
                return false;
            }
        } else {
            // 농협 / 관납
            if($A.util.isEmpty(wd.order.OrderAccount__c)) {
                helper.gfn_toast('주문고객을 선택 해야 합니다.', 'w');
                return false;
            }
            if($A.util.isEmpty(wd.order.DeliverTo__c)) {
                helper.gfn_toast('납품처를 선택 해야 합니다.', 'w');
                return false;
            }
            if($A.util.isEmpty(wd.order.OrderScheduleDate__c)) {
                helper.gfn_toast('납품요청일자를 선택 해야 합니다.', 'w');
                return false;
            }
        }
        if($A.util.isEmpty(wd.orderLineItemList[0].ProductId__c)) {
            helper.gfn_toast('제품을 선택 해야 합니다.', 'w');
            return false;
        }

        return true;
    },

    fn_btnLabelChange : function (component, event, helper) {
        const purpose = component.find('purposeOfOrder').get('v.value');
        helper.fn_InitWrapperData(component);
        component.set('v.wrapperData.isSaveButton', component.get('v.isOldSaveButton'));
        component.set('v.wrapperData.isERPSaveButton',component.get('v.isOldErpSaveButton'));
        switch (purpose) {
            case '재고보충' :
                component.set('v.btnLabel', '제품 조회');
                component.set('v.isOrderScheduleDate', true);
                break;
            case '실판매기회' :
                component.set('v.btnLabel', '판매 기회 조회');
                component.set('v.isOrderScheduleDate', false);
                break;
            case '' : component.set('v.btnLabel', ''); break;
            default : return;
        }
    },

    fn_getSoldTo : function (component, event, helper) {
        // 납품처 초기화.
        component.set('v.wrapperData.order.DeliverTo__c', '');
        // option 초기화.
        component.set('v.soldToList', '');
        const accountId = component.find('orderAccount').get('v.value')[0];

        !$A.util.isEmpty(accountId)
        && helper.apex(
            component, 'fn_getSoldTo', 'getTargetSoldTo', {'accountId':accountId}
        ).then(function ({resData, response}) {
            $A.util.isEmpty(resData.soldToList) ? helper.gfn_toast('해당하는 납품처가 없습니다.', 'w') : component.set('v.soldToList', resData.soldToList);
            (resData.soldToList.length === 1) && component.set('v.wrapperData.order.DeliverTo__c', resData.soldToList[0].value);
            // !$A.util.isEmpty(resData.isGov) && component.set('v.isGov', resData.isGov);
        }).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error, response);
        });
    },

    fn_setSoldTo : function (component, order) {
        let soldToOptionList;

        if(!$A.util.isEmpty(order.DeliverTo__c)) {
            soldToOptionList = [
                {'label': order.DeliverTo__r.Name, 'value': order.DeliverTo__c},
            ];
        }

        component.set('v.soldToList', soldToOptionList);
    },

    /**
     * lacComService Cmp를 담는 역할.
     */
    lacComService : null
});