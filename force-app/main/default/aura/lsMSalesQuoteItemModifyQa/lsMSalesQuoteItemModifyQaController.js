/****************************************************************************************
 * @filename      : lsMSalesQuoteItemModifyQaController.js
 * @projectname   :
 * @author        : i2max_my.Seo
 * @date          : 2020-07-06 오전 9:34
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
 0.1     2020-07-06 오전 9:34    i2max_my.Seo          Create
 ****************************************************************************************/
({
    doInit : function (component, event, helper) {
        const qli = component.get('v.qli');
        component.set('v.initUnitPrice', qli.UnitPrice__c);
        component.set('v.initNetPrice', qli.NetPrice__c);

        if($A.util.isEmpty(qli.AdditionalDisc__c)) {
            qli.AdditionalDisc__c = 0
            component.set('v.qli', qli);
        }

        component.set('v.initDiscount', qli.AdditionalDisc__c)
    },

    doChange : function (component, event, helper) {
        const qli = component.get('v.qli');
        const unitPrice = component.find('unitPrice').get('v.value');

        qli.AdditionalDisc__c   = qli.AdditionalDisc__c || 0;
        qli.UnitPrice__c        = $A.util.isEmpty(unitPrice) ? 0 : unitPrice;
        qli.TotalPrice__c       = qli.NetPrice__c = unitPrice - qli.AdditionalDisc__c;
        // qli.AdditionalDisc__c   = discount;

        component.set('v.qli', qli);
    },

    doMoveRegister : function (component, event, helper) {
        helper.fn_checkValid(component, event, helper) && helper.fn_calculateWithServer(component, event, helper);
    },

    doCancel : function (component, event, helper) {
        component.set('v.qli.UnitPrice__c', component.get('v.initUnitPrice'));
        component.set('v.qli.NetPrice__c', component.get('v.initNetPrice'));
        component.set('v.qli.AdditionalDisc__c', component.get('v.initDiscount'));
        helper.gfn_closeQuickActionModal(component);
    },
});