/****************************************************************************************
 * @filename      : lsMSalesQuestionImproveRegisterHelper.js
 * @projectname   :
 * @author        : SEOKHO LEE
 * @date          : 2020-06-29 오전 10:29
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
 0.1     2020-06-29 오전 10:29      SEOKHO LEE          Create
 ****************************************************************************************/
({
    /**
     * valid Check
     * @param component
     * @param helper
     * @returns {boolean}
     */
    fn_checkValid: function (component, helper) {
        if($A.util.isEmpty(component.get('v.caseCreateData.caseData.Subject'))) {
            helper.gfn_toast('제목을 입력하세요.', 'w');
            return false;
        }
        if($A.util.isEmpty(component.get('v.caseCreateData.caseData.Type'))) {
            helper.gfn_toast('유형을 선택하세요.', 'w');
            return false;
        }
        if($A.util.isEmpty(component.get('v.caseCreateData.caseData.Description'))) {
            helper.gfn_toast('상세 내용을 입력하세요.', 'w');
            return false;
        }
        if(component.get('v.caseCreateData.caseData.Type') === '품질문제 건의'){
            if($A.util.isEmpty(component.get('v.caseCreateData.assetName'))) {
                helper.gfn_toast('기대번호를 입력하세요.', 'w');
                return false;
            }
        }
        if(component.get('v.caseCreateData.assetName').length !== 10 && component.get('v.caseCreateData.assetName').length != 0) {
            helper.gfn_toast('기대번호는 10자리 여야 합니다.', 'w');
            return false;
        }
        return true;
    },

    /**
     * 목록 이동
     * @param component
     */
    fn_doMoveList : function(component){
        component.find('lacComService').doNaviService({
            "type": component.get('v.isCommunity') ? "comm__namedPage" : "standard__namedPage",
            "attributes": {
                "name": "lsMSalesQuestionImprove__c"
            }
        })
    },

    /**
     * 상세 정보 페이지 이동
     * @param component
     * @param Id
     */
    fn_doMoveDetail : function(component, Id){
        component.find('lacComService').doNaviService({
            "type": component.get('v.isCommunity') ? "comm__namedPage" : "standard__namedPage",
            "attributes": {
                "name": "lsMSalesQuestionImproveDetail__c"
            },
            "state": {
                "recordId": Id
            }
        })
    },
    
})