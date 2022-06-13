/**
 * @filename      : ZZ_LoadDataTestHelper.js
 * @projectname   :
 * @author        : i2max_ParkJW
 * @date          : 2020-06-09 오전 10:58
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
 0.1     2020-06-09 오전 10:58           i2max_ParkJW        Create
 */

({
    // reqData 초기화.
    fn_initSearch : function(component) {
        component.set('v.reqData.pageSize', '5');

        // 검색조건 초기화
        component.set('v.reqData.productName', '');
    },

    lacComService : null
});