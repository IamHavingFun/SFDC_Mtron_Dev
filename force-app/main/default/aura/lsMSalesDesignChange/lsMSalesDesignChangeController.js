/**
 * @filename      : ZZ_LoadDataTestController.js
 * @projectname   :
 * @author        : i2max_ParkJW
 * @date          : 2020-06-09 오전 10:58
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
 0.1     2020-06-09 오전 10:58           i2max_ParkJW        Create
 */

({
    //-------------------------------------------------------------
    // 초기화
    //-------------------------------------------------------------
    doInit : function(component, event, helper){
        helper.lacComService = component.find('lacComService');

        helper.lacComService.doGetSobjectData(['ProductChange__c'], function(resData) {
            component.set('v.labelMap', resData);
        });

        helper.apex(
            component, 'doInit', 'init', null
        ).then(function ({resData, response}) {
            component.set('v.initData', resData);

            helper.fn_initSearch(component);

            $A.enqueueAction(component.get('c.doSearch'));
        }).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error, response);
        });
    },

    //------------------------------------------------------------------------------
    // 검색
    //------------------------------------------------------------------------------
    doSearch : function (component, event, helper) {
        helper.gfn_pageFrameReset(component, 'table', 'getSearch')
            .then(function (params) {
                return helper.gfn_search(component, 5, 1, params.tableId, params.apexCallMethodName);
            }).catch(function (error) {
            helper.gfn_ApexErrorHandle(error);
        });
    },

    //------------------------------------------------------------------------------
    // 설계변경 상세조회 페이지로 이동
    //------------------------------------------------------------------------------
    doViewDetail : function (component, event, helper) {
        const recordId = event.currentTarget.dataset.recordid;

        component.find('lacComService').doNaviService({
            "type": component.get('v.isCommunity') ? "comm__namedPage" : "standard__namedPage",
            "attributes": {
                "name": "lsMSalesDesignChangeDetail__c"
            },
            "state": {
                "recordId": recordId
            }
        });
    }

});