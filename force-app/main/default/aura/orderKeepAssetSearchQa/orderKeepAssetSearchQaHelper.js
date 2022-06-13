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
        component.set('v.reqData.productId', '');
        component.set('v.reqData.assetName', '');

    },

    fn_select : function (component, event, helper) {
        const orderKeep = component.get('v.orderKeep');
        const resultList = helper.gfn_getInputCheckedList(component.find('mycheck'));

        if(resultList.length > 1 || resultList.length === 0) {
            helper.gfn_toast('반드시 하나의 자산을 선택 해야 합니다.', 'w'); return;
        }

        orderKeep.KeepAsset__c = resultList[0].Id;

        helper.apex(
            component, 'fn_select', 'save', {
                'orderKeep':orderKeep
            }
        ).then(function ({resData, response}) {
            component.set('v.orderKeep', resData);
            helper.gfn_toast('보관자산이 정상적으로 등록 되었습니다.', 's');
            helper.gfn_refresh(component);
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