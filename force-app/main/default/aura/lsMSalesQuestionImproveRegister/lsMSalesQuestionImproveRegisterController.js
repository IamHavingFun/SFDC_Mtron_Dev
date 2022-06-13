/****************************************************************************************
 * @filename      : lsMSalesQuestionImproveRegisterController.js
 * @projectname   :
 * @author        : SEOKHO LEE
 * @date          : 2020-06-11 오전 11:22
 * @group         :
 * @group-content :
 * @description   : [모바일] 질문/개선 신규 등록
 * @tester        :
 * @reference     :
 * @copyright     : Copyright © I2max. All Rights Reserved.
 * @modification Log
 * ===============================================================
 * ver     date                     author              description
 * ===============================================================
 0.1     2020-06-11 오전 11:22     SEOKHO LEE          Create
 ****************************************************************************************/
({
    /**
     * 초기화
     * @param component
     * @param event
     * @param helper
     */
    doInit: function (component, event, helper) {

        const pageReference = helper.fn_getUrlParams();
        helper.apex(component, 'doInit', 'init',
            {'recordId' : pageReference.recordId}
            /*component.get('v.recordId') != null ? { 'recordId' : component.get('v.recordId') } : {}*/
        ).then(function ({resData, response}) {
            component.set('v.caseCreateData', resData);
            $A.util.isEmpty(component.get('v.caseCreateData.assetName')) ? component.set('v.caseCreateData.assetName', '') : null;
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
    doSave: function (component, event, helper) {
        if(helper.fn_checkValid(component,helper)){
            helper.apex( component, 'doSave', 'save', {'caseCreateData': component.get('v.caseCreateData')
            }).then(function ({resData, response}) {
                helper.fn_doMoveDetail(component, resData.Id);
            }).catch(function ({error, response}) {
                helper.gfn_ApexErrorHandle(error, response);
            });
        }
    },

    /**
     * 목록 이동
     * @param component
     * @param event
     * @param helper
     */
    doCancel : function (component, event, helper) {
        helper.fn_doMoveList(component);
    }
})