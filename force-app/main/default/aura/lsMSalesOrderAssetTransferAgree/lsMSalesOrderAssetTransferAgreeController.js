/**
 * Created by MS on 2020-07-01.
 */

({
    doInit : function (component, event, helper) {

        const pageReference = helper.fn_getUrlParams();
        !$A.util.isEmpty(pageReference.tabName) && component.set('v.tabName', pageReference.tabName);

        helper.apex(
            component, 'doInit', 'init', {}
        ).then(({resData, response}) => {
            component.set('v.orderList', resData);
        }).catch(({error, response}) => {
            helper.gfn_ApexErrorHandle(error, response);
        });
    },

    doAgreeApprovalConfirm : function (component, event, helper) {
        //============================================================================
        // Confirm 처리
        //============================================================================
        component.set('v.tempOrder', event.getSource().get('v.value'));

        helper.gfn_createComponent(component, 'lacComConfirmQuickAction', {
            'action': component.get('c.doApproval'),
            'btnLabel': '확인',
            'title': '전수배 전환 동의 승인 처리',
            'comment': '전수배 전환 동의에 승인 처리 하시겠습니까?'
        });
    },

    doAgreeRejectConfirm : function (component, event, helper) {
        //============================================================================
        // Confirm 처리
        //============================================================================
        component.set('v.tempOrder', event.getSource().get('v.value'));

        helper.gfn_createComponent(component, 'lacComConfirmQuickAction', {
            'action': component.get('c.doReject'),
            'btnLabel': '확인',
            'title': '전수배 전환 동의 거부 처리',
            'comment': '전수배 전환 동의에 거부 처리 하시겠습니까?'
        });
    },


    /**
     * 승인 처리.
     * @param component
     * @param event
     * @param helper
     */
    doApproval : function (component, event, helper) {
        helper.apex(
            component, 'doApproval', 'save', {'order' : component.get('v.tempOrder'), 'status' : '승인'}
        ).then(({resData, response}) => {
            helper.gfn_toast('전수배 전환 동의 승인 처리 되었습니다.', 's', null);
            component.set('v.orderList', resData);
        }).catch(({error, response}) => {
            helper.gfn_ApexErrorHandle(error, response);
        });
    },

    /**
     * 거부 처리.
     * @param component
     * @param event
     * @param helper
     */
    doReject : function (component, event, helper) {
        helper.apex(
            component, 'doReject', 'save', {'order' : component.get('v.tempOrder'), 'status' : '거부'}
        ).then(({resData, response}) => {
            helper.gfn_toast('전수배 전환 동의 거부 처리 되었습니다.', 's', null);
            component.set('v.orderList', resData);
        }).catch(({error, response}) => {
            helper.gfn_ApexErrorHandle(error, response);
        });
    },
});