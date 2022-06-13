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
    doInit : function(component, event, helper) {

        helper.apex(
            component, 'doInit', 'init',{
                recordId :component.get('v.recordId')
            }
        ).then(function ({resData, response}) {
            component.set('v.prevContract', resData.prevContract);
            component.set('v.newContract', resData.newContract);
            component.set('v.toDay', resData.toDay);
        }).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error, response);
        });
    },

    doSave : function (component, event, helper) {

        // 날짜 체크.
        // 1. 같은 날짜 체크.
        // 2. 변경일자가 기존 날짜보다 작은것 체크.
        if(  component.get('v.newContract.CustomerExpectedDate__c') == component.get('v.prevContract.CustomerExpectedDate__c')) {
            helper.gfn_toast('기존 고객 인도기일과 다른 날짜를 입력해야 합니다.', 'w');
            return;
        }
        if(  component.get('v.newContract.CustomerExpectedDate__c') < component.get('v.toDay')) {
            helper.gfn_toast('고객 인도기일은 오늘 이후의 날짜로만 변경할 수 있습니다.', 'w');
            return;
        }

        helper.apex(
            component, 'doSave', 'save' ,{
                'newContract' : component.get('v.newContract'),
                'prevContract' : component.get('v.prevContract')
            }
        ).then(function ({resData, response}) {
            component.set('v.initData', resData);
            helper.gfn_toast('변경하신 고객 인도기일을 해당 고객님께 정상적으로 알림 발송하였습니다.','s');
            helper.gfn_closeQuickActionModal(component);
            helper.gfn_refresh();
        }).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error, response);
        });

    },


});