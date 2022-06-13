/****************************************************************************************
 * @filename      : noticeBoardViewAddController.js
 * @projectname   :
 * @author        : i2max_my.Seo
 * @date          : 2020-09-09 오후 1:28
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
 0.1     2020-09-09 오후 1:28    i2max_my.Seo          Create
 ****************************************************************************************/
({
    /**
     * Init
     *
     * @param component
     * @param event
     * @param helper
     */
    doInit: function (component, event, helper) {
        helper.apex(
            component, 'doInit', 'init', {recordId:component.get('v.recordId')}, false, true
        ).then(function ({resData, response}) {
            !!resData && helper.gfn_refresh();
        }).catch(function (error, response) {
            helper.gfn_ApexErrorHandle(error, response);
        });
    },
});