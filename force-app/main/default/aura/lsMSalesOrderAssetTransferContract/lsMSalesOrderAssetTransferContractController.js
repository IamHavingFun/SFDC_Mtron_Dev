/****************************************************************************************
 * @filename      : lsMSalesOrderAssetTransferContract.js
 * @projectname   :
 * @author        : SEOKHO LEE
 * @date          : 2020-11-19 오전 11:09
 * @group         :
 * @group-content :
 * @description   : 전배 승인 처리(모바일)
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
        console.log('----------');
        const recordId = component.get('v.recordId');
        console.log('recordId ---------- '+ recordId);
        helper.apex(component, 'doInit', 'init', {
            'recordId': recordId
        }).then(function ({resData, response}) {
            component.set('v.transferData', resData);
            component.set('v.assetTransferRequest', resData.assetTransferRequest);
            component.set('v.isRejectGrant', resData.isRejectGrant);
            component.set('v.isTargetContract', resData.isTargetContract);
            component.set('v.isSendReceiveItem', resData.isSendReceiveItem);
            component.set('v.notiMessage', resData.notiMessage);
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
        console.log(component.get('v.assetTransferRequest'));
        console.log('------------------');
        if (helper.fn_checkValid(component, helper)) {
            helper.apex(component, 'doSave', 'save', {
                'assetTransferRequest': component.get('v.assetTransferRequest')
            }).then(function ({resData, response}) {
                helper.gfn_toast('해당건에 대해서 거부 처리 되었습니다.', 's');
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

        component.set('v.assetTransferRequest.Contract__c', checkedContractId);
        // 모든 checkbox 배열처리
        let checkList = component.find('check');
        checkList = $A.util.isArray(checkList) ? checkList : [checkList];
        // 나머지 checkbox false 처리
        checkList.filter((item) => item.get('v.value') !== checkedContractId)
            .forEach((item) => item.set('v.checked', false));
    },

    doCancel  : function (component, event, helper) {
        helper.gfn_closeQuickActionModal(component);
    },

});