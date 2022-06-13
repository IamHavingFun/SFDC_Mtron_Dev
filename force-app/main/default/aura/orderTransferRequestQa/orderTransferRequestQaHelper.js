/****************************************************************************************
 * @filename      : orderTransferRequestQaHelper.js
 * @projectname   :
 * @author        : i2max_my.Seo
 * @date          : 2020-11-20 오전 9:12
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
   0.1     2020-11-20 오전 9:12    i2max_my.Seo          Create
 ****************************************************************************************/
({
    /**
     * Init
     *
     * @param component
     */
    fn_init : function (component) {
        this.lacComService = component.find('lacComService');

        this.apex(
            component, 'fn_init', 'init', {
                recordId:component.get('v.recordId')
            }
        ).then(({resData}) => {
            component.set('v.assetTransferRequest', resData.assetTransferRequest);
            component.set('v.isTransferAgree', resData.isTransferAgree);
            component.set('v.isRequestProcess', resData.isRequestProcess);
            component.set('v.notiMessage', resData.notiMessage);
        }).catch(({error}) => {
            this.gfn_ApexErrorHandle(error);
        });
    },

    /**
     * Save
     *
     * @param component
     */
    fn_save : function (component) {
        const assetTransferRequest = component.get('v.assetTransferRequest');

        if($A.util.isEmpty(assetTransferRequest.AssetNo__c)) {
            this.gfn_toast('전배를 선택해야 합니다.', 'w');
            return;
        }

        assetTransferRequest.AssetNo__r = null;

        this.apex(
            component, 'fn_save', 'save', {
                assetTransferRequest:assetTransferRequest
            }
        ).then(({resData}) => {
            this.gfn_toast(component.get('v.save'), 's');
            this.fn_navigateToAssetTransferRequest(component, resData);
            this.gfn_closeQuickActionModal(component);
        }).catch(({error}) => {
            this.gfn_ApexErrorHandle(error);
        });
    },

    /**
     * Create orderTransferSearchQa modal pop-up
     *
     * @param component
     */
    fn_createOrderTransferSearchQa : function (component) {
        this.gfn_createComponent(component, 'orderTransferSearchQa', {
            assetTransferRequest:component.getReference('v.assetTransferRequest'),
            productName:component.get('v.assetTransferRequest').Model__r.Name
        }, 'slds-modal_medium');
    },

    /**
     * Navigate to saved AssetTransFerRequest Id
     *
     * @param component
     * @param recordId
     */
    fn_navigateToAssetTransferRequest : function (component, recordId) {
        this.lacComService.doNaviService({
            "type": "standard__recordPage",
            "attributes": {
                "recordId": recordId,
                "actionName": "view"
            }
        });
    },

    lacComService:null
});