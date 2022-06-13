/**
 * Created by MS on 2020-07-06.
 */

({
    /**
     * 홈으로
     * @param component
     * @param event
     * @param helper
     */
    doCancel: function (component, event, helper) {
        component.find('lacComService').doNaviService({
            "type": component.get('v.isCommunity') ? "comm__namedPage" : "standard__namedPage",
            "attributes": {
                "name": "lsMSalesHome__c"
            }
        });
    }
});