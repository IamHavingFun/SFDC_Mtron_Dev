/****************************************************************************************
 * @filename      : lsMSalesLeaseInspectionReportCreate2Helper.js
 * @author        : I2MAX
 * @date          : 2021-03-31
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
 0.1     2021-03-31         I2MAX          Create
 ****************************************************************************************/
({
    /**
     * 저장 완료 후, Home 화면으로 이동
     *
     * @param component
     */
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