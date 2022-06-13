/****************************************************************************************
 * @filename      : lacComQuickActionController.js
 * @projectname   :
 * @author        : i2max_my.Seo
 * @date          : 2020-03-10 오전 9:55
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
   0.1     2020-03-10 오전 9:55     i2max_my.Seo           Create
 ****************************************************************************************/
({
    /**
     * 취소버튼 클릭
     * @param component
     * @param event
     * @param helper
     */
    doCancel : function(component, event, helper) {
        var action = component.get('v.closeAction');
        !$A.util.isEmpty(action) && $A.enqueueAction(action);
        component.find("overlayLib").notifyClose();
    }
});