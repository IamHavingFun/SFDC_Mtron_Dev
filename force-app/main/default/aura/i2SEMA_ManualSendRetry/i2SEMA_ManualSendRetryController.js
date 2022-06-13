/****************************************************************************************
  * @filename      : i2SEMA_ManualSendRetryController.js
  * @projectname   : i2SEMA Core
  * @author        : i2max_shlee 
  * @date          : 2020/04/14 9:48 AM
  * @group         : e.g)tab name
  * @group-content : e.g)view file  
  * @description   : 
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                author              description
  * ===============================================================
    0.1     2020/04/14 9:48 AM     i2max_shlee       Create
****************************************************************************************/
({
    doInit : function(component,event,helper){
        // Base Initialize
//        helper.gfn_baseInitialize(component,['NotificationTemplate__c']);

        let recordId = component.get('v.recordId');
        helper.gfn_log(component,'doInit',recordId);

        helper.apex(
            component,'doInit','initialize' ,{
                'recordId':recordId
        }).then((returnData,response) => {
            const componentResponse = returnData;
//            component.set('v.referenceData',componentResponse.data.referenceData);
            helper.gfn_log(component,'doInit',componentResponse.data);
        }).catch((error,response) => {
            helper.gfn_ApexErrorHandle(error, response);
        });
    },
});