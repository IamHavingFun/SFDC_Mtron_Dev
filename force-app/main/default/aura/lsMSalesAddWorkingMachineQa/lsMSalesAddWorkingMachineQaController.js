/****************************************************************************************
 * @filename      : lsMSalesAddWorkingMachineQaController.js
 * @projectname   :
 * @author        : i2max_my.Seo
 * @date          : 2020-06-24 오후 7:43
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
 0.1     2020-06-24 오후 7:43    i2max_my.Seo          Create
 ****************************************************************************************/
({
    /**
     * Init
     *
     * @param component
     * @param event
     * @param helper
     */
    doInit: function (component, event, helper) {
        helper.apex(
            component, 'doInit', 'init', {'prodId':component.get('v.quoteWp.product.Id')}
        ).then(function ({resData, response}) {
            component.set('v.resData', resData);
            component.set('v.prodFeatureOptions', resData.prodFeatureOptions);
            component.find('pfOption').set('v.value', resData.prodFeatureOptions[0].value);
            component.set('v.oemCompanyOptions', resData.oemCompanyOptionsByFeature[resData.prodFeatureOptions[0].value]);

            !$A.util.isEmpty(resData.wrapperDataList[0]) ?
            component.set('v.recordList', resData.wrapperDataList[0].prodOptionList)
            : helper.gfn_toast('해당 데이터가 없습니다.', 'w');
            component.set('v.wrapperDataList', resData.wrapperDataList);
        }).catch(function (error, response) {
            helper.gfn_ApexErrorHandle(error, response);
        });
    },

    doSelectOptionalProduct: function (component, event, helper) {
        //==============================================================================
        // 선택에 따른 class 변경 로직.
        //==============================================================================
        let items = component.find('optionalProduct');
        items = $A.util.isArray(items) ? items : [items];

        items.forEach(item => {
            if(item.getElement() === event.currentTarget) {
                const optinoProductId = event.currentTarget.dataset.value;
                component.get('v.recordList').some((record) => {
                    if(record.OptionalProduct__c === optinoProductId) {
                        //============================================================================
                        // 선택된 제품시리즈VO 세팅[유의]
                        //============================================================================
                        // component.set('v.quoteWp.qliList[0].Product__c', record.OptionalProduct__c);
                        component.set('v.targetId', record.OptionalProduct__c);
                        return true;
                    }
                });
                $A.util.addClass(event.currentTarget, 'select');
            }
            else {
                $A.util.removeClass(item.getElement(), 'select');
            }
        });
    },


    doChangeProdFeature : function (component, event, helper) {
        helper.fn_changeProdFeature(component, event, helper);
    },

    doChangeOemCompany : function (component, event, helper) {
        helper.fn_oemCompany(component, event, helper);
    },

    doCancel : function (component, event, helper) {
        helper.gfn_closeQuickActionModal(component);
    },

    doSelect : function (component, event, helper) {
        helper.fn_isValid(component, event, helper) && helper.fn_select(component, event, helper, component.get('v.targetId'));
    },
});