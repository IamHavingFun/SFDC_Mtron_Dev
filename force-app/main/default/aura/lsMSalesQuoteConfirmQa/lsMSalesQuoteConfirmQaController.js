/****************************************************************************************
 * @filename      : lsMSalesQuoteConfirmQaController.js
 * @projectname   :
 * @author        : i2max_my.Seo
 * @date          : 2020-08-24 오후 1:08
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
 0.1     2020-08-24 오후 1:08    i2max_my.Seo          Create
 ****************************************************************************************/
({
    doSaveQuote : function (component, event, helper) {
        !$A.util.isEmpty(component.get('v.actionForQuote')) && (() => {
            $A.enqueueAction(component.get('v.actionForQuote'));
            helper.gfn_closeQuickActionModal(component);
        })();
    },

    doMoveContract : function (component, event, helper) {
        !$A.util.isEmpty(component.get('v.actionForContract')) && (() => {
            $A.enqueueAction(component.get('v.actionForContract'));
            helper.gfn_closeQuickActionModal(component);
        })();
    },
});