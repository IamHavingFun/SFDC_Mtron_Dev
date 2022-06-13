/****************************************************************************************
 * @filename      : lsMSalesWarrantyClaimHelper.js
 * @projectname   :
 * @author        : SEOKHO LEE
 * @date          : 2020-07-01 오후 1:05
 * @group         :
 * @group-content :
 * @description   :
 * @tester        :
 * @reference     :
 * @copyright     : Copyright © I2max. All Rights Reserved.
 * @modification Log
 * ===============================================================
 * ver     date                     author              description
 * ===============================================================
 0.1     2020-07-01 오후 1:05      SEOKHO LEE          Create
 ****************************************************************************************/
({
    // reqData 초기화.
    fn_initSearch : function(component) {
        component.set('v.reqData.pageSize', '3');
        component.set('v.reqData.searchBox', '');
    },

    lacComService : null
});