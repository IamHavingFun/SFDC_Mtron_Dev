/****************************************************************************************
 * @filename      : orderERPSendQa.js
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
     * init.
     *
     * @param component
     * @param event
     * @param helper
     */
    doInit: function (component, event, helper) {
        helper.apex(
            component, 'doInit', 'init', {'recordId':component.get('v.recordId')}
        ).then(function ({resData, response}) {
            component.set('v.caseData', resData.caseData);
            component.set('v.isOwnerChangePossible', resData.isOwnerChangePossible);
            component.set('v.ownerQueueOptions', resData.ownerQueueOptions);
        }).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error, response);
        });
    },
    /**
     * 소유자 변경 처리.
     *
     * @param component
     * @param event
     * @param helper
     */
    doSave : function (component, event, helper) {
        const recordId = component.get('v.recordId');
        helper.apex(
            component, 'doSve', 'save', {
                'caseData': component.get('v.caseData')
            }
        ).then(function ({resData, response}) {
            helper.gfn_closeQuickActionModal(component);
            helper.gfn_refresh();
        }).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error);
        });
    },
});