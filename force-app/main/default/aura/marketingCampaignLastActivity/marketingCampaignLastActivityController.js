/****************************************************************************************
 * @filename      : marketingCampaignLastActivityController.js
 * @projectname   :
 * @author        : i2max
 * @date          : 2021-02-24
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
 0.1     2021-02-24 		        i2max               Create
 ****************************************************************************************/


({
	doInit : function(component, event, helper) {
         helper.apex(
            component, 'doInit', 'init', {
                'recordId':component.get('v.recordId')
            }
        ).then(function ({resData, response}){
            component.set('v.campaigns', resData.campaigns);
            component.set('v.totalPrice', resData.totalPrice);
        }).catch(function (error, response) {
            helper.gfn_ApexErrorHandle(error, response);
        });
	}
})