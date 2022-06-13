({
    /**
     * fn_initSearch 검색조건 초기화
     *
     * @param component
     */
    fn_initSearch : function(component) {
        component.set('v.reqData.pageSize', '10');
        component.set('v.reqData.name', '');
    },
    
    lacComService : null
})