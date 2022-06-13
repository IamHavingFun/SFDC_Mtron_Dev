/****************************************************************************************
 * @filename      : lsMSalesCaseListController.js
 * @projectname   :
 * @author        : i2max_my.Seo
 * @date          : 2020-11-26 오후 4:59
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
 0.1     2020-11-26 오후 4:59    i2max_my.Seo          Create
 ****************************************************************************************/
({
    /**
     * Init
     *
     * @param component
     * @param event
     * @param helper
     */
    doInit : function(component, event, helper){
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
     * 신규 등록 Page
     * @param component
     * @param event
     * @param helper
     */
    doNaviRegister: function (component, event, helper) {
        component.find('lacComService').doNaviService({
            "type": component.get('v.isCommunity') ? "comm__namedPage" : "standard__namedPage",
            "attributes": {
                "name": "lsMSalesQuestionImproveRegister__c"
            }
        })
    },

    /**
     * 질문/개선 상세 조회 Page
     * @param component
     * @param event
     * @param helper
     */

    doViewDetail : function (component, event, helper) {
        component.find('lacComService').doNaviService({
            "type": component.get('v.isCommunity') ? "comm__namedPage" : "standard__namedPage",
            "attributes": {
                "name": "lsMSalesQuestionImproveDetail__c"
            },
            "state": {
                "recordId": event.currentTarget.dataset.recordid
            }
        });
    }

});