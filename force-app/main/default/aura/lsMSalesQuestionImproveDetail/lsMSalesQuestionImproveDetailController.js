/****************************************************************************************
 * @filename      : lsMSalesQuestionImproveDetailController.js
 * @projectname   :
 * @author        : SEOKHO LEE
 * @date          : 2020-06-18 오후 3:25
 * @group         :
 * @group-content :
 * @description   : [모바일] 질문/개선 상세조회
 * @tester        :
 * @reference     :
 * @copyright     : Copyright © I2max. All Rights Reserved.
 * @modification Log
 * ===============================================================
 * ver     date                     author              description
 * ===============================================================
 0.1     2020-06-18 오후 3:25      SEOKHO LEE          Create
 ****************************************************************************************/
({
    /**
     * Init
     *
     * @param component
     * @param event
     * @param helper
     */
    doInit : function(component, event, helper) {
        
        helper.lacComService = component.find('lacComService');
        helper.lacComService.doGetSobjectData('Case', function(resData) {
            component.set('v.labelMap', resData);
        });
        helper.apex(
            component, 'doInit', 'init',
            {'recordId' : component.get('v.recordId')}
        ).then(function ({resData, response}) {
            component.set('v.wrapperData', resData);
            component.set('v.recordId', resData.caseData.Id);
            console.log(resData.caseData.Id);
            delete(resData.caseData.Id);
            console.log(resData.caseData.Id);
        }).catch(function ({error, response}) {
            helper.log(component, error);
            helper.gfn_ApexErrorHandle(error, response);
        });
    },

    handleUploadFinished: function (component, event, helper) {
        helper.gfn_refresh();
    },

    /**
     * 목록 이동
     * @param component
     * @param event
     * @param helper
     */
    doCancel : function (component, event, helper) {
        helper.fn_doMoveList(component);
    },

   /* /!**
     * save
     * @param component
     * @param event
     * @param helper
     *!/
    doSave : function (component, event, helper) {
        console.log(JSON.stringify(component.get('v.wrapperData.caseData')));
        helper.apex(
            component, 'doSave', 'save',
            {'wrapperData' : component.get('v.wrapperData')}
        ).then(function ({resData, response}) {
            helper.fn_doMoveList(component);
        }).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error, response);
        });
    },*/

   doEdit : function (component, event, helper) {
        component.find('lacComService').doNaviService({
            "type": component.get('v.isCommunity') ? "comm__namedPage" : "standard__namedPage",
            "attributes": {
                "name": "lsMSalesQuestionImproveRegister__c"
            },
            "state": {
                "recordId": component.get('v.recordId')
            }
        })
    },
    doEvaluation : function (component, event, helper) {
        helper.gfn_createComponent(component, 'lsMSalesCaseEvaluationQa', {'recordId': component.get('v.recordId')});
    },
})