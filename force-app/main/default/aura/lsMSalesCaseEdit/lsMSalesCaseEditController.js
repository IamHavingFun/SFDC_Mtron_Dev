/****************************************************************************************
 * @filename      : lsMSalesCaseEditController.js
 * @projectname   :
 * @author        : i2max_my.Seo
 * @date          : 2020-11-26 오후 5:03
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
 0.1     2020-11-26 오후 5:03    i2max_my.Seo          Create
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
        console.log('----------');
        helper.apex(component, 'doInit', 'init',
            {'recordId' : pageReference.recordId}
        ).then(function ({resData, response}) {
            console.log('----------2');
            console.log('resData : ', resData);
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
    },

    /**
     * 유형 변경
     * @param component
     * @param event
     * @param helper
     */
    doTypeChange : function (component, event, helper) {
        const eType = event.getSource().get('v.value');

        // 문제 제기 값 초기화.
        component.set('v.caseCreateData.assetName', '');
        component.set('v.caseCreateData.caseData.UsingTime__c', '');
        component.set('v.caseCreateData.caseData.IssueDetails__c', '');
        component.set('v.caseCreateData.caseData.DoneDetails__c', '');

        if(eType === '질의응답') {
            component.set('v.type2List', component.get('v.caseCreateData').type2List1);
        } else if(eType === '지원요청') {
            component.set('v.type2List', component.get('v.caseCreateData').type2List2);
        } else if(eType === '문제제기') {
            component.set('v.type2List', component.get('v.caseCreateData').type2List3);
        }
    }

})