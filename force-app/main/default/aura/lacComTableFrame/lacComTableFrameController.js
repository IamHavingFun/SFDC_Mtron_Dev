({
    // ====================================================
    // 초기
    // ====================================================
    doInit : function(component, event, helper) {
        // 처음에 search가 호출되지 않는 경우를 대비
        component.set("v.isLastPage", true);
    },

    // ====================================================
    // 강제적 Reset
    // ====================================================
    doReset : function(component, event, helper) {
        component.set("v.pageNumber", 1);
        component.set("v.pageSize", 20);
        component.set("v.resultSize", 0);
        component.set("v.totalSize", 0);
    },

    // ====================================================
    // 다음 페이지
    // ====================================================
    onNext : function(component, event, helper) {
        // 현재 페이지 번호
        var pageNumber = component.get("v.pageNumber");
        // 페이지 번호 += 1
        component.set("v.pageNumber", pageNumber+1);
        // 검색조건
        var searchTerm = component.get("v.searchTerm");
        // 로그 출력
        helper.gfn_log(component, 'lacComTableFrame.onNext');

        // 숫자 페이징인 경우 추가 처리가 필요
        let isNumPaging = component.get('v.number');

        if(isNumPaging){
        }

        // 이벤트 호출
        helper.fireEvent(component, pageNumber+1, searchTerm);
    },

    // ====================================================
    // 넘어온 데이터를 정제하고 화면에 표시하는 역할
    // ====================================================
    sortData : function(component, event, helper) {
        var params = event.getParam('arguments');

        helper.gfn_log(component, 'lacComTableFrame.sortData' , {
            'params' : params,
        });
        // 레코드 출력
        helper.getRecords(component, params);
    },

    // ====================================================
    // 이전 페이지
    // ====================================================
    onPrev : function(component, event, helper) {
        // 현재 페이지 번호
        var pageNumber = component.get("v.pageNumber");
        // 페이지 번호 -= 1
        component.set("v.pageNumber", pageNumber-1);
        // 검색조건
        var searchTerm = component.get("v.searchTerm");
        // 로그 출력
        helper.gfn_log(component, 'lacComTableFrame.onPrev');
        // 이벤트 호출
        helper.fireEvent(component, pageNumber-1, searchTerm);
    },


    // ===================================================
    // 페이지 번호 선택
    // ===================================================
    onMove : function(component, event, helper) {
        // 선택 된 페이지
        let selected = event.getSource().get('v.value');
        // 페이지 번호 설정
        component.set("v.pageNumber", selected);

        // 마지막 페이지 체크
        let totalSize = component.get('v.totalSize');
        let pageSize = component.get("v.pageSize");
        let pageLength = component.get('v.pageLength');

        if(Math.ceil(totalSize / pageLength) === selected){
            component.set("v.isLastPage", true);
        }else{
            component.set("v.isLastPage", false);
        }

        // 검색 조건
        let searchTerm = component.get("v.searchTerm");
        // 로그 출력
        helper.gfn_log(component, 'lacComTableFrame.onMove');
        // 이벤트 호출
        helper.fireEvent(component, selected, searchTerm);
    }
})