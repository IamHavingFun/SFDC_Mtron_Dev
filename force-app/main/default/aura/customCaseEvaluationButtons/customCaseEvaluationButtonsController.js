/****************************************************************************************
 * @filename      : caseButtonAreaController.js
 * @projectname   :
 * @author        : SEOKHO LEE
 * @date          : 2020-06-08 오전 11:01
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
 0.1     2020-06-08 오전 11:01     SEOKHO LEE          Create
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
            component.set('v.isEvaluationProcess',resData);
        }).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error, response);
        });
    },
    /**
     * Quick Action을 생성하기 위한 함수
     * @param component
     * @param event
     * @param helper
     */
    doMoveCaseEvaluation: function (component, event, helper) {
        helper.gfn_createComponent(component, 'customCaseEvaluation', {
            'recordId': component.get('v.recordId')
        }, 'slds-modal_medium');
    }
})