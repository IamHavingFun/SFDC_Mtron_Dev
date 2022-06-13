/****************************************************************************************
 * @filename      : orderTransferRequestQaController.js
 * @projectname   :
 * @author        : i2max_my.Seo
 * @date          : 2020-11-19 오후 12:29
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
 0.1     2020-11-19 오후 12:29    i2max_my.Seo          Create
 ****************************************************************************************/
({
    /**
     * Init
     *
     * @param component
     * @param event
     * @param helper
     */
    doInit : function (component, event, helper) {
        helper.apex(
            component, 'doInit', 'init', {
                recordId : component.get('v.recordId')
            }
        ).then(({resData}) => {
            component.set('v.order', resData.order);
            component.set('v.isRequested', resData.isRequested);
            component.set('v.isOpportunityOrder', resData.isOpportunityOrder);
            component.set('v.isPossible', resData.isPossible);      // 전수배 주문 전환 가능 여부 , 영업소 검토 단계에서만 가능.
            component.set('v.isNhGovAccount', resData.isNhGovAccount);  // 농협/관납 고객여부 체크.
        }).catch(({error}) => {
            helper.gfn_ApexErrorHandle(error);
        });
    },

    /**
     * Save
     *
     * @param component
     * @param event
     * @param helper
     */
    doSave : function (component, event, helper) {
        const orderRecord = component.get('v.order');
        helper.apex(
            component, 'doSave', 'save', {
                order : orderRecord
            }
        ).then(({resData}) => {
            if(orderRecord.OrderAccount__r.CustomerType__c === '농협' || orderRecord.OrderAccount__r.CustomerType__c === '관납') {
                helper.gfn_toast('전수배 주문으로의 전환 동의 처리되었습니다, 전배 요청 진행 해주세요.', 's');
            } else {
                helper.gfn_toast('주문 대리점에게 전수배 주문으로의 전환 동의 요청을 정상적으로 발송하였습니다.', 's');
            }
            helper.gfn_closeQuickActionModal(component);
            helper.gfn_refresh();
        }).catch(({error}) => {
            helper.gfn_ApexErrorHandle(error);
        });
    },

});