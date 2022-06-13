/****************************************************************************************
 * @filename      : orderAssetDisplayQaHelper.js
 * @projectname   :
 * @author        : i2max_my.Seo
 * @date          : 2020-04-20 오후 2:45
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
 0.1     2020-04-20 오후 2:45    i2max_my.Seo          Create
 ****************************************************************************************/
({
    fn_initSearch : function(component) {
        component.set('v.reqData.pageSize', '10');

        // 검색조건 초기화
        component.set('v.reqData.productType', '');
        component.set('v.reqData.series', '');
        component.set('v.reqData.name', '');
    },
});