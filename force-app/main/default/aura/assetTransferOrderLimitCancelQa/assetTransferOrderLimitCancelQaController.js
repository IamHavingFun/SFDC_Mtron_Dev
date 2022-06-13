/****************************************************************************************
 * @filename      : assetTransferOrderLimitCancelQaController.js
 * @author        : I2MAX
 * @date          : 2021-03-24
 * @group         :
 * @group-content :
 * @description   :
 * @tester        :
 * @reference     :
 * @release       : v1.0.0
 * @copyright     : Copyright © I2max. All Rights Reserved.
 * @modification Log
 * ===============================================================
 * ver     date                    author         description
 * ===============================================================
 1.0     2021-03-24         I2MAX            Create
 ****************************************************************************************/
({
    doInit : function(component, event, helper){ //access token
        helper.apex(
            component, 'doInit', 'init', {
                'recordId' : component.get('v.recordId')
            }
        ).then(function ({resData, response}) {
            component.set('v.asset', resData);

            if(resData.TransferCount__c !== 1 || resData.InventoryType__c !== '대리점재고') {
                component.set('v.isError', true);
                component.set('v.errorMessage', '해당 자산은 전배 제한 해제 대상이 아닙니다.');
            }
        }).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error, response);
        });
    },

    doSave: function (component, event, helper) {
        const asset = component.get('v.asset');
        // 버그로 lacComBaseHelper의 gfn_closeQuickAction를 사용하지 말고 다음과 같이 사용.
        const closeQuickAction = $A.get("e.force:closeQuickAction");
        asset.Id = component.get('v.recordId');

        if($A.util.isEmpty(asset.LimitCancelComment__c)) {
            helper.gfn_toast('사유를 입력하세요', 'w');
            return;
        }

        helper.apex(
            component, 'doSave', 'save', {asset: asset}
        ).then(({resData}) => {
            helper.gfn_toast('전수배 제한 해제 요청이 정상적으로 제출되었습니다.', 's');
            helper.gfn_refresh();
            // QA close
            closeQuickAction.fire();
        }).catch(({error}) => {
            helper.gfn_ApexErrorHandle(error);
        });
    },
});