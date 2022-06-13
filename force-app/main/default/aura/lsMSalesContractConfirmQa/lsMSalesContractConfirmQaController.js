/****************************************************************************************
 * @filename      : lsMSalesContractConfirmQaController.js
 * @projectname   :
 * @author        : i2max_my.Seo
 * @date          : 2020-08-06 오전 9:56
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
 0.1     2020-08-06 오전 9:56    i2max_my.Seo          Create
 ****************************************************************************************/
({
    /**
     * 계약 저장 후, Eform QA 띄우는 method.
     *
     * @param component
     * @param event
     * @param helper
     */
    doSaveContract : function (component, event, helper) {
        !$A.util.isEmpty(component.get('v.actionForContract')) && (() => {
            $A.enqueueAction(component.get('v.actionForContract'));
            helper.gfn_closeQuickActionModal(component);
        })();
    },

    /**
     * 계약 변경 없이, Eform QA 띄우는 method.
     *
     * @param component
     * @param event
     * @param helper
     */
    doMoveEFormQa : function (component, event, helper) {
        !$A.util.isEmpty(component.get('v.actionForEForm')) && (() => {
            $A.enqueueAction(component.get('v.actionForEForm'));
            helper.gfn_closeQuickActionModal(component);
        })();
    },
});