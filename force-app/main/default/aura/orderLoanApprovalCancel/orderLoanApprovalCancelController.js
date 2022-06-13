/****************************************************************************************
 * @filename      : opportunityLossCloseQa.js
 * @projectname   : LWC_I2MAX
 * @author        : i2max_my.Seo
 * @date          : 2020-03-10 오전 9:33
 * @group         :
 * @group-content :
 * @description   : 추가 여신 승인 취소 처리
 * @tester        :
 * @reference     :
 * @copyright     : Copyright © I2max. All Rights Reserved.
 * @modification Log
 * ===============================================================
 * ver     date                     author              description
 * ===============================================================
 0.1     2020-03-10 오전 9:33     i2max_my.Seo          Create
 ****************************************************************************************/
({
    //-------------------------------------------------------------
    // 초기화
    //-------------------------------------------------------------
    doInit : function(component, event, helper){
        helper.apex(
            component, 'doInit', 'init', { 'recordId' : component.get('v.recordId')}
        ).then($A.getCallback(function ({resData, response}) {
            component.set('v.order', resData.order);
            component.set('v.isProcess', resData.isProcess);
            component.set('v.processMessage', resData.processMessage);
        })).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error, response);
        });
    },
    doSave : function(component, event, helper){
        helper.apex(
            component, 'doSave', 'save', {
                order : component.get('v.order')
            }
        ).then($A.getCallback(function ({resData, response}) {
            if(resData.returnCode === '00') {
                helper.gfn_toast('해당 주문에 대한 추가여신승인 취소 처리가 되었습니다.', 's');
                helper.gfn_refresh();
                helper.gfn_closeQuickActionModal(component)||helper.gfn_closeQuickAction(component);
            } else {
                helper.gfn_toast(resData.returnMsg, 'w');
            }

        })).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error, response);
        });
    },
    doCancel : function(component, event, helper){
        helper.gfn_closeQuickActionModal(component)||helper.gfn_closeQuickAction(component);
    }
});