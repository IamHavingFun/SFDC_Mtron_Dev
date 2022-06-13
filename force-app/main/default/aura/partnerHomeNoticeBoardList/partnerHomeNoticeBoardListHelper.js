/**
 * Created by ms on 2020-05-13.
 */

({
    //============================================================================
    // 공지사항 : 공지사항 조회-홈용
    //============================================================================
    fn_getNoticeBoardList : function (component, event, helper) {
        helper.apex(
            component, 'doGetNoticeBoardList', 'getNoticeBoardList',{}
        ).then(function ({resData, response}) {
            component.set('v.recordList', resData);
        }).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error, response);
        });
    },
});