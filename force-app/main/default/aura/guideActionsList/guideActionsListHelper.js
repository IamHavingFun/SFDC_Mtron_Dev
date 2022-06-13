({
    //============================================================================
    // Task : Guide Action 조회
    //============================================================================
    fn_GuideActionList : function (component, event, helper) {
        console.log('1 ===> ' + component.get('v.recordId'));
        console.log('2 ===> ' + component.get("v.targetObject"));
        const recordId = $A.util.isEmpty(component.get('v.recordId')) === true ? '' : component.get('v.recordId');
        helper.apex(
            component, 'doGuideActionList', 'getGuideActionList',
            {
                'recordId': recordId,
                'targetObject': component.get('v.targetObject')
            }
        ).then(function ({resData, response}) {
            component.set('v.recordList', resData);
        }).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error, response);
        });
    }
});