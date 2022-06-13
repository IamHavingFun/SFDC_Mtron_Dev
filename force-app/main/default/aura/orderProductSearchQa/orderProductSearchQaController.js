/****************************************************************************************
 * @filename      : orderProductSearchQaController.js
 * @projectname   :
 * @author        : i2max_my.Seo
 * @date          : 2020-04-16 오후 1:20
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
 0.1     2020-04-16 오후 1:20    i2max_my.Seo          Create
 ****************************************************************************************/
({
    /**
     * init.
     *
     * @param component
     * @param event
     * @param helper
     */
    doInit: function (component, event, helper) {
        helper.lacComService = component.find('lacComService');

        helper.lacComService.doGetSobjectData(['Product2'], function(resData) {
            component.set('v.productLabel', resData.Product2);
        });

        helper.apex(
            component, 'doInit', 'init', {}
        ).then(function ({resData, response}) {
            component.set('v.seriesList', resData.seriesList);

            helper.fn_initSearch(component);

            const dealerId = component.get('v.wrapperData.order.Dealer__c');
            const productId = component.get('v.wrapperData.order.OrderProduct__c');
            component.set('v.reqData.dealerId', dealerId);
            component.set('v.reqData.productId', productId);

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
     * 최소 한 개의 record를 선택 하게 처리 및 해당 cmp 닫음.
     *
     * @param component
     * @param event
     * @param helper
     */
    doSelect : function (component, event, helper) {
        helper.fn_select(component, event, helper);
    },

    doChangeProductSeries : function (component, event, helper) {
        helper.fn_getProductSeries(component, event, helper, component.get('v.reqData.productType'));
    },
});