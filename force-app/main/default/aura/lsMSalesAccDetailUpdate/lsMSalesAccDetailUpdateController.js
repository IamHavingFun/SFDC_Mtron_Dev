/****************************************************************************************
 * @filename      : lsMSalesAccDetailUpdateController.js
 * @projectname   :
 * @author        : i2max_my.Seo
 * @date          : 2020-06-24 오전 7:42
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
 0.1     2020-06-24 오전 7:42    i2max_my.Seo          Create
 ****************************************************************************************/
({
    doAddressSearch : function (component, event, helper) {
        helper.gfn_createComponent(component, 'lsMSalesAddressSearchQa', {
            'mobileStepVO':component.getReference('v.mobileStepVO')
        }, 'slds-modal_medium');
    },

    doPrevPage : function (component) {
        component.find('lacComService').doNaviService({
            "type": component.get('v.isCommunity') ? "comm__namedPage" : "standard__namedPage",
            "attributes": {
                "name": "lsMSalesQuoteRegister__c"
            },
            "state": {
                "type":"m",
                "quoteId":component.get('v.mobileStepVO.bizData.quote.Id')
            }
        });
    },

    doValidCheck : function (component, event, helper) {
        const mobileStepVO  = component.get('v.mobileStepVO');
        const isCorporationAccount = (mobileStepVO.bizData.quote.CustomerName__r.RecordType.DeveloperName === 'CorporationAccount');
        let date;


        if(!isCorporationAccount && ($A.util.isEmpty(mobileStepVO.dateData.tempYear) || $A.util.isEmpty(mobileStepVO.dateData.tempMonth) || $A.util.isEmpty(mobileStepVO.dateData.tempDay))) {
            helper.gfn_toast('생년월일을 입력해 주세요.', 'w');
            return;
        }

        // Address Valid Check.
        if($A.util.isEmpty(mobileStepVO.bizData.quote.CustomerName__r.BillingPostalCode)) {
            helper.gfn_toast('주소를 입력해 주세요.', 'w');
            return;
        }

        date = mobileStepVO.dateData.tempYear + '-' + mobileStepVO.dateData.tempMonth + '-' + mobileStepVO.dateData.tempDay;

        if(!isCorporationAccount) {
            helper.apex(
                component, 'fn_checkValid', 'checkDate', {customerDate:date}
            ).then(({resData, response}) => {
                !resData && helper.gfn_toast('날짜 선택이 잘못되었습니다. 다시 선택해주세요', 'w');
                if(resData) {
                    $A.enqueueAction(component.get('c.doNextPage'));
                }
            }).catch(({error, response}) => {
                helper.gfn_ApexErrorHandle(error, response);
            });
        } else {
            $A.enqueueAction(component.get('c.doNextPage'));
        }
    },

    doNextPage : function (component, event, helper) {
        $A.enqueueAction(component.get('c.doNext'));
        // helper.fn_checkValid(component, event, helper) && $A.enqueueAction(component.get('c.doNext'));
    },
});