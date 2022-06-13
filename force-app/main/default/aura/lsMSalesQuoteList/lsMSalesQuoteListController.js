/****************************************************************************************
 * @filename      : lsMSalesQuoteListController.js
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
     * init.
     *
     * @param component
     * @param event
     * @param helper
     */
    doInit : function (component, event, helper) {
        helper.fn_initSearch(component);

        helper.lacComService = component.find('lacComService');

        $A.enqueueAction(component.get('c.doSearch'));
    },

    /**
     * Search.
     *
     * @param component
     * @param event
     * @param helper
     */
    doSearch : function (component, event, helper) {
        helper.gfn_pageFrameReset(component)
            .then(function (params) {
                return helper.gfn_search(component, 10, 1);
            }).catch(function (error) {
            helper.gfn_ApexErrorHandle(error);
        });
    },


    //==============================================================================
    // 같은 community page를 호출 하지만 state 값 변경이 다름.
    //==============================================================================


    /**
     * quote 생성.
     *
     * @param component
     * @param event
     * @param helper
     */
    doNewQuote : function (component, event, helper) {
        helper.lacComService.doNaviService({
            "type": component.get('v.isCommunity') ? "comm__namedPage" : "standard__namedPage",
            "attributes": {
                "name": "lsMSalesQuoteRegister__c"
            },
            "state":{
                "type":"i"
            }
        });
    },

    /**
     * quote 수정.
     *
     * @param component
     * @param event
     * @param helper
     */
    doModifyQuote : function (component, event, helper) {
        const record = event.getSource().get('v.value');

        // if($A.util.isEmpty(record.Opportunity__c)) {
        //     helper.gfn_toast('견적에 연결된 기회가 없습니다.', 'w');
        //     return;
        // }

        helper.lacComService.doNaviService({
            "type": component.get('v.isCommunity') ? "comm__namedPage" : "standard__namedPage",
            "attributes": {
                "name": "lsMSalesQuoteRegister__c"
            },
            "state": {
                "type":"m",
                "quoteId":record.Id
            }
        });
    },

    /**
     * quote 보기.
     *
     * @param component
     * @param event
     * @param helper
     */
    doViewQuote : function (component, event, helper) {
        const record = event.getSource().get('v.value');

        helper.log(component, '@@@@@ record.Id : ' + record.Id);

        helper.lacComService.doNaviService({
            "type": component.get('v.isCommunity') ? "comm__namedPage" : "standard__namedPage",
            "attributes": {
                "name": "lsMSalesQuoteRegister__c"
            },
            "state":{
                "type":"v",
                "quoteId":record.Id
            }
        });
    },
});