/*
  * @filename      : marketingCampaignSalesActivityController.js
  * @author        : I2MAX
  * @date          : 2021-02-23 오후 1:59
  * @group         :
  * @group-content :
  * @description   :
  * @reference     :
  * @release       : v1.0.0
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                    author       description
  * ===============================================================
    1.0     2021-02-23 오후 1:59         I2MAX          Create
 */
({
      doGetData: function (component, event, helper) {
            helper
                .apex(component, "doGetData", "init", {
                      recordId: component.get("v.recordId"),
            })
                .then(function ({ resData, response }) {
                      component.set("v.activityList", resData.salesActivities);
            })
                .catch(function (error, response) {
                      helper.gfn_ApexErrorHandle(error, response);
            });
      }
});