/****************************************************************************************
 * @filename      : contractARController.js
 * @projectname   :
 * @author        : i2max_ss.Jung
 * @date          : 2020-04-08 오후 3:03
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
 0.1     2020-04-08 오후 3:03       i2max_ss.Jung         Create
 ****************************************************************************************/
({
    //-------------------------------------------------------------
    // 초기화
    //-------------------------------------------------------------
    doInit : function(component, event, helper) {

        component.set('v.partnerUrl',helper.gfn_getSiteUrlFromWindowLocation());
        helper.lacComService = component.find('lacComService');

        helper.lacComService.doGetSobjectData('Contract__c', function(resData) {
            component.set('v.labelMap', resData);
        });
        //console.log('@@@@@@@@ labelMap :: ' + JSON.stringify(component.get('v.labelMap')));

        helper.apex(
            component, 'doInit', 'init', {
                'recordId':component.get('v.recordId')
            }
        ).then(function ({resData, response}) {
            component.set('v.contract', resData.contractData);

        }).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error, response);
        });
    },

    doSave: function (component, event, helper) {
        const contract = component.get('v.contract');

        helper.apex(
            component, 'doSave', 'save', {
                'contract':contract
            }
        ).then(function ({resData, response}) {
            helper.gfn_toast('정상적으로 저장되었습니다.', 's');
            //$A.enqueueAction(component.get('c.doCancel'));
        }).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error, response);
        });
    },

});