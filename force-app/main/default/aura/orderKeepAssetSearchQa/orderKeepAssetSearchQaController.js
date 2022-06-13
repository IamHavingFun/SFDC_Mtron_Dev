/****************************************************************************************
 * @filename      : orderOpportunitySearchQaController.js
 * @projectname   :
 * @author        : i2max_my.Seo
 * @date          : 2020-04-16 오후 5:18
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
 0.1     2020-04-16 오후 5:18    i2max_my.Seo          Create
 ****************************************************************************************/
({
    /**
     * Init.
     *
     * @param component
     * @param event
     * @param helper
     */
    doInit: function (component, event, helper) {
        component.find('lacComService').doGetSobjectData(['Product2', 'Asset'], function(resData) {
            component.set('v.labelMap', resData);
        });

        helper.apex(
            component, 'doInit', 'init', {'recordId' : component.get('v.recordId')}
        ).then(function ({resData, response}) {
            component.set('v.orderKeep', resData.orderKeep);
            component.set('v.isButtonSave', resData.isButtonSave);
            component.set('v.pageComment', resData.pageComment);

            if(resData.isButtonSave === false) {
                helper.gfn_toast(resData.pageComment, 'w');
                return;
            }
            helper.fn_initSearch(component);
            component.set('v.reqData.productId', resData.orderKeep.Order__r.OrderProduct__c);
            $A.enqueueAction(component.get('c.doSearch'));

        }).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error, response);
        });
    },

    /**
     * Search.
     *
     * @param component
     * @param event
     * @param helper
     */
    doSearch : function (component, event, helper) {
        helper.gfn_pageFrameReset(component, 'table', 'getSearch')
            .then(function (params) {
                return helper.gfn_search(component, 10, 1, params.tableId, params.apexCallMethodName);
            }).catch(function (error) {
            helper.gfn_ApexErrorHandle(error);
        });
    },

    /**
     * 최소 한 개의 record 선택 및 선택한 record attribute에 할당 후 cmp 닫음.
     *
     * @param component
     * @param event
     * @param helper
     */

    doSelect : function (component, event, helper) {
        helper.fn_select(component, event, helper);
    },

    doCheck : function (component, event, helper) {
        helper.fn_check(component, event);
    },

    /**
     * Cancel.
     *
     * @param component
     * @param event
     * @param helper
     */
    doCancel : function (component, event, helper) {
        helper.gfn_closeQuickAction(component);
    }
});