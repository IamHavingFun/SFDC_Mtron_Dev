/****************************************************************************************
 * @filename      : opptyNewQaController.js
 * @projectname   :
 * @author        : i2max_my.Seo
 * @date          : 2020-04-14 오전 10:15
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
   0.1     2020-04-14 오전 10:15    i2max_my.Seo          Create
 ****************************************************************************************/
({
    /**
     * save (single record)
     *
     * @param component
     * @param event
     * @param helper
     */
    doSave : function (component, event, helper) {
        const oppty = component.get('v.oppty');

         /*
         * lookup field 선택 후, 취소 했을 시 value에 바인딩 해 둔 값으로 저장이 안 되므로
         * aura:id로 찾아와 값을 할당.
         * */
        oppty.AccountId = component.find('accountId').get('v.value');
        oppty.Promotion__c = component.find('promotion').get('v.value');

        helper.apex(
            component, 'doSave', 'save', {
                'oppty':oppty
            }
        ).then(function ({resData, response}) {
            helper.gfn_toast('정상적으로 저장되었습니다.', 's');

            component.find('lacComService').doNaviService({
                "type": "standard__recordPage",
                "attributes": {
                    "recordId": resData,
                    "objectApiName": "Opportunity",
                    "actionName": "view"
                }
            });
        }).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error);
        });
    },

    /**
     * Opportunity Home으로 이동
     *
     * @param component
     * @param event
     * @param helper
     */
    doNaviObjHome : function (component, event, helper) {
        component.find('lacComService').doNaviService({
            "type": "standard__objectPage",
            "attributes": {
                "objectApiName": 'Opportunity',
                "actionName": "home"
            }
        });
    },
});