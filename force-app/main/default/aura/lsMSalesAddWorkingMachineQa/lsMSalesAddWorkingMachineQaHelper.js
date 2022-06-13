/****************************************************************************************
 * @filename      : lsMSalesAddWorkingMachineQaHelper.js
 * @projectname   :
 * @author        : i2max_my.Seo
 * @date          : 2020-06-25 오전 9:53
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
 0.1     2020-06-25 오전 9:53    i2max_my.Seo          Create
 ****************************************************************************************/
({
    fn_changeProdFeature : function (component, event, helper) {
        const prodFeatureName = event.getSource().get('v.value');
        component.set('v.oemCompanyOptions', component.get('v.resData').oemCompanyOptionsByFeature[prodFeatureName]);

        component.get('v.wrapperDataList').forEach((data) => {
            (data.prodFeature.Name === prodFeatureName) && component.set('v.recordList', data.prodOptionList);
        });
    },

    fn_oemCompany : function (component, event, helper) {
        const prodFeatureName = component.find('pfOption').get('v.value');
        const oemCompanyName = event.getSource().get('v.value');
        let resultList = [];

        component.get('v.wrapperDataList').forEach((data) => {
            if(data.prodFeature.Name === prodFeatureName) {
                resultList = data.prodOptionList.filter((po) => {
                    return po.OptionalProduct__r.OEMCompany__c === oemCompanyName;
                })
            }
        });

        component.set('v.recordList', resultList);
    },

    fn_select : function (component, event, helper, id) {
        const quoteWp = component.get('v.quoteWp');
/*

        if(quoteWp.qliList.length === 4) {
            helper.gfn_toast('제품을 4개 까지만 선택할 수 있습니다.', 'w');
            return;
        }
*/

        if(!$A.util.isEmpty(id)) {
            helper.apex(
                component, 'fn_select', 'getQliDataForQuote', {
                    'quoteWrapper':quoteWp,
                    'prodId':id
                }
            ).then(function ({resData, response}) {
                helper.fn_initAmt(component, resData);
                helper.gfn_closeQuickActionModal(component);
            }).catch(function ({error, response}) {
                helper.gfn_ApexErrorHandle(error, response);
            });
        }
    },

    fn_initAmt : function (component, quoteWp) {

        quoteWp.quote.LastQuoteAmt__c       = quoteWp.amtWrapper.resultPrice = quoteWp.amtWrapper.totalPrice;
        quoteWp.quote.UsedUndertakingAmt__c = 0;
        quoteWp.amtWrapper.totalDiscount    = quoteWp.amtWrapper.discount;

        component.set('v.quoteWp', quoteWp);
    },

    fn_isValid : function (component, event, helper) {
        if($A.util.isEmpty(component.get('v.targetId'))) {
            helper.gfn_toast('작업기를 선택해 주세요.', 'w');
            return false;
        }

        return true;
    },
});