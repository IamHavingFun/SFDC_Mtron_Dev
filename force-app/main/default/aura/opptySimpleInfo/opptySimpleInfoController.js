/**
 * Created by ms on 2020-04-08.
 */

({
    doInit: function (component, event, helper) {
        helper.apex(
            component, 'getOpptySimpleInfo', 'getOpptySimpleInfo', {"recordId":component.get('v.recordId')}
        ).then(function ({resData, response}) {
            component.set('v.resData', resData);
        }).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error, response);
        });
    },

    doNaviService : function(component, event, helper){
            const recordId = event.currentTarget.dataset.recordid;
            const recordType = event.currentTarget.dataset.recordtype;

            component.find('lacComService').doNaviService({
                "type": "standard__recordPage",
                "attributes": {
                    "recordId": recordId,
                    "objectApiName": "Account",
                    "actionName": "view"
                }
            });
        },
});