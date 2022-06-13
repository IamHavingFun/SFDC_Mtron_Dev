/**
 * Created by ms on 2020-05-13.
 */

({
    //============================================================================
    // 설계변경 : 최신건 조회
    //============================================================================
    fn_getList : function (component, event, helper) {
        helper.apex(
            component, 'fn_getList', 'getList',{}
        ).then(function ({resData, response}) {
            component.set('v.recordList', resData);
        }).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error, response);
        });
    },
});