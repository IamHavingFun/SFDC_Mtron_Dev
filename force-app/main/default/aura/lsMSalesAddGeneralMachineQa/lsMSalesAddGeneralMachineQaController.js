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
            //component.find('pfOption').set('v.value', resData.prodFeatureOptions[0].value);
            //component.set('v.oemCompanyOptions', resData.oemCompanyOptionsByFeature[resData.prodFeatureOptions[0].value]);
/*
            !$A.util.isEmpty(resData.wrapperDataList[0]) ?
                component.set('v.recordList', resData.wrapperDataList[0].prodOptionList)
                : helper.gfn_toast('해당 데이터가 없습니다.', 'w');
            component.set('v.wrapperDataList', resData.wrapperDataList);
*/

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
                    if(record.Id === optinoProductId) {
                        //============================================================================
                        // 선택된 제품시리즈VO 세팅[유의]
                        //============================================================================
                        component.set('v.targetId', record.Id);
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
        const segment = event.getSource().get('v.value');
        component.find('ocOption').set('v.value', '');      // 초기화.
        helper.apex(
            component, 'doChangeProdFeature', 'getOemCompanyOptions', {'segment':segment}
        ).then(function ({resData, response}) {
            component.set('v.oemCompanyOptions', resData);
        }).catch(function (error, response) {
            helper.gfn_ApexErrorHandle(error, response);
        });
        helper.fn_changeProdFeature(component, event, helper);
    },

    doSearch : function (component, event, helper) {
        const segment = component.find('pfOption').get('v.value');
        const company = component.find('ocOption').get('v.value');
        const modelName = component.find('srchText').get('v.value');
        helper.apex(
            component, 'doSearch', 'getProducts', {'segment':segment, 'company':company, 'modelName':modelName}
        ).then(function ({resData, response}) {
            component.set('v.recordList', resData);
        }).catch(function (error, response) {
            helper.gfn_ApexErrorHandle(error, response);
        });
    },

    doChangeOemCompany : function (component, event, helper) {
        helper.fn_oemCompany(component, event, helper);
    },

    doCancel : function (component, event, helper) {
        helper.gfn_closeQuickActionModal(component);
    },

    doSelect : function (component, event, helper) {
        const id = component.get('v.targetId');

        console.log('💥💥💥💥💥💥💥 ' + component.get('v.targetId'));

        if($A.util.isEmpty(id)) {
            helper.gfn_toast('작업기를 선택해 주세요.', 'w');
            return;
        }

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
});