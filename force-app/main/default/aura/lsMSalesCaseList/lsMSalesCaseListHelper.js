/****************************************************************************************
 * @filename      : lsMSalesCaseListHelper.js
 * @projectname   :
 * @author        : i2max_my.Seo
 * @date          : 2020-11-26 오후 4:59
 * @group         :
 * @group-content :
 * @description   :
 * @tester        :
 * @reference     :
 * @copyright     : Copyright © I2max. All Rights Reserved.
 * @modification Log
 * ===============================================================
 * ver     date                    author              description
 * ===============================================================
 0.1     2020-11-26 오후 4:59    i2max_my.Seo          Create
 ****************************************************************************************/
({
    // reqData 초기화.
    fn_initSearch : function(component) {
        component.set('v.pageSize', '5');
        // 검색조건 초기화
        component.set('v.reqData.searchStatus', 'All');
    },

    lacComService : null
});