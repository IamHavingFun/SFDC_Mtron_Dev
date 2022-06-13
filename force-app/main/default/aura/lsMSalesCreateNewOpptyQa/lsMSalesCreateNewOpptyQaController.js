/****************************************************************************************
 * @filename      : lsMSalesCreateNewOpptyQaController.js
 * @projectname   : LS
 * @author        : Park JW
 * @date          : 2020-08-06 오전 10:20
 * @group         :
 * @group-content :
 * @description   :
 * @tester        :
 * @reference     :
 * @copyright     : Copyright © I2max. All Rights Reserved.
 * @modification Log
 * ===============================================================
 * ver     date                      author          description
 * ===============================================================
 0.1     2020-08-06 오전 10:20           Park JW         Create
 ****************************************************************************************/

({
    //-------------------------------------------------------------
    // 판매기회 생성 init
    //-------------------------------------------------------------
    doInit : function(component, event, helper) {
        helper.lacComService = component.find('lacComService');
        console.log(component.get('v.recordId'));
        helper.apex(
            component, 'doInit', 'init', {
                'recordId': component.get('v.recordId')
            }
        ).then( function ({resData, response}){
            helper.gfn_toast('판매 기회가 생성되었습니다.','s');
            component.find('lacComService').doNaviService({
                "type": "standard__recordPage",
                "attributes": {
                    "recordId": resData.Id,
                    "objectApiName": 'Opportunity',
                    "actionName": "view"
                }
            });
        }
        ).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error, response);
            $A.get("e.force:closeQuickAction").fire()
        });
    },
});