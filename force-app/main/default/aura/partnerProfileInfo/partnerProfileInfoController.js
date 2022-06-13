/****************************************************************************************
 * @filename      : partnerProfileInfo.js
 * @projectname   : LWC_I2MAX
 * @author        : i2max_my.Seo
 * @date          : 2020-03-10 오전 9:33
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
 0.1     2020-03-10 오전 9:33     i2max_my.Seo          Create
 ****************************************************************************************/
({
    //-------------------------------------------------------------
    // 초기화
    //-------------------------------------------------------------
    doInit : function(component, event, helper){
        helper.apex(
            component, 'doInit', 'init', null
        ).then(function ({resData, response}) {
            component.set('v.resData', resData);
        }).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error, response);
        });
    },

});