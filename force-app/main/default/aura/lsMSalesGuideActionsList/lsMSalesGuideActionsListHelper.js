({
    //============================================================================
    // Task : Guide Action 조회
    //============================================================================
    fn_GuideActionList : function (component, event, helper) {

        console.log('3===> ' + component.get("v.recordId"));
        helper.apex(
            component, 'doGuideActionList', 'getGuideActionList',
            {
                'targetObject': component.get('v.targetObject')
            }
        ).then(function ({resData, response}) {
            component.set('v.recordList', resData);
        }).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error, response);
        });
    }
});