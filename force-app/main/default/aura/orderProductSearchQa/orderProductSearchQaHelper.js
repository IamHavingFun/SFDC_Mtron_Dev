/****************************************************************************************
 * @filename      : orderProductSearchQaHelper.js
 * @projectname   :
 * @author        : i2max_my.Seo
 * @date          : 2020-04-16 오후 1:20
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
 0.1     2020-04-16 오후 1:20    i2max_my.Seo          Create
 ****************************************************************************************/

({
    fn_initSearch : function(component) {
        component.set('v.reqData.pageSize', '10');

        // 검색조건 초기화
        component.set('v.reqData.productType', '');
        component.set('v.reqData.series', '');
        component.set('v.reqData.name', '');
        component.set('v.reqData.dealerId', '');
        component.set('v.reqData.productId', '');
    },

    fn_select : function (component, event, helper) {
        const resultList = helper.gfn_getInputCheckedList(component.find('mycheck'));

        if(resultList.length === 0) {
            helper.gfn_toast('반드시 제품 한 개를 선택 해야 합니다.', 'w'); return;
        }

        const wrapperData = component.get('v.wrapperData');

        wrapperData.orderLineItemList[0].ProductId__c = resultList[0].Id;
        wrapperData.orderLineItemList[0].ListPrice__c = resultList[0].ListPrice__c;
        wrapperData.orderLineItemList[0].UnitPrice__c = resultList[0].ListPrice__c;
        wrapperData.orderLineItemList[0].ProductId__r = resultList[0];

        // 개인/영농
        if(wrapperData.isPerFarCorp) {
            wrapperData.orderLineItemList[0].UnitPrice__c = resultList[0].DealerListPrice__c;

            helper.apex(
                component, 'fn_select', 'calculatePrice', {
                    'wrapperData':wrapperData
                }
            ).then(function ({resData, response}) {
                component.set('v.wrapperData', resData);
                helper.gfn_closeQuickActionModal(component);
            }).catch(function ({error, response}) {
                helper.gfn_ApexErrorHandle(error, response);
            });
        }
        // 농협/관납
        else {
            if(!resultList[0].GovListPrice__c && !resultList[0].NhListPrice__c) {
                helper.gfn_toast('관납 또는 농협가가 존재 하지 않습니다.', 'w'); return;
            }

            wrapperData.orderLineItemList[0].ProductId__r = resultList[0];
            wrapperData.orderLineItemList[0].UnitPrice__c = resultList[0].DealerListPrice__c;

            helper.apex(
                component, 'fn_select', 'calculatePriceForNhGov', {
                    'wrapperData': wrapperData
                }
            ).then(function ({resData, response}) {
                component.set('v.wrapperData', resData);

                helper.gfn_closeQuickActionModal(component);
            }).catch(function ({error, response}) {
                helper.gfn_ApexErrorHandle(error, response);
            });
        }
    },

    fn_getProductSeries : function (component, event, helper, productType) {
        helper.apex(
            component, 'fn_getProductSeries', 'getProductSeriesList', {
                'productType':productType
            }
        ).then(function ({resData, response}) {
            component.set('v.seriesList', resData);
            component.set('v.reqData.series', '');

            ($A.util.isEmpty(resData) && !$A.util.isEmpty(component.get('v.reqData.productType'))) && helper.gfn_toast('기종에 해당하는 시리즈가 없습니다.', 'w');
        }).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error, response);
        });
    },

    lacComService : null
});