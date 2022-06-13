/****************************************************************************************
 * @filename      : lsMSalesContractListController.js
 * @projectname   :
 * @author        : i2max_my.Seo
 * @date          : 2020-06-15 오전 10:34
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
 0.1     2020-06-15 오전 10:34    i2max_my.Seo          Create
 ****************************************************************************************/
({
    /**
     * 초기화
     * @param component
     * @param event
     * @param helper
     */
    doInit : function (component, event, helper) {
        helper.fn_initSearch(component);

        $A.enqueueAction(component.get('c.doSearch'));
    },

    doSearch : function (component, event, helper) {
        helper.gfn_pageFrameReset(component)
            .then(function (params) {
                return helper.gfn_search(component, 10, 1);
            }).catch(function (error) {
            helper.gfn_ApexErrorHandle(error);
        });
    },

    doMoveRegister : function (component, event, helper) {
        const evt = event.getSource();

        const contractId = evt.get('v.value');
        const type = evt.get('v.label');
        let isModify = false;
        let isWait   = false;

        isModify = (type === '계약서 작성중') ? !isModify : isModify;
        isWait = (type === '출고 대기중') ? !isWait : isWait;

        component.find('lacComService').doNaviService({
            "type": component.get('v.isCommunity') ? "comm__namedPage" : "standard__namedPage",
            "attributes": {
                "name": "lsMSalesContractRegister__c"
            },
            "state": {
                "recordId": contractId,
                "isModify": isModify,
                "isWait":isWait
            }
        });
    },
});