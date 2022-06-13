/****************************************************************************************
 * @filename      : lsMSalesWarrantyClaimController.js
 * @projectname   :
 * @author        : SEOKHO LEE
 * @date          : 2020-06-19 오후 2:07
 * @group         :
 * @group-content :
 * @description   : [모바일] LWS 클레임
 * @tester        :
 * @reference     :
 * @copyright     : Copyright © I2max. All Rights Reserved.
 * @modification Log
 * ===============================================================
 * ver     date                     author              description
 * ===============================================================
 0.1     2020-06-19 오후 2:07      SEOKHO LEE          Create
 ****************************************************************************************/
({
    /**
     * init
     * @param component
     * @param event
     * @param helper
     */
    doInit : function(component, event, helper){
        helper.lacComService = component.find('lacComService');
        helper.fn_initSearch(component);
        $A.enqueueAction(component.get('c.doSearch'));
    },
    /**
     * 검색
     * @param component
     * @param event
     * @param helper
     */
    doSearch : function (component, event, helper) {
        helper.gfn_pageFrameReset(component, 'table', 'getSearch')
            .then(function (params) {
                return helper.gfn_search(component, component.get('v.pageSize'), 1, params.tableId, params.apexCallMethodName);
            }).catch(function (error) {
            helper.gfn_ApexErrorHandle(error);
        });
    },

    /**
     * LWS 클레임 상세 조회 Page
     * @param component
     * @param event
     * @param helper
     */
    doViewDetail : function (component, event, helper) {
        component.find('lacComService').doNaviService({
        "type": component.get('v.isCommunity') ? "comm__namedPage" : "standard__namedPage",
        "attributes": {
            "name": "lsMSalesWarrantyClaimDetail__c"
        },
        "state": {
            "recordId": event.currentTarget.dataset.recordid
        }
    });
}
    
})