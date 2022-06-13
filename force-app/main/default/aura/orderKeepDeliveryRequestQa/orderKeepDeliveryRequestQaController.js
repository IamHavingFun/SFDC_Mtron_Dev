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
            component.set('v.order', resData.order);
            component.set('v.isButtonSave', resData.isButtonSave);
            component.set('v.pageComment', resData.pageComment);
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
                'order': component.get('v.order'),
                'comment': component.get('v.requestComment'),
            }
        ).then(function ({resData, response}) {
            helper.gfn_toast('보관처리 승인 요청이 처리 되었습니다.', 's');
            helper.gfn_refresh();
            helper.gfn_closeQuickActionModal(component);
        }).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error, response);
        });
    },

});