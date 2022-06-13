/****************************************************************************************
 * @filename      : lsMSalesQuestionImproveHelper.js
 * @projectname   :
 * @author        : SEOKHO LEE
 * @date          : 2020-06-18 오후 2:37
 * @group         :
 * @group-content :
 * @description   : [모바일] 질문/개선
 * @tester        :
 * @reference     :
 * @copyright     : Copyright © I2max. All Rights Reserved.
 * @modification Log
 * ===============================================================
 * ver     date                     author              description
 * ===============================================================
 0.1     2020-06-18 오후 2:37        SEOKHO LEE          Create
 ****************************************************************************************/
({
    // reqData 초기화.
    fn_initSearch : function(component) {
        component.set('v.pageSize', '5');
        // 검색조건 초기화
        component.set('v.reqData.searchStatus', 'All');
    },
     lacComService : null
})