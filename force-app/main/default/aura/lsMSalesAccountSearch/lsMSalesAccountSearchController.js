/****************************************************************************************
 * @filename      : lsMSalesAccountSearchController.js
 * @projectname   :
 * @author        : i2max_my.Seo
 * @date          : 2020-06-17 오후 3:43
 * @group         :
 * @group-content :
 * @description   : [모바일] 판매 기회 관리
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
        helper.fn_initSearch(component);
        $A.enqueueAction(component.get('c.doSearch'));
    },

    /**
     * 검색 옵션 변경시 핸들러
     * @param component
     * @param event
     * @param helper
     */
    doSearchChange: function (component, event, helper) {
        helper.listChange(component);
        if(component.get('v.reqData.searchType') === 'Asset') {
             helper.apex(
                component, 'doInit', 'getSeriesOptions', {'recordId':''}
             ).then(function({resData,response}){
                component.set('v.seriesOptions',resData);
             }).catch(function({error, response}){
                helper.gfn_ApexErrorHandle(error, response);
             });
        }
    },

    /**
     * 시리즈 변경시 핸들러
     * @param component
     * @param event
     * @param helper
     */
    doSeriesChange: function (component, event, helper) {
        helper.apex(
            component, 'doInit', 'getHorsePowerStandardOptions', {

               'series': component.get('v.reqData.srchSeries')
            }
        ).then(function ({resData, response}) {
            component.set('v.horsePowerStandardOptions', resData);
        }).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error, response);
        });
    },

    /**
     * 검색
     * @param component
     * @param event
     * @param helper
     */
    doSearch : function (component, event, helper) {

//              console.log(JSON.stringify(component.get('v.resData')));

              helper.gfn_pageFrameReset(component, 'table', 'getSearch')
                  .then(function (params) {
                      console.log('resolve params : ', params);
                      return helper.gfn_search(component, 15, 1, params.tableId, params.apexCallMethodName);
                  }).catch(function (error) {
                  helper.gfn_ApexErrorHandle(error);
              });

          },


    /**
     * 고객 상세 페이지.
     * @param component
     * @param event
     * @param helper
     */
    doDetail : function(component,event,helper){
        component.find('lacComService').doNaviService({
            "type": component.get('v.isCommunity') ? "comm__namedPage" : "standard__namedPage",
            "attributes": {
                "name": "lsMSalesAccountDetail__c"
            },
            "state": {
                "recordId": event.currentTarget.dataset.recordid
            }
        });
    },


})