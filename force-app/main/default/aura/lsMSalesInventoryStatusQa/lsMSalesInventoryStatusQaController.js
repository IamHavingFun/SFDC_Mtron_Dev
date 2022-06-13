/****************************************************************************************
 * @filename      : lsMSalesInventoryStatusQaController.js
 * @projectname   :
 * @author        : i2max_ParkJW
 * @date          : 2020-06-19 오후 2:11
 * @group         :
 * @group-content :
 * @description   :
 * @tester        :
 * @reference     :
 * @copyright     : Copyright © I2max. All Rights Reserved.
 * @modification Log
 * ===============================================================
 * ver     date                    author              description
 * ===============================================================
 0.1     2020-06-19 오후 2:11           i2max_ParkJW        Create
 ****************************************************************************************/

({
    //-------------------------------------------------------------
    // 초기화
    //-------------------------------------------------------------
    doInit : function(component, event, helper) {
        helper.apex(
            component, 'doInit', 'init', {
                'targetProduct':component.get('v.targetProduct')
            }
        ).then(function ({resData, response}) {
            component.set('v.recordList', resData);
            // 데이터 없을때 로직 추가 예정
            $A.util.isEmpty(resData) && helper.gfn_toast('보유중인 재고가 없습니다.', 'w');
        }).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error, response);
        });
    },

    /**
     * close
     * @param component
     * @param event
     * @param helper
     */
    doCancel : function(component, event, helper) {
        helper.gfn_closeQuickActionModal(component);
    }
});