({
    /**
     * 최상위 초기화 처리
     * @param component
     * @param event
     * @param helper
     */
    doInit : function(component, event, helper) {
        component.set('v.isCommunity', helper.gfn_isCommunitySite());
    },

    /**
     * Table 관련 리스트 데이터 및 페이징 처리
     * 기존의 searchTerm -> reqData 변경
     * Com_TableFrame에서는 searchTerm 을 그대로 사용
     * @param component
     * @param event
     * @param helper
     */
    util_Move : function(component, event, helper) {
        const message = event.getParam("message");

        //-------------------------------------------------------------
        // 이벤트 메시지 로깅
        //-------------------------------------------------------------
        helper.gfn_log(component, 'util_Move: message : ', message);

        //-------------------------------------------------------------
        // Server Apex의 Method를 search 로 고정
        //-------------------------------------------------------------
        helper.apex(component, 'util_Move', message.apexCallMethodName, {
            // message의 searchTerm 을 reqData key로 사용
            'reqData' : JSON.stringify(message.searchTerm),
            'pageSize' : message.pageSize,
            'pageNumber' : message.pageNumber
        }).then(function ({resData, response}) {
            // resData 전체 세팅
            component.set("v.resData", resData);
            // resData의 recordList만 세팅
            if($A.util.isEmpty(resData.recordList)){
                component.set("v.recordList", resData);
                helper.gfn_callPageFrame(component, resData);
            }
            else {
                component.set("v.recordList", resData.recordList);
                helper.gfn_callPageFrame(component, resData.recordList, resData.totalSize);
            }
        }).catch(function({error, response}){
            helper.gfn_ApexErrorHandle(error, response);
        });
    },

})