/****************************************************************************************
 * @filename      : orderERPSendRetrunQa.js
 * @projectname   :
 * @author        : i2max_my.Seo
 * @date          : 2020-04-14 오전 10:15
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
 0.1     2020-04-14 오전 10:15    i2max_my.Seo          Create
 ****************************************************************************************/
({
    /**
     * init.
     *
     * @param component
     * @param event
     * @param helper
     */
    doInit: function (component, event, helper) {
        helper.apex(
            component, 'doInit', 'init', {'recordId':component.get('v.recordId')}
        ).then(function ({resData, response}) {
            component.set('v.isValidOrder', resData.isValidOrder);
            component.set('v.validMessage', resData.validMessage);
        }).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error, response);
        });
    },
    /**
     * 주문 ERP 전송
     *
     * @param component
     * @param event
     * @param helper
     */
    doSend : function (component, event, helper) {
        const recordId = component.get('v.recordId');
        helper.apex(
            component, 'doSend', 'sendERP', {
                'recordId':recordId
            }
        ).then(function ({resData, response}) {
            if(resData.STATUS == 'Y') {
                helper.gfn_toast('ERP 반품 주문 신청이 정상적으로 처리 되었습니다.','s');
                var btt = component.find('btnSend');
                btt.set('v.disabled',true);
                helper.gfn_closeQuickActionModal(component);
                helper.gfn_refresh();
            } else {
                helper.gfn_toast(resData.MESSAGE);
            }
        }).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error);
        });
    },
});