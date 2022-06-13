/**
 * Created by ms on 2020-04-08.
 */

({
    doInit: function (component, event, helper) {
        helper.lacComService = component.find('lacComService');

        helper.lacComService.doGetSobjectData('Order__c', function(resData) {
            component.set('v.labelMap', resData);
       //console.log('@@@@@@@@ resData :: ' + JSON.stringify(resData));
        });
        //console.log('@@@@@@@@ labelMap :: ' + JSON.stringify(component.get('v.labelMap')));

        helper.apex(
            component, 'getSupplyPrice', 'getSupplyPrice', {"recordId":component.get('v.recordId')}
        ).then(function ({resData, response}) {
            component.set('v.resData', resData);
        }).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error, response);
        });
    }
});