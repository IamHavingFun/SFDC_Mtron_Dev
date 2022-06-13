/****************************************************************************************
 * @filename      : lsMSalesAccountDetailOpptyListController.js
 * @projectname   :
 * @author        : i2max_my.Seo
 * @date          : 2020-08-05 오전 7:28
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
 0.1     2020-08-05 오전 7:28    i2max_my.Seo          Create
 ****************************************************************************************/
({
    doMoveNextPage : function (component, event, helper) {
        component.find('lacComService').doNaviService({
            "type": component.get('v.isCommunity') ? "comm__namedPage" : "standard__namedPage",
            "attributes": {
                "name": "lsMSalesOpptyDetail__c"
            },
            "state": {
                "recordId": event.currentTarget.dataset.recordid
            }
        });
    },
});