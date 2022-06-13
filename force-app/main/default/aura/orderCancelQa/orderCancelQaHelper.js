/****************************************************************************************
 * @filename      : orderCancelQaHelper.js
 * @author        : I2MAX
 * @date          : 2021-05-10
 * @group         :
 * @group-content :
 * @description   :
 * @tester        :
 * @reference     :
 * @release       : v1.0.0
 * @copyright     : Copyright © I2max. All Rights Reserved.
 * @modification Log
 * ===============================================================
 * ver     date                    author        description
 * ===============================================================
 0.1     2021-05-10         I2MAX          Create
 ****************************************************************************************/
({
    /**
     * Init
     *
     * @param component
     */
    fn_init: function (component) {
        this.apex(
            component, 'fn_init', 'init', {orderId: component.get('v.recordId')}
        ).then(({resData}) => {
            component.set('v.order', resData);
            (resData.Status__c === '종료') && component.set('v.wasCanceled', true);
        }).catch(({error}) => {
            this.gfn_ApexErrorHandle(error);
        });
    },

    /**
     * ERP 전송 안된 취소 처리
     *
     * @param component
     */
    fn_CancelSave : function (component, helper) {
        const closeQa = $A.get("e.force:closeQuickAction");
        helper.apex(
            component, 'fn_CancelSave', 'save', {order: component.get('v.order')}
        ).then (function ({resData, response}) {
            helper.gfn_toast('주문 취소 처리 되었습니다.', 's');
            helper.gfn_refresh();
            closeQa.fire();
        }).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error, response);
        });
    },

    /**
     * 공장주문 취소 처리 : save
     *
     * @param component
     */
    fn_OrToSave : function (component, helper) {
        const closeQa = $A.get("e.force:closeQuickAction");
        helper.apex(
            component, 'fn_OrToSave', 'callIF', {order: component.get('v.order'), callType : 'OR'}
        ).then(function ({resData, response}) {
            if(resData.Status__c == '종료') {
                helper.gfn_toast('주문 취소 처리 되었습니다.', 's');
                helper.gfn_refresh();
                closeQa.fire();
            } else {
                helper.gfn_toast(resData.ERPOrderCancelMessage__c, 'e');
            }
        }).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error, response);
        });
    },

    /**
     * 전수배 취소 처리 : save
     *
     * @param component
     */
    fn_ZortToSave : function (component,helper) {
        /*
            context의 문제로 lacComBase의 function 사용 불가
            다음과 같이 사용하면 됨.
        */
        const closeQa = $A.get("e.force:closeQuickAction");
        helper.apex(
            component, 'fn_ZortToSave_1', 'callIF', {order: component.get('v.order'), callType : 'ZORT'}
        ).then(function ({resData, response}) {
            if(resData.ERPOrderCancelStatus__c == 'ZORT 취소성공') {
                return helper.apex(
                    component, 'fn_ZortToSave_2', 'callIF', {order: resData, callType: 'ZRET'}
                );
            } else {
                throw resData.ERPOrderCancelMessage__c;
            }
        }).catch(function (error) {
            helper.gfn_toast(error, 'e');
        }).then(function ({resData, response}) {
            if(resData.ERPOrderCancelStatus__c == 'ZRET 취소성공') {
                return helper.apex(
                    component, 'fn_ZortToSave_3', 'save', {order: resData}
                );
            } else {
                throw resData.ERPOrderCancelMessage__c;
            }
        }).catch(function (error) {
            helper.gfn_toast(error, 'e');
        }).then(function ({resData, response}) {
            if(resData.Status__c == '종료') {
                helper.gfn_toast('전수배 주문 취소 처리 되었습니다.', 's');
                helper.gfn_refresh();
                closeQa.fire();
            } else {
                helper.gfn_toast(resData.ERPOrderCancelMessage__c, 'e');
            }
        }).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error, response);
        });
    },
});