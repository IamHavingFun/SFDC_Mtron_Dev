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
            }
        ).then(function ({resData, response}) {
            //helper.gfn_toast('성공적으로 저장되었습니다.', 's');
            helper.gfn_toast('정상적으로 결재 제출이 완료 되었습니다..', 's');
            helper.gfn_closeQuickActionModal(component);
        }).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error, response);
        });
    },

});