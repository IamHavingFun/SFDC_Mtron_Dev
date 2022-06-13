/****************************************************************************************
 * @filename      : lsMSalesOpptyDetailController.js
 * @projectname   :
 * @author        : i2max_my.Seo
 * @date          : 2020-08-04 오후 5:28
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
 0.1     2020-08-04 오후 5:28    i2max_my.Seo          Create
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

        helper.apex(
            component, 'doInit', 'init', {opptyId:component.get('v.recordId')}
        ).then(function ({resData, response}) {
            component.set('v.resData', resData);
        }).catch(function (error, response) {
            helper.gfn_ApexErrorHandle(error, response);
        });
    },

    doMovePrevPage : function (component, event, helper) {
        helper.lacComService.doNaviService({
            "type": component.get('v.isCommunity') ? "comm__namedPage" : "standard__namedPage",
            "attributes": {
                "name": "lsMSalesAccountDetail__c"
            },
            "state": {
                "recordId": component.get('v.resData.AccountId'),
                "isReturnPage":true
            }
        });
    },

    doMoveQuoteRegister : function (component, event, helper) {
        const oppty = component.get('v.resData');
        const label = event.getSource().get('v.label');

        const type = (label === '견적서 작성') ? 'i' : (label === '견적서 수정') ? 'm' : 'v';
        const opptyId = $A.util.isEmpty(oppty.QuoteLineItem__r) ? oppty.Id : '';
        const quoteId = $A.util.isEmpty(oppty.QuoteLineItem__r) ? '' : oppty.QuoteLineItem__r[0].Quote__c;

        helper.lacComService.doNaviService({
            "type": component.get('v.isCommunity') ? "comm__namedPage" : "standard__namedPage",
            "attributes": {
                "name": "lsMSalesQuoteRegister__c"
            },
            "state": {
                "type":type,
                "opptyId":opptyId,
                "quoteId":quoteId
            }
        });
    },
});