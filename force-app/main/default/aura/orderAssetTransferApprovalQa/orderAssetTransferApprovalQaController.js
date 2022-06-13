/****************************************************************************************
 * @filename      : orderAssetTransferApprovalQaController.js
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
            component.set('v.isNotRequested', resData.isNotRequested);
            !resData.isNotRequested && component.set('v.isProcessed', resData.isProcessed);
        }).catch(({error}) => {
            helper.gfn_ApexErrorHandle(error);
        });
    },

    doSelect : function (component) {
        const division = component.get('v.division');

        if(division === '승인') {
            $A.enqueueAction(component.get('c.doApprove'));
        } else {
            $A.enqueueAction(component.get('c.doReject'));
        }
    },

    /**
     * Save
     *
     * @param component
     * @param event
     * @param helper
     */
    doApprove : function (component, event, helper) {
        helper.apex(
            component, 'doSave', 'setApprove', {
                order : component.get('v.order'),
                status : '승인'
            }
        ).then(({resData}) => {
            helper.gfn_toast('전수배 주문으로의 전환에 정상적으로 승인되었습니다.\n' + '대상 기대 및 수배 대리점의 동의 확정 후 전수배 주문으로의 전환이 완료됩니다.', 's');
            helper.gfn_closeQuickActionModal(component);
            helper.gfn_refresh();
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
    doReject : function (component, event, helper) {
        helper.apex(
            component, 'doSave', 'setReject', {
                order : component.get('v.order'),
                status : '거부'
            }
        ).then(({resData}) => {
            helper.gfn_toast('정상적으로 전수배 전환 공급에 대해서 거부 처리 되었습니다.', 's');
            helper.gfn_closeQuickActionModal(component);
            helper.gfn_refresh();
        }).catch(({error}) => {
            helper.gfn_ApexErrorHandle(error);
        });
    },

});