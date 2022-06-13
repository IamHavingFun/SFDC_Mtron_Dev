/****************************************************************************************
 * @filename      : lsMSalesDesignChangeDetailController.js
 * @projectname   :
 * @author        : i2max_ParkJW
 * @date          : 2020-07-03 오전 9:51
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
 0.1     2020-07-03 오전 9:51           i2max_ParkJW        Create
 ****************************************************************************************/

({
    //-------------------------------------------------------------
    // 초기화
    //-------------------------------------------------------------
    doInit : function(component, event, helper) {
        component.find('lacComService').doGetSobjectData('ProductChange__c', function(resData) {
            component.set('v.labelMap', resData);
        });

        helper.apex(
            component, 'doInit', 'init', {'recordId': component.get('v.recordId')}
        ).then(function ({resData, response}) {
            component.set('v.productChange', resData);
        }).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error, response);
        });
    },

    doBack : function(component,event,helper){
        window.history.back();
    },

});