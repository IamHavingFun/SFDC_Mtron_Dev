/****************************************************************************************
 * @filename      : TransferApprovalQaController.js
 * @projectname   :
 * @author        : SEOKHO LEE
 * @date          : 2020-11-19 오전 11:09
 * @group         :
 * @group-content :
 * @description   : 전배 승인 처리
 * @tester        :
 * @reference     :
 * @copyright     : Copyright © I2max. All Rights Reserved.
 * @modification Log
 * ===============================================================
 * ver     date                     author              description
 * ===============================================================
 0.1     2020-11-19 오전 11:09      SEOKHO LEE          Create
 ****************************************************************************************/

({
    /**
     * 초기화
     * @param component
     * @param event
     * @param helper
     */
    doInit: function (component, event, helper) {
        helper.apex(component, 'doInit', 'init', {
                'recordId': component.get('v.recordId')
        }).then(function ({resData, response}) {
            component.set('v.transferData', resData);
            component.set('v.isProcessed', resData.isProcessed);
            component.set('v.isRejectGrant', resData.isRejectGrant);
            component.set('v.isTargetContract', resData.isTargetContract);
            component.set('v.isSendReceiveItem', resData.isSendReceiveItem);
            component.set('v.notiMessage', resData.notiMessage);
            /*resData.isProcessed && helper.gfn_toast('이미 처리가 완료 되었습니다.', 'w');*/
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
        console.log('------------------');
        if (helper.fn_checkValid(component, helper)) {
            helper.apex(component, 'doSave', 'save', {
                'assetTransferRequest': component.get('v.transferData.assetTransferRequest')
            }).then(function ({resData, response}) {
                helper.gfn_toast('성공적으로 저장되었습니다.', 's');
                helper.gfn_refresh();
                helper.gfn_closeQuickActionModal(component);
            }).catch(function ({error, response}) {
                helper.gfn_ApexErrorHandle(error, response);
            });
        }
    },

    doCheck  : function (component, event, helper) {
        // event 된 것만 checked 표시
        const eventComponent = event.getSource();
        const checkedContractId = eventComponent.get('v.value');
        
        component.set('v.transferData.assetTransferRequest.Contract__c', checkedContractId);
        // 모든 checkbox 배열처리
        let checkList = component.find('check');
        checkList = $A.util.isArray(checkList) ? checkList : [checkList];
        // 나머지 checkbox false 처리
        checkList.filter((item) => item.get('v.value') !== checkedContractId)
            .forEach((item) => item.set('v.checked', false));
    }
});