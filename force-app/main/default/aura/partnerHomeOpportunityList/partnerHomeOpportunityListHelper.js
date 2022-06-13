/**
 * Created by ms on 2020-05-13.
 */

({
    //============================================================================
    // 기회 조회 : 최신 상담 내역 조회
    //============================================================================
    fn_getOpportunityList : function (component, event, helper) {
        helper.apex(
            component, 'fn_getNoticeBoardList', 'getOpportunityList',{}
        ).then(function ({resData, response}) {
            component.set('v.opptyList1', resData.list1);
            component.set('v.opptyList2', resData.list2);
        }).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error, response);
        });
    },
});