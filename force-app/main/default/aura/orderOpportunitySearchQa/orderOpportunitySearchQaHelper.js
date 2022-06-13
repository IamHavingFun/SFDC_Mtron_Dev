/****************************************************************************************
 * @filename      : orderOpportunitySearchQaHelper.js
 * @projectname   :
 * @author        : i2max_my.Seo
 * @date          : 2020-04-16 오후 5:20
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
 0.1     2020-04-16 오후 5:20    i2max_my.Seo          Create
 ****************************************************************************************/

({
    fn_initSearch : function(component) {
        component.set('v.reqData.pageSize', '10');

        // 검색조건 초기화
        component.set('v.reqData.productType', '');
        component.set('v.reqData.series', '');
        component.set('v.reqData.name', '');
        component.set('v.reqData.dealerId', '');
        component.set('v.reqData.productId', '');
    },

    fn_select : function (component, event, helper) {
        const resultList = helper.gfn_getInputCheckedList(component.find('mycheck'));

        if(resultList.length > 1 || resultList.length === 0) {
            helper.gfn_toast('반드시 하나의 기회를 선택 해야 합니다.', 'w'); return;
        }

        const wrapperData = component.get('v.wrapperData');

        if($A.util.isEmpty(resultList[0].ProductId__r)) {
            helper.gfn_toast('해당 기회에는 제품이 없습니다.', 'w'); return;
        }

        wrapperData.order.Opportunity__c                    = resultList[0].Contract__r.Opportunity__c;
        wrapperData.order.DeliveryDate__c                   = resultList[0].Contract__r.CustomerExpectedDate__c;
        // ITVOC-2022-03-0716 : 파트너의 주문 고객은 대리점으로 고정
        //wrapperData.order.OrderAccount__c                   = resultList[0].Contract__r.Dealer__c;
        //wrapperData.order.OrderAccount__c                   = resultList[0].Contract__r.Opportunity__r.AccountId;
        wrapperData.opptyName                               = resultList[0].Contract__r.Opportunity__r.Name;
        wrapperData.orderLineItemList[0].ProductId__c       = resultList[0].ProductId__c;
        wrapperData.orderLineItemList[0].ListPrice__c       = resultList[0].ProductId__r.ListPrice__c;
        wrapperData.orderLineItemList[0].UnitPrice__c       = resultList[0].ProductId__r.DealerListPrice__c;
        wrapperData.orderLineItemList[0].ProductId__r       = resultList[0].ProductId__r;

        helper.apex(
            component, 'fn_select', 'calculatePrice', {
                'wrapperData':wrapperData
            }
        ).then(function ({resData, response}) {
            component.set('v.wrapperData', resData);

            const action = component.get('v.action');
            !$A.util.isEmpty(action) && $A.enqueueAction(action);

            helper.gfn_closeQuickActionModal(component);
        }).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error, response);
        });
    },

    fn_check : function (component, event) {
        const record = event.getSource().get('v.value');

        let checkList = component.find('mycheck');
        checkList = $A.util.isArray(checkList) ? checkList : [checkList];

        checkList.filter((item) => item.get('v.value') !== record)
            .forEach((item) => item.set('v.checked', false));
    },

});