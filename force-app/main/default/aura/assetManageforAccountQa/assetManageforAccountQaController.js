/****************************************************************************************
 * @filename      : assetManageforAccountQa
 * @projectname   :
 * @author        : Choi SeongWon
 * @date          : 2020-05-14 오전 09:06
 * @group         :
 * @group-content :
 * @description   :
 * @reference     :
 * @copyright     : Copyright © I2max. All Rights Reserved.
 * ===============================================================
 * ver     date                     author              description
 * ===============================================================
    0.1     2020-05-14 오전 09:06    Choi SeongWon         Create
    0.2     2020-07-08 오전 09:00     SEOKHO LEE           Modify
 ****************************************************************************************/
({

    doInit : function(component, event, helper ){
        helper.lacComService = component.find('lacComService');
        helper.lacComService.doGetSobjectData(['Product2','Asset'], function(resData){
                component.set('v.labelMap', resData);
            });
            helper.apex(
                component, 'doInit', 'init', {'recordId' : component.get('v.recordId')}
            ).then(function({resData,response}){
                helper.fn_initSearch(component);
                component.set('v.customerData', resData);
            }).catch(function ({error, response}){
                helper.gfn_ApexErrorHandle(error, response);
        });
    },

   onCheck : function(component, event, helper){
       // event 된 것만 checked 표시
       const eventComponent = event.getSource();
       const checkedRecord = eventComponent.get('v.value');

       // 모든 checkbox 배열처리
       let checkList = component.find('mycheck');
       checkList = $A.util.isArray(checkList) ? checkList : [checkList];

       // 나머지 checkbox false 처리
       checkList.filter((item) => item.get('v.value').Id !== checkedRecord.Id)
           .forEach((item) => item.set('v.checked', false));

       // checked 된 record 값을 asset에 세팅
       component.set('v.customerData.asset', (eventComponent.get('v.checked') ? checkedRecord : null));

       helper.log(component, 'checked asset : ', component.get('v.customerData.asset'));
   },

    doSearch : function(component, event, helper){
         helper.gfn_pageFrameReset(component, 'table', 'getSearch')
            .then(function (params) {
                // 초기화 : 이미 선택된 asset을 초기화함
                component.set('v.customerData.asset', null);
                return helper.gfn_search(component, 10, 1, params.tableId, params.apexCallMethodName);
            }).catch(function (error) {
                helper.gfn_ApexErrorHandle(error);
            });
    },

    doSave : function (component, event, helper) {
        if(helper.fn_saveCondition(component, helper)){
              helper.apex(component, 'doSave', 'save',{
                    // 선택된 asset은 doCheck 시 바로 저장이 된다.
                   'customerData' : component.get('v.customerData')
               }).then(function ({resData, response}){
                   helper.gfn_toast('정상적으로 저장되었습니다.','s');
                   helper.gfn_refresh();
                   helper.gfn_closeQuickActionModal(component);
               }).catch(function ({error, response}) {
                   helper.gfn_ApexErrorHandle(error, response);
               });
          }
    },


});