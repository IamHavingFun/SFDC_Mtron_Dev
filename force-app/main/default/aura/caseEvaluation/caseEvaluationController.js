/****************************************************************************************
 * @filename      : caseEvaluationController.js
 * @projectname   :
 * @author        : SEOKHO LEE
 * @date          : 2020-06-05 오전 11:23
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
 0.1     2020-06-05 오전 11:23     SEOKHO LEE          Create
 ****************************************************************************************/
({
    /**
     * Init
     * @param component
     * @param event
     * @param helper
     */
    doInit: function (component, event, helper) {
        helper.apex(
            component, 'doInit', 'init', {
                'recordId':component.get('v.recordId') }
        ).then(function ({resData, response}) {
            component.set('v.initData',resData);
            switch (resData.caseData.Status) {
                case '답변 완료 및 평가 대기':
                    component.set('v.isDisabled', false); break;
                case '평가 완료 및 마감':
                    helper.gfn_toast('이미 종료된 건입니다.', 'w'); break;
                default :
                    helper.gfn_toast('지금 요청건에 대한 검토 진행 중입니다.', 'w'); break;
            }
        }).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error, response);
        });
    },

    /**
     * save
     * @param component
     * @param event
     * @param helper
     */
    doSave : function (component, event ,helper) {
        helper.apex(
            component, 'doSave', 'save',
            {'caseData' : component.get('v.initData').caseData}
        ).then(function ({resData, response}) {
            helper.gfn_closeQuickAction();
            helper.gfn_refresh();
        }).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error, response);
        });
    },
})