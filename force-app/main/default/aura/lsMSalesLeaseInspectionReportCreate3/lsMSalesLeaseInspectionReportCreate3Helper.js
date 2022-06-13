/****************************************************************************************
 * @filename      : lsMSalesLeaseInspectionReportCreate3Helper.js
 * @author        : I2MAX
 * @date          : 2021-04-15
 * @group         :
 * @group-content :
 * @description   :
 * @tester        :
 * @reference     :
 * @release       : v1.0.0
 * @copyright     : Copyright © I2max. All Rights Reserved.
 * @modification Log
 * ===============================================================
 * ver     date                    author        description
 * ===============================================================
 0.1     2021-04-15         I2MAX          Create
 ****************************************************************************************/
({
    fn_afterUploadFinished: function (component, event) {
        const targetCmp = event.getSource();

        targetCmp.set('v.disabled', true);
    },

    fn_close : function (component) {
        component.find('lacComService').doNaviService({
            "type": component.get('v.isCommunity') ? "comm__namedPage" : "standard__namedPage",
            "attributes": {
                "name": "lsMSalesHome__c"
            },
            "state": {
                "recordId": component.get("v.mobileStepVO.bizData.contract.Id")
            }
        });
    },
});