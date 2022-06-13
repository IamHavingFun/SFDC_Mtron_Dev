/****************************************************************************************
 * @filename      : lacComConfirmQuickActionController.js
 * @projectname   :
 * @author        : i2max_my.Seo
 * @date          : 2020-04-14 오전 11:09
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
   0.1     2020-04-14 오전 11:09        i2max_my.Seo          Create
 ****************************************************************************************/
({
    doAction: function (component, event, helper) {
        const action = component.get('v.action');
        !$A.util.isEmpty(action) && $A.enqueueAction(action);
        helper.gfn_closeQuickActionModal(component);
    },

    doCancel : function(component, event, helper) {
        helper.gfn_closeQuickActionModal(component);
    }
});