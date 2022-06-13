/****************************************************************************************
 * @filename      : exmOpptyListController.js
 * @projectname   : LWC_I2MAX
 * @author        : i2max_my.Seo
 * @date          : 2020-03-10 오전 9:33
 * @group         :
 * @group-content :
 * @description   :
 * @tester        :
 * @reference     :
 * @copyright     : Copyright © I2max. All Rights Reserved.
 * @modification Log
 * ===============================================================
 * ver     date                     author              description
 * ===============================================================
   0.1     2020-03-10 오전 9:33     i2max_my.Seo          Create
 ****************************************************************************************/
({
    /**
     * Init.
     *
     * @param component
     * @param event
     * @param helper
     */
    doInit: function (component, event, helper) {
        component.find('lacComService').doGetSobjectData(['Product2', 'Asset'], function(resData) {
            component.set('v.labelMap', resData);
        });

        helper.apex(
            component, 'doInit', 'init',
            {
                'productId':component.get('v.productId')
            }
        ).then(function ({resData, response}) {
            ($A.util.isEmpty(resData.assetList)) && helper.gfn_toast('해당 전수배 목록이 없습니다.', 'w');

            component.set('v.recordList', resData.assetList);
        }).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error, response);
        });
    },

    /**
     * 선택한 record를 attribute에 할당 후, 해당 cmp를 닫음.
     *
     * @param component
     * @param event
     * @param helper
     */
    doSelect : function (component, event, helper) {
        const resultList = helper.gfn_getInputCheckedList(component.find('mycheck'));

        if(resultList.length > 1 || resultList.length === 0) {
            helper.gfn_toast('반드시 한 개를 선택 해야 합니다.', 'w'); return;
        }

        const wrapperData = component.get('v.wrapperData');

        (!$A.util.isEmpty(wrapperData.asset)) && component.set('v.wrapperData.existAsset', wrapperData.asset);

        wrapperData.asset                           = resultList[0];
        wrapperData.order.TransferBusinessOffice__c = resultList[0].Dealer__c;
        wrapperData.order.TransferMachineNo__c      = wrapperData.orderLineItemList[0].TransferAsset__c = resultList[0].Id;

        component.set('v.wrapperData', wrapperData);

        helper.gfn_closeQuickActionModal(component);
    },
})