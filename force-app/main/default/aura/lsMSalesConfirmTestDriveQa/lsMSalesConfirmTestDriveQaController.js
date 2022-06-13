/****************************************************************************************
 * @filename      : lsMSalesConfirmTestDriveQaController.js
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
 0.1     2020-08-10 오후 03:25           Park JW         Create
 ****************************************************************************************/

({
    //-------------------------------------------------------------
    // 판매기회 생성 init
    //-------------------------------------------------------------
    doInit : function(component, event, helper) {
        helper.lacComService = component.find('lacComService');
        helper.apex(
            component, 'doInit', 'init', {
                'recordId': component.get('v.recordId')
            }
        ).then( function ({resData, response}){
            component.set('v.targetLead', resData);
            if(resData.Status == '시승예약완료') {
                component.set('v.isConfirmDriveDate', true);
            }
        })
    },
    doSave : function(component, event, helper) {
        helper.apex(
            component, 'doSave', 'save', {
                'target': component.get('v.targetLead')
            }
        ).then( function ({resData, response}){
            helper.gfn_toast('시승 예약이 완료되었습니다.','s');
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