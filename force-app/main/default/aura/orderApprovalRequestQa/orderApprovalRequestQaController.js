({
    /**
     * 초기 거래
     * @param component
     * @param event
     * @param helper
     */
    doInit: function (component, event, helper) {
        helper.apex(
            component, 'doInit', 'init', {"recordId":component.get('v.recordId')}
        ).then(function ({resData, response}) {
            component.set('v.orderRecord', resData.order);
            component.set('v.isApprovalRequest', resData.isApprovalRequest);
        }).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error, response);
        });
    },

    /**
     * 저장
     * @param component
     * @param event
     * @param helper
     */
    doSave: function (component, event, helper) {
        helper.apex(
            component, 'doSave', 'submitForApproval', {
                'recordId': component.get('v.recordId'),
                'comment': component.get('v.requestComment'),
            }
        ).then(function ({resData, response}) {
            helper.gfn_toast('주문이 제출되었습니다.\n' +'제출된 주문은 영업소의 검토 후 확정되며, 이는 주문 현황에서 확인하실 수 있습니다.', 's');
            helper.gfn_closeQuickActionModal(component);
        }).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error, response);
        });
    },

});