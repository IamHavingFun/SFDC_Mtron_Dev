/****************************************************************************************
 * @filename      : orderNewQaController.js
 * @projectname   :
 * @author        : i2max_my.Seo
 * @date          : 2020-04-16 오후 1:36
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
   0.1     2020-04-16 오후 1:36    i2max_my.Seo          Create
 ****************************************************************************************/
({
    /**
     * Init.
     *
     * @param component
     * @param event
     * @param helper
     */
    doInit: function (component, event, helper) {
        helper.lacComService = component.find('lacComService');

        helper.lacComService.doGetSobjectData(['Product2', 'Order__c', 'Asset', 'OrderLineitem__c'], function(resData) {
            component.set('v.labelMap', resData);
        });

        helper.apex(
            component, 'doInit', 'init', {
                'recordId':component.get('v.recordId')
            }
        ).then(function ({resData, response}) {
            component.set('v.wrapperData', resData.wrapperData);
            // component.set('v.orderScheduleDateList', resData.orderScheduleDateList);
            component.set('v.priceChangeCommentOptions', resData.priceChangeCommentOptions);
            component.set('v.oldPriceDecisionDate', resData.wrapperData.order.PriceDecisionDate__c);    // 현재 가격 결정일
            component.set('v.btnLabel', '제품 조회');
            if(resData.wrapperData.isInsert === false) {
                if(resData.wrapperData.order.PurposeOfOrder__c === '실판매기회') {
                    component.set('v.btnLabel', '판매 기회 조회');
                }
            }
            component.set('v.isOldSaveButton', resData.wrapperData.isSaveButton);
            component.set('v.isOldErpSaveButton', resData.wrapperData.isERPSaveButton);
            const isOldSaveButton = component.get('v.isOldSaveButton');
            const isOldErpSaveButton = component.get('v.isOldErpSaveButton');
            helper.fn_setSoldTo(component, resData.wrapperData.order);

            $A.enqueueAction(component.get('c.doChangeBooleanAttr'));
        }).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error, response);
        });
    },

    /**
     * save.
     *
     * @param component
     * @param event
     * @param helper
     */
    doSave : function (component, event, helper) {
        const resultWrapperData = component.get('v.wrapperData');
        if(!resultWrapperData.isPerFarCorp) {
            resultWrapperData.order.SoldTo__c = resultWrapperData.order.SupplyTo__c = resultWrapperData.order.OrderAccount__c;
        }

        helper.fn_ValidationCheckForSave(component, event, helper)
        && helper.apex(
            component, 'doSave', 'save', {
                'wrapperData':resultWrapperData
            }
        ).then($A.getCallback(function ({resData, response}) {
            component.set('v.wrapperData', resData);
            if($A.util.isEmpty(resData.invalidComment)) {
                // helper.gfn_toast('주문이 생성되었습니다.\n' +'영업소 주문 확정 후 주문이 완료됩니다.', 's');
                if(resData.isPerFarCorp === true) {
                    helper.gfn_toast('주문이 저장되었습니다. 내용 확인 후 우측 상단의 [주문제출]을 통해 주문 확정 바랍니다.', 's');
                } else {
                    helper.gfn_toast('주문이 저장되었습니다. 내용 확인 후 우측 상단의 [승인을 위한 제출]을 통해 주문 확정 바랍니다.\n' + '단, 전수배 주문의 경우 전배 요청이 완료된 후 확정하시기 바랍니다.', 's');
                }
                $A.enqueueAction(component.get('c.doNavigateToOrder'));
            }
            else {
                helper.gfn_createComponent(component, 'orderInvalidNotifyQa',
                    {
                        'comment': resData.invalidComment,
                        'orderId': resData.order.Id
                    }, 'slds-modal_small');
            }
        })).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error, response);
        });
    },

    /**
     * save.
     *
     * @param component
     * @param event
     * @param helper
     */
    doSaveNew : function (component, event, helper) {
        const resultWrapperData = component.get('v.wrapperData');
        if(!resultWrapperData.isPerFarCorp) {
            resultWrapperData.order.SoldTo__c = resultWrapperData.order.SupplyTo__c = resultWrapperData.order.OrderAccount__c;
        }

        helper.fn_ValidationCheckForSave(component, event, helper)
        && helper.apex(
            component, 'doSave', 'save', {
                'wrapperData':resultWrapperData
            }
        ).then($A.getCallback(function ({resData, response}) {
            component.set('v.wrapperData', resData);
            if($A.util.isEmpty(resData.invalidComment)) {
                if(resData.isPerFarCorp === true) {
                    helper.gfn_toast('주문이 저장되었습니다. 내용 확인 후 우측 상단의 [주문제출]을 통해 주문 확정 바랍니다.', 's');
                } else {
                    helper.gfn_toast('주문이 저장되었습니다. 내용 확인 후 우측 상단의 [승인을 위한 제출]을 통해 주문 확정 바랍니다.\n' + '단, 전수배 주문의 경우 전배 요청이 완료된 후 확정하시기 바랍니다.', 's');
                }
                $A.enqueueAction(component.get('c.doNavigateToNewOrder'));
            }
            else {
                helper.gfn_createComponent(component, 'orderInvalidNotifyQa',
                    {
                        'comment': resData.invalidComment,
                        'orderId': resData.order.Id
                    }, 'slds-modal_small');
            }
        })).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error, response);
        });
    },


    /**
     * 가격 정정
     *
     * @param component
     * @param event
     * @param helper
     */
    doErpSave : function (component, event, helper) {

        const resultWrapperData = component.get('v.wrapperData');
        if(!resultWrapperData.isPerFarCorp) {
            resultWrapperData.order.SoldTo__c = resultWrapperData.order.SupplyTo__c = resultWrapperData.order.OrderAccount__c;
        }
        if(resultWrapperData.isErpDeliveryChange === true && $A.util.isEmpty(resultWrapperData.order.VSTEL__c) === true) {
            helper.gfn_toast('출하위치를 선택 해주세요.', 'w');
            return false;
        }
        if(resultWrapperData.isErpDeliveryChange === true && $A.util.isEmpty(resultWrapperData.order.VSTEL__c) === false &&
            $A.util.isEmpty(resultWrapperData.order.DeliveryComment__c)) {
            helper.gfn_toast('출하위치 변경에 대한 출하 전달사항을 입력 해주세요.', 'w');
            return false;
        }
        if($A.util.isEmpty(resultWrapperData.order.DeliveryComment__c) === false) {
            const regExp = new RegExp("[&$^#@]");
            if(regExp.test(resultWrapperData.order.DeliveryComment__c)) {
                helper.gfn_toast('출하 전달 사항은 특수문자를 입력할 수 없습니다.', 'w');
                return false;
            }
        }
        if(resultWrapperData.isErpPriceChange === true && $A.util.isEmpty(resultWrapperData.orderLineItemList[0].CorrectionPrice__c)) {
            helper.gfn_toast('정정 가격을 입력 해주세요.[최소 0원]', 'w');
            return false;
        }
        if(resultWrapperData.isErpPriceChange === true && resultWrapperData.orderLineItemList[0].CorrectionPrice__c > 0) {
            if($A.util.isEmpty(resultWrapperData.orderLineItemList[0].PriceChangeComment__c)) {
                helper.gfn_toast('가격 변경 사유를 선택 해주세요.', 'w');
                return false;
            } else {
                const priceChagneComment = resultWrapperData.orderLineItemList[0].PriceChangeComment__c;
                if(priceChagneComment == '기타' && $A.util.isEmpty(resultWrapperData.orderLineItemList[0].OtherChangeComment__c)) {
                    helper.gfn_toast('가격 변경 상세 사유를 입력 해주세요.', 'w');
                    return false;
                }
            }
        }
        helper.fn_ValidationCheckForSave(component, event, helper)
        && helper.apex(
            component, 'doSave', 'erpSave', {
                'wrapperData':resultWrapperData
            }
        ).then($A.getCallback(function ({resData, response}) {
            if(resData.order.ErpS_RESULT__c === '00') {
                helper.gfn_toast('ERP 주문 가격 정정이 정상 처리 되었습니다.', 's');
                $A.enqueueAction(component.get('c.doNavigateToOrder'));
            } else {
                helper.gfn_toast('ERP 주문 가격 정정 오류 :'+resData.order.ErpS_MESSAGE__c , 'e');
            }
        })).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error, response);
        });
    },
    /**
     * 각 주문 목적에 따라 QuickAction cmp 보여줌.
     *
     * @param component
     * @param event
     * @param helper
     */
    doMoveSearchList : function (component, event, helper) {

        if(component.get('v.wrapperData.isPerFarCorp')) {

            const purpose = component.get('v.wrapperData.order.PurposeOfOrder__c');
            //const purpose = component.find('purposeOfOrder').get('v.value');
            switch (purpose) {
                case '재고보충' :
                    helper.gfn_createComponent(component, 'orderProductSearchQa', {
                        'wrapperData': component.getReference('v.wrapperData')
                    }, 'slds-modal_medium');
                    break;
                case '실판매기회' :
                    helper.gfn_createComponent(component, 'orderOpportunitySearchQa', {
                        'wrapperData': component.getReference('v.wrapperData'),
                        'action': component.get('c.doOrderScheduleCheck'),
                    }, 'slds-modal_medium');
                    break;
                default :
                    return;
            }
        }
        else {
            $A.util.isEmpty(component.get('v.wrapperData.order.OrderAccount__c')) || ($A.util.isEmpty(component.get('v.soldToList')[0]))
            ? helper.gfn_toast('주문 고객에 따른 납품처가 존재 해야 합니다.', 'w')
            : helper.gfn_createComponent(component, 'orderProductSearchQa', {
                'wrapperData': component.getReference('v.wrapperData'),
            }, 'slds-modal_medium');
        }
    },

    /**
     * 판매기회 변경후 납품 요청월 체크.
     *
     * @param component
     * @param event
     * @param helper
     */
    doOrderScheduleCheck : function (component, event, helper) {
        const wrapperData = component.get('v.wrapperData');
        console.log('isInsert : ' + wrapperData.isInsert);
        console.log('DeliveryDate__c : ' + wrapperData.order.DeliveryDate__c);
        console.log('currentDate : ' + wrapperData.currentDate);
        console.log('isOldSaveButton : ' + component.get('v.isOldSaveButton'));
        console.log('isERPSaveButton : ' + component.get('v.isOldErpSaveButton'));

        if(wrapperData.isInsert === true) {
            // 등록
            if(wrapperData.order.DeliveryDate__c < wrapperData.currentDate) {
                helper.gfn_toast('선택한 계약의 고객 인도기일이 이미 경과하였습니다.\n실패하지 않은 계약이라면, 고객 인도기일을 먼저 수정하시기 바랍니다.', 'w', 'sticky');
                wrapperData.isSaveButton = false;
                wrapperData.isERPSaveButton = false;
            } else {
                wrapperData.isSaveButton = component.get('v.isOldSaveButton');
                wrapperData.isERPSaveButton = component.get('v.isOldErpSaveButton');
                wrapperData.order.OrderScheduleDate__c = wrapperData.order.DeliveryDate__c;
            }
        } else {
            // 수정
            if(wrapperData.order.DeliveryDate__c < wrapperData.strOrderScheduleDate) {
                helper.gfn_toast('선택한 계약의 고객 인도기일이 본 주문의 납품요청일자를 이미 경과 하였습니다.\n본 주문에 입력해야하는 계약이라면, 납품요청일자 혹은 고객 인도기일을 수정하여 진행하시기 바랍니다.', 'w', 'sticky');
                wrapperData.isSaveButton = false;
                wrapperData.isERPSaveButton = false;
            } else {
                wrapperData.isSaveButton = component.get('v.isOldSaveButton');
                wrapperData.isERPSaveButton = component.get('v.isOldErpSaveButton');
                wrapperData.order.OrderScheduleDate__c = wrapperData.order.DeliveryDate__c;
            }
        }
        component.set('v.wrapperData', wrapperData);
    },

    /**
     * 전수배 목록을 보여 주는 QuickAction cmp 호출.
     *
     * @param component
     * @param event
     * @param helper
     */
    doAssetSearch : function (component, event, helper) {
        const orderLineItemList = component.get('v.wrapperData.orderLineItemList');

        $A.util.isEmpty(orderLineItemList[0].ProductId__c)
        ? helper.gfn_toast('제품을 먼저 선택 해야 합니다.', 'w')
        : helper.gfn_createComponent(component, 'orderAssetSearchQa',
            {
                'productId':orderLineItemList[0].ProductId__c,
                'wrapperData':component.getReference('v.wrapperData')
            }, 'slds-modal_medium');
    },

    /**
     * 공장 재고를 보여 주는 QuickAction cmp 호출.
     *
     * @param component
     * @param event
     * @param helper
     */
    doAssetSearchForDisplay : function (component, event, helper) {
        helper.gfn_createComponent(component, 'orderAssetDisplayQa', {
            'productName':component.get('v.wrapperData.orderLineItemList[0].ProductId__r.Name')
        }, 'slds-modal_medium');
    },

    /**
     * 버튼 label 값 변경.
     *
     * @param component
     * @param event
     * @param helper
     */
    doChangeBtnLabel : function (component, event, helper) {
        helper.fn_btnLabelChange(component, event, helper);
    },

    /**
     * 주문 고객 선택에 따른 해당 주문 고객의 정보와 납품처의 Data 찾아 오는 method.
     *
     * @param component
     * @param event
     * @param helper
     */
    doGetSoldTo : function (component, event, helper) {
        helper.fn_getSoldTo(component, event, helper);
    },

    /**
     * 상황에 따라 주문 Object의 list 이동 또는 팝업창만 닫음.
     *
     * @param component
     * @param event
     * @param helper
     */
    doCancel : function (component, event, helper) {
        component.get('v.wrapperData.isInsert')
        ? helper.lacComService.doNaviService({
            "type": "standard__objectPage",
            "attributes": {
                "objectApiName": 'Order__c',
                "actionName": "home"
            }
        })
        : helper.gfn_closeQuickActionModal(component) && helper.gfn_closeQuickAction(component);
    },

    doNavigateToOrder : function (component, event, helper) {
        const isInsert = component.get('v.wrapperData.isInsert');
        if(isInsert) {
            helper.lacComService.doNaviService({
                "type": "standard__recordPage",
                "attributes": {
                    "recordId": component.get('v.wrapperData.order.Id'),
                    "objectApiName": "Order__c",
                    "actionName": "view"
                }
            });
        } else {
            helper.gfn_refresh(component);
            helper.gfn_closeQuickActionModal(component) && helper.gfn_closeQuickAction(component);
        }
    },

    doNavigateToNewOrder : function (component, event, helper) {
        const resultWrapperData = component.get('v.wrapperData');
        const isInsert = component.get('v.wrapperData.isInsert');
        if(isInsert) {
            helper.apex(
                component, 'doNewData', 'newData', {
                    'wrapperData':resultWrapperData
                }
            ).then($A.getCallback(function ({resData, response}) {
                resData.order.OrderScheduleDate__c = resData.strOrderScheduleDate;
                component.set('v.wrapperData', resData);
            })).catch(function ({error, response}) {
                helper.gfn_ApexErrorHandle(error, response);
            });

        }
    },

    doPriceChange : function (component, event, helper) {
        let CorrectionPrice = event.getSource().get('v.value');
        let BaseSellingPrice = component.find('BaseSellingPrice').get('v.value');
        let OldSellingPrice = component.find('SellingPrice').get('v.label');

        if($A.util.isEmpty(CorrectionPrice)) CorrectionPrice = 0;
        if(parseFloat(CorrectionPrice) >= parseFloat(BaseSellingPrice)) {
            helper.gfn_toast('기준 가격보다 낮은 금액을 입력 해주세요');
            component.find('CorrectionPrice').set('v.value', 0);
            component.find('SellingPrice').set('v.value', OldSellingPrice);
            return;
        }
        if((parseFloat(CorrectionPrice)*-1) >= BaseSellingPrice) {
            helper.gfn_toast('기준 가격보다 높은 금액은 입력할 수 없습니다.');
            component.find('CorrectionPrice').set('v.value', 0);
            component.find('SellingPrice').set('v.value', OldSellingPrice);
            return;
        }
        component.find('SellingPrice').set('v.value', (parseFloat(BaseSellingPrice)+parseFloat(CorrectionPrice)));
        event.preventDefault();
    },
    /**
     * 가격 결정일 수정.
     * @param component
     * @param event
     * @param helper
     */
    doPriceDecisionDateChange : function (component, event, helper) {
        const oldPriceDecisionDate = component.get('v.oldPriceDecisionDate');
        const resultWrapperData = component.get('v.wrapperData');
        console.log(oldPriceDecisionDate);
        helper.apex(
            component, 'doPriceDecisionDateChange', 'getPriceDecisionDateChange', {
                'wrapperData':resultWrapperData
            }
        ).then($A.getCallback(function ({resData, response}) {
            component.set('v.wrapperData', resData);
        })).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error, response);
            component.set('v.wrapperData.order.PriceDecisionDate__c', oldPriceDecisionDate);
        });

    },
    /**
     * 가격 결정일 변경.
     * @param component
     * @param event
     * @param helper
     */
    doOrderScheduleDateChange : function (component, event, helper) {
        const oldPriceDecisionDate = component.get('v.oldPriceDecisionDate');
        const wrapperData = component.get('v.wrapperData');
        if(wrapperData.order.OrderScheduleDate__c <= wrapperData.currentDate) {
            helper.gfn_toast('납품요청일자는 오늘 이후의 날짜만 선택 가능합니다.');
            wrapperData.order.OrderScheduleDate__c = '';
            component.set('v.wrapperData', wrapperData);
        }
    },


});