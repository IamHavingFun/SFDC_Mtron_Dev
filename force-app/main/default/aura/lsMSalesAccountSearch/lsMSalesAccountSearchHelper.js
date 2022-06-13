/****************************************************************************************
 * @filename      : lsMSalesQuestionImproveHelper.js
 * @projectname   :
 * @author        : i2max_my.Seo
 * @date          : 2020-06-18 오후 2:37
 * @group         :
 * @group-content :
 * @description   : [모바일] 판매 기회 관리
 * @tester        :
 * @reference     :
 * @copyright     : Copyright © I2max. All Rights Reserved.
 * @modification Log
 * ===============================================================
 * ver     date                     author              description
 * ===============================================================
 0.1     2020-06-18 오후 2:37        i2max_my.Seo          Create
 ****************************************************************************************/
({
    // reqData 초기화.
    fn_initSearch : function(component) {
        component.set('v.pageSize', '5');
        // 검색조건 초기화
        component.set('v.reqData.searchType', 'Opportunity');
        component.set('v.reqData.srchName', '');
        component.set('v.reqData.srchSeries', '');
        component.set('v.reqData.srchHorsePowerStandard', '');
        component.set('v.reqData.srchPurchaseDate', '');
        component.set('v.reqData.srchDate', '');
        
    },

    listChange : function(component){
        component.set('v.reqData.srchName', '');
        component.set('v.reqData.srchSeries', '');
        component.set('v.reqData.srchHorsePowerStandard', '');
        component.set('v.reqData.srchPurchaseDate', '');
        component.set('v.reqData.srchDate', '');
    },
    lacComService : null
})