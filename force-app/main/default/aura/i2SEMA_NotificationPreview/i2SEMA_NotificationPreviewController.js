/****************************************************************************************
  * @filename      : i2SEMA_NotificationPreviewController.js
  * @projectname   : i2sema.dev pd
  * @author        : i2max_shlee 
  * @date          : 2020/04/08 1:10 PM
  * @group         : e.g)tab name
  * @group-content : e.g)view file  
  * @description   : 
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                author              description
  * ===============================================================
    0.1     2020/04/08 1:10 PM     i2max_shlee       Create
****************************************************************************************/
({
    doInit : function(component,event,helper){

        helper.gfn_baseInitialize(component,['NotificationTemplate__c'])
            .then((returnData,response) => {

                // Component Initialize
                let recordId = component.get('v.recordId');
                helper.gfn_log(component,'Preview doInit',recordId);
                if(!(recordId == '' || recordId == undefined)) {
                    helper.apex(component
                            ,'doInit'
                            ,'initialize'
                            ,{ recordId : recordId}
                            )
                    .then((returnData,response) => {
                        const data = returnData.data;

                        component.set('v.referenceData',data.referenceData);
                        helper.gfn_log(component,'Preview doInit data',data.referenceData);
                    })
                    .catch((error,response) => {
                        helper.gfn_ApexErrorHandle(error, response);
                    })
                }
            })
            .catch((error,response) => {
                helper.gfn_ApexErrorHandle(error, response);
            });
    },
    moveLink : function(component, event, helper){
        let btnLink = event.currentTarget.getAttribute('data-value');
        helper.gfn_log(component,'doInit','btnLink=  '+btnLink);
        window.open(btnLink,'_blank');
    },
});