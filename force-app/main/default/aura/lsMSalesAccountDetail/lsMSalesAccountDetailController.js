/****************************************************************************************
 * @filename      : lsMSalesAccountDetailController.js
 * @projectname   :
 * @author        : i2max_my.Seo
 * @date          : 2020-06-17 오후 3:43
 * @group         :
 * @group-content :
 * @description   : [모바일] 고객 상세 정보
 * @tester        :
 * @reference     :
 * @copyright     : Copyright © I2max. All Rights Reserved.
 * @modification Log
 * ===============================================================
 * ver     date                     author              description
 * ===============================================================
 0.1     2020-06-17 오후 3:43       i2max_my.Seo        Create
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
        helper.lacComService = component.find('lacComService');
        helper.lacComService.doGetSobjectData('Account', function(resData) {
            component.set('v.labelMap', resData);
        });

        const params = helper.fn_getUrlParams();

        helper.apex(
            component, 'doInit', 'init', {
                'recordId':component.get('v.recordId')
            }
        ).then(function ({resData, response}) {
            component.set('v.detailData', resData);
            !!params.isReturnPage && component.set('v.tabName', 'Opportunity');
        }).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error, response);
        });
    },

    doTabChange : function (component, event, helper) {
        const tabName = event.currentTarget.dataset.tabid;
        helper.log(component, '--------------\n', tabName, '--------------\n');
        component.set('v.tabName', tabName);
    },

    doBack : function (component, event, helper) {
        component.find('lacComService').doNaviService({
            "type": component.get('v.isCommunity') ? "comm__namedPage" : "standard__namedPage",
            "attributes": {
                // 임시적으로 홈으로 세팅
                "name": "lsMSalesOpportunity__c"
            }
        });
    }
})