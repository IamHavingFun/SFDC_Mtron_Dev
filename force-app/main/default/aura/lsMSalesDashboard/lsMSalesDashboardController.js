/**
 * Created by MS on 2020-06-29.
 */

({
    doInit : function(component, event, helper){
        helper.lacComService = component.find('lacComService');

/*        var targetLabel = component.get('v.sObjectName') == 'Opportunity' ? 'Opportunity': component.get('v.sObjectName')+'__c';
        helper.lacComService.doGetSobjectData(targetLabel, function(resData) {
            component.set('v.labelMap', resData);
        });*/

        helper.apex(
            component, 'doGet', 'doGet', {'sObjectName':component.get('v.sObjectName')}
        ).then(function ({resData, response}) {
            component.set('v.data', resData.data);
        }).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error, response);
        });
    }
})