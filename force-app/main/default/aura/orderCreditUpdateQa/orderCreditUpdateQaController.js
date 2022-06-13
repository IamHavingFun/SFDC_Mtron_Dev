/****************************************************************************************
 * @filename      : orderCreditUpdateQaController.js
 * @projectname   :
 * @author        : CHOI SEONGWON
 * @date          : 2020-09-04 오후 4:57
 * @group         :
 * @group-content :
 * @description   :
 * @reference     :
 * @copyright     : Copyright © I2max. All Rights Reserved.
 * ===============================================================
 * ver     date                author              description
 * ===============================================================
    0.1                Choi SeongWon         Create
 ****************************************************************************************/
({
     doInit : function(component, event, helper){
         helper.apex(
              component, 'doInit', 'init',{
                "recordId":component.get('v.recordId')
                }
         ).then(function ({resData, response}) {
            component.set('v.order', resData);
            if(resData.Status__c != '본사 여신 검토') {
                helper.gfn_toast('주문의 상태가 본사 여신 검토인 경우만 여신문서 생성이 가능합니다.', 'w');
            }
            if($A.util.isEmpty(resData.ErpZLNNO__c) === false) {
                helper.gfn_toast('이미 추가여신승인문서의 결재가 진행 중입니다', 'w');
            }
         }).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error, response);
         });
     },

     doSave : function (component, event, helper) {

          if(  $A.util.isEmpty(component.get('v.order.ErpLRESN_T__c'))
                             &&  $A.util.isEmpty(component.get('v.order.ErpLPLAN_T__c'))
                             &&  $A.util.isEmpty(component.get('v.order.ErpLFDBK_T__c'))) {

                                 helper.gfn_toast('정보가 입력되지 않았습니다.', 'w');
                                 return;
                                                            }

         else if(     $A.util.isEmpty(component.get('v.order.ErpLRESN_T__c'))){
             helper.gfn_toast('연체사유가 입력되지 않았습니다.', 'w');
                               return;
         }
         else if(   $A.util.isEmpty(component.get('v.order.ErpLPLAN_T__c'))){
                           helper.gfn_toast('수금계획이 입력되지 않았습니다.', 'w');
                                return;
                 }
         else if(   $A.util.isEmpty(component.get('v.order.ErpLFDBK_T__c'))){
                          helper.gfn_toast('담당자 의견이 입력되지 않았습니다.', 'w');
                                  return;
                 }

         helper.apex(
              component, 'doSave', 'save' ,{
               'order' : component.get('v.order')
               }
         ).then(function ({resData, response}) {
              if($A.util.isEmpty(resData) === true) {
                  helper.gfn_toast('정상적으로 추가여신 문서 생성이 되었습니다.', 's');
                  helper.gfn_closeQuickActionModal(component);
                  helper.gfn_refresh();
              } else {
                  helper.gfn_toast(resData, 'w');
              }
         }).catch(function ({error, response}) {
              helper.gfn_ApexErrorHandle(error, response);
         });
     },


});