/****************************************************************************************
 * @filename      : orderAssetDisplayQaController.js
 * @projectname   :
 * @author        : i2max_my.Seo
 * @date          : 2020-04-20 오후 2:06
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
 0.1     2020-04-20 오후 2:06    i2max_my.Seo          Create
 ****************************************************************************************/
({
    /**
     * Init
     *
     * @param component
     * @param event
     * @param helper
     */
    doInit: function (component, event, helper) {
        helper.lacComService = component.find('lacComService');

        helper.lacComService.doGetSobjectData(['Product2', 'Asset'], function(resData) {
            component.set('v.labelMap', resData);
        });

        helper.apex(
            component, 'doInit', 'init', {}
        ).then(function ({resData, response}) {
            component.set('v.seriesList', resData.seriesList);
            component.set('v.productTypeList', resData.productTypeList);

            helper.fn_initSearch(component);

            !$A.util.isEmpty(component.get('v.productName')) && component.set('v.reqData.name', component.get('v.productName'));

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

    doCancel : function (component, event, helper) {
        helper.gfn_closeQuickActionModal(component);
    },
});