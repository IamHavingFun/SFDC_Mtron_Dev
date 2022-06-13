/****************************************************************************************
 * @filename      : lsMSalesCaseEvaluationQa.js
 * @projectname   :
 * @author        : i2max_my.seo
 * @date          : 2020-06-11 오전 11:22
 * @group         :
 * @group-content :
 * @description   : [모바일] 질문/개선 대리점 평가.
 * @tester        :
 * @reference     :
 * @copyright     : Copyright © I2max. All Rights Reserved.
 * @modification Log
 * ===============================================================
 * ver     date                     author              description
 * ===============================================================
 0.1     2020-06-11 오전 11:22     i2max_my.seo          Create
 ****************************************************************************************/
({
    /**
     * 초기화
     * @param component
     * @param event
     * @param helper
     */
    doInit : function (component, event, helper) {
        helper.apex(component,'doInit', 'init', {'recordId':component.get('v.recordId')}
        ).then(function ({resData,response}) {
            helper.log(component, '=======init 실행=======');
            helper.log(component, resData);
            helper.log(component, '=======================');
            component.set('v.caseRec',resData);
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
        helper.log(component, '=======save 실행=======');
        helper.log(component, component.get('v.caseRec'));
        helper.log(component, '=======================');

        let DealerFeedback = component.get('v.caseRec.DealerFeedback__c');
        let Comment = component.get('v.caseRec.DealerFeedbackComment__c');
        if(DealerFeedback === '재검토 요청' && $A.util.isEmpty(Comment)) {
            helper.gfn_toast('재검토 요청 사유를 기입 해주세요.', 'w');
            return false;
        }
        helper.apex(
            component, 'doSave', 'save',
            {'caseRec' : component.get('v.caseRec')}
        ).then(function ({resData, response}) {
            helper.gfn_toast('평가 등록이 처리 되었습니다.', 's');
            helper.gfn_closeQuickActionModal(component);
            helper.gfn_refresh();
        }).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error, response);
        });

    },
    doCancel : function (component, event, helper) {
        helper.gfn_closeQuickActionModal(component);
    },
    doSelected : function (component, event, helper) {
        const selecteval = event.currentTarget.dataset.selecteval;
        helper.log(component, '--------------\n', selecteval, '--------------\n');
        component.set('v.caseRec.DealerFeedback__c', selecteval);
    },
})