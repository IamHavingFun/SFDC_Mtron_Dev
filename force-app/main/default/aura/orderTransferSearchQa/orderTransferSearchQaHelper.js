/****************************************************************************************
 * @filename      : orderTransferSearchQaHelper.js
 * @projectname   :
 * @author        : i2max_my.Seo
 * @date          : 2020-11-20 오전 9:51
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
   0.1     2020-11-20 오전 9:51    i2max_my.Seo          Create
 ****************************************************************************************/
({
    /**
     * Init
     *
     * @param component
     */
    fn_init: function (component) {
        this.lacComService = component.find('lacComService');

        this.lacComService.doGetSobjectData(['Product2', 'Asset'], function(resData) {
            component.set('v.labelMap', resData);
        });

        this.fn_initialize(component);

        this.apex(
            component, 'fn_init', 'init', {
                productId:component.get('v.assetTransferRequest').Model__c,
                orderId:component.get('v.assetTransferRequest').Order__c,
                reqData:component.get('v.reqData')
            }
        ).then(({resData}) => {
            component.set('v.businessOfficeNameList', resData.businessOfficeNameList);
            component.set('v.reqData.businessOfficeName', resData.currentUserBusinessOfficeName);

            if($A.util.isEmpty(resData.wrapperDataList)) {
                !$A.util.isEmpty(component.get('v.recordList')) && component.set('v.recordList', null);
                this.gfn_toast(component.get('v.noDataFound'), 'w');
                return;
            }

            component.set('v.recordList', resData.wrapperDataList);
        }).catch(({error}) => {
            this.gfn_ApexErrorHandle(error);
        });
    },

    fn_search : function (component) {
        this.apex(
            component, 'fn_search', 'search', {
                productId:component.get('v.assetTransferRequest').Model__c,
                orderId:component.get('v.assetTransferRequest').Order__c,
                reqData:component.get('v.reqData')
            }
        ).then(({resData}) => {
            if($A.util.isEmpty(resData)) {
                !$A.util.isEmpty(component.get('v.recordList')) && component.set('v.recordList', null);
                this.gfn_toast(component.get('v.noDataFound'), 'w');
                return;
            }

            component.set('v.recordList', resData);
        }).catch(({error}) => {
            this.gfn_ApexErrorHandle(error);
        });
    },

    /**
     * Asset select
     *
     * @param component
     */
    fn_select : function (component) {
        const resultList = this.gfn_getInputCheckedList(component.find('mycheck'));

        if(resultList.length > 1 || resultList.length === 0) {
            this.gfn_toast('반드시 하나의 전배 대상을 선택 해야 합니다.', 'w'); return;
        }

        const assetTransferRequest = component.get('v.assetTransferRequest');

        assetTransferRequest.AssetNo__c = resultList[0].Id;
        assetTransferRequest.AssetNo__r = resultList[0];
        assetTransferRequest.TransferDealer__c = resultList[0].Dealer__c;
        assetTransferRequest.OwnerId = resultList[0].Dealer__r.DealerOwner__c;

        component.set('v.assetTransferRequest', assetTransferRequest);

        this.gfn_closeQuickActionModal(component);
    },

    /**
     * Valid multi check
     *
     * @param component
     * @param event
     */
    fn_checkMultiSelect : function (component, event) {
        let checkList = component.find('mycheck');
        checkList = $A.util.isArray(checkList) ? checkList : [checkList];

        checkList.filter((item) => item.get('v.value') !== event.getSource().get('v.value'))
            .forEach((item) => item.set('v.checked', false));
    },

    /**
     * Request data initialization
     *
     * @param component
     */
    fn_initialize : function (component) {
        component.set('v.reqData.assetTransferTarget', 'true');
        component.set('v.reqData.assetName', '');
        component.set('v.reqData.businessOfficeName', '');
    },

    lacComService: null
});