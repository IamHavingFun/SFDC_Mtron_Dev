/****************************************************************************************
 * @filename      : guideActionsListController.js
 * @projectname   : LWC_I2MAX
 * @author        : i2max_my.Seo
 * @date          : 2020-03-10 오전 9:33
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
 0.1     2020-03-10 오전 9:33     i2max_my.Seo          Create
 ****************************************************************************************/
({
    //-------------------------------------------------------------
    // 초기화
    //-------------------------------------------------------------
    doInit : function(component, event, helper){
        const recordId = $A.util.isEmpty(component.get('v.recordId')) ? '' : component.get('v.recordId');
        component.set('v.recordId', recordId);

        console.log('1 ===> ' + recordId);
        console.log('2 ===> ' + component.get("v.targetObject"));
        helper.apex(
            component, 'doInit', 'init', null
        ).then(function ({resData, response}) {
            component.set('v.initData', resData);
            helper.fn_GuideActionList(component, event, helper);
        }).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error, response);
        });
    },

    //------------------------------------------------------------------------------
    // 검색
    //------------------------------------------------------------------------------
    doGuideActionList : function (component, event, helper) {
        console.log('===> ' + component.get("v.recordId"));
        helper.fn_GuideActionList(component, event, helper);
    },

    //------------------------------------------------------------------------------
    // task 완료 체크
    //------------------------------------------------------------------------------
    doCheckedComplete : function (component, event, helper) {
        const recordId = event.currentTarget.dataset.recordid;
        console.log('=== recordId : ' + recordId);

        helper.apex(
            component, 'doCheckedComplete', 'saveCompletedById',
            {
                'recordId': recordId,
            }
        ).then(function ({resData, response}) {
            console.log('------------------');
            helper.fn_GuideActionList(component, event, helper);
            console.log('------------------');
        }).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error, response);
        });

    },

    //============================================================================
    // Task Detail 페이지 이동
    //============================================================================
    doNaviDetail : function (component, event, helper) {
        component.find('lacComService').doNaviService({
            "type": "standard__recordPage",
            "attributes": {
                "recordId": event.currentTarget.dataset.recordid,
                "objectApiName": 'Task',
                "actionName": "view"
            }
        });
    }

})