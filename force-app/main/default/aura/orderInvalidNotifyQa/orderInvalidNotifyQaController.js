/****************************************************************************************
 * @filename      : orderInvalidNotifyQaController.js
 * @projectname   :
 * @author        : i2max_my.Seo
 * @date          : 2020-07-21 오후 2:19
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
 0.1     2020-07-21 오후 2:19    i2max_my.Seo          Create
 ****************************************************************************************/
({
    doNavigateToOrder : function (component, event, helper) {
        component.find('lacComService').doNaviService({
            "type": "standard__recordPage",
            "attributes": {
                "recordId": component.get('v.orderId'),
                "objectApiName": "Order__c",
                "actionName": "view"
            }
        });
        helper.gfn_closeQuickActionModal(component);
    },
});