/****************************************************************************************
 * @filename      : 
 * @projectname   :
 * @author        : Choi SeongWon
 * @date          : 2020-06-13 오후 2:46
 * @group         :
 * @group-content :
 * @description   :
 * @reference     :
 * @copyright     : Copyright © I2max. All Rights Reserved.
 * ===============================================================
 * ver           date                 author         description
 * ===============================================================
    0.1    2020-06-13 오후 2:43        Choi SeongWon      Create
 ****************************************************************************************/({

     doInit : function (component, event, helper) {
         helper.lacComService = component.find('lacComService');
         helper.fn_initSearch(component);

         helper.gfn_pageFrameReset(component, 'table', 'getSearch')
                          .then(function (params) {
                              console.log('resolve params : ', params);
                              return helper.gfn_search(component, 5, 1, params.tableId, params.apexCallMethodName);
//                             component.set('v.splitCreatedDate',splitCreatedDate);
                             
                          }).catch(function (error) {
                          helper.gfn_ApexErrorHandle(error);
                      });
     },



       doDetail : function(component,event,helper){
         component.find('lacComService').doNaviService({
                     "type": component.get('v.isCommunity') ? "comm__namedPage" : "standard__namedPage",
                     "attributes": {
                         "name": "lsMSalesNoticeDetail__c"
                     },
                     "state": {
                         "recordId": event.currentTarget.dataset.recordid
                     }
                 });
             }
})