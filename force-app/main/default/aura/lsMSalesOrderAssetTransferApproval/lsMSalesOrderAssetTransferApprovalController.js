/**
 * Created by MS on 2020-07-01.
 */

({
    doInit : function (component, event, helper) {
        console.log('---------------------');
        const pageReference = helper.fn_getUrlParams();
        !$A.util.isEmpty(pageReference.tabName) && component.set('v.tabName', pageReference.tabName);

        helper.apex(
            component, 'doInit', 'init', {}
        ).then(({resData, response}) => {
            component.set('v.dataList', resData);
        }).catch(({error, response}) => {
            helper.gfn_ApexErrorHandle(error, response);
        });
    },

    doApprovalConfirm : function (component, event, helper) {
        //============================================================================
        // Confirm 처리
        //============================================================================
        component.set('v.assetTransfer', event.getSource().get('v.value'));

        helper.gfn_createComponent(component, 'lacComConfirmQuickAction', {
            'action': component.get('c.doApproval'),
            'btnLabel': '확인',
            'title': '전배 승인 처리',
            'comment': '전배 승인 처리 하시겠습니까?'
        });
    },

    doRejectConfirm : function (component, event, helper) {
        //============================================================================
        // Confirm 처리
        //============================================================================
        component.set('v.assetTransfer', event.getSource().get('v.value'));

        helper.gfn_createComponent(component, 'lsMSalesOrderAssetTransferContract', {
            'recordId':component.get('v.assetTransfer').Id,
            'contractId':component.getReference('v.contractId')
        }, 'slds-modal_medium');

    },


    /**
     * 승인 처리.
     * @param component
     * @param event
     * @param helper
     */
    doApproval : function (component, event, helper) {
        helper.apex(
            component, 'doApproval', 'save', {'assetTransferRequest' : component.get('v.assetTransfer'), 'status' : '승인'}
        ).then(({resData, response}) => {
            helper.gfn_toast('전배 승인 처리 되었습니다.', 's', null);
            component.set('v.dataList', resData);
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
            component, 'doReject', 'save', {'assetTransferRequest' : component.get('v.assetTransfer'), 'status' : '거부'}
        ).then(({resData, response}) => {
            component.set('v.dataList', resData);
            helper.gfn_toast('전배 거부 처리 되었습니다.', 's', null);
        }).catch(({error, response}) => {
            helper.gfn_ApexErrorHandle(error, response);
        });
    },
});