/****************************************************************************************
 * @filename      : 
 * @projectname   :
 * @author        : Choi SeongWon
 * @date          : 2020-06-23 오후 5:21
 * @group         :
 * @group-content :
 * @description   :
 * @reference     :
 * @copyright     : Copyright © I2max. All Rights Reserved.
 * ===============================================================
 * ver     date                   author             description
 * ===============================================================
    0.1  2020-06-23 오후 5:21    Choi SeongWon          Create
 ****************************************************************************************/({


     doInit : function (component, event, helper) {

             helper.lacComService = component.find('lacComService');
             helper.lacComService.doGetSobjectData('NoticeBoard__C', function(resData) {
                        component.set('v.labelMap', resData);
             });

             helper.apex(
                component, 'doInit', 'init', {
                       'recordId':component.get('v.recordId')
                }
                ).then(function({resData, response}){
                component.set('v.detailData',resData);
                }).catch(function ({error, response}) {
                     helper.gfn_ApexErrorHandle(error, response);
                   });
     },

     doBack : function(component,event,helper){
              helper.lacComService.doNaviService({
                 "type": component.get('v.isCommunity') ? "comm__namedPage" : "standard__namedPage",
                 "attributes": {

                        "name": "lsMSalesNotice__c"
                                }
              });

     },

})