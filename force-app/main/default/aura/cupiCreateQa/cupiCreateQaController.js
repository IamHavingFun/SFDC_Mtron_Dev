/**
 *  @filename      : cupiCreateQaController.js
 * @projectname   :
 * @author        : SEOKHO LEE
 * @date          : 2020-05-14 오전 8:30
 * @group         :
 * @group-content :
 * @description   :
 * @tester        :
 * @reference     :
 * @copyright     : Copyright © I2max. All Rights Reserved.
 * @modification Log
 * ===============================================================
 * ver     date                     author              description
 * ===============================================================
 0.1     2020-05-14 오전 8:30       SEOKHO LEE          Create
 */
({
    /**
     * 초기화
     * @param component
     * @param event
     * @param helper
     */
    doInit : function (component, event, helper) {
        helper.apex(component,'doInit', 'init' ,
            {'recordId' : component.get('v.recordId')}
        ).then(function ({resData,response}) {
            component.set('v.wrapperData',resData);
        }).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error, response);
        })
    },

    /**
     * 저장
     * @param component
     * @param event
     * @param helper
     */
    doSave : function (component, event ,helper) {
        helper.apex(
            component, 'doSave', 'save',
            {'wrapperData' : component.get('v.wrapperData')}
        ).then(function ({resData, response}) {
            helper.gfn_closeQuickAction();
            helper.gfn_refresh();
        }).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error, response);
        });
    },

    /**
     * 체크박스
     * @param component
     * @param event
     * @param helper
     */
    doChange: function (component, event) {
        const e = event.getSource();
        const setCupiField = 'v.wrapperData.cupi.'+ e.getLocalId();
        const checked = e.get('v.checked');
        const value = e.get('v.value');
        (checked === value) ? component.set(setCupiField, value) : component.set(setCupiField, !checked);
    }
})