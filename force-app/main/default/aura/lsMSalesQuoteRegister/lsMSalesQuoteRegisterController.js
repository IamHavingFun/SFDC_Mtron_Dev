/****************************************************************************************
 * @filename      : lsMSalesQuoteRegisterController.js
 * @projectname   :
 * @author        : i2max_my.Seo
 * @date          : 2020-06-19 오후 3:23
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
 0.1     2020-06-19 오후 3:23    i2max_my.Seo          Create
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
        //==============================================================================
        // URL 관련 Param 값 체크 및 세팅.
        //==============================================================================
        const pageReference = helper.fn_getUrlParams();
        !$A.util.isEmpty(pageReference.type) && component.set('v.type', pageReference.type);

        helper.lacComService = component.find('lacComService');

        helper.apex(
            component, 'doInit', 'init', {
                'type':component.get('v.type'),
                'opptyId':pageReference.opptyId,
                'quoteId':pageReference.quoteId
            }
        ).then(function ({resData, response}) {
            component.set('v.quoteWp', resData.quoteWp);
            component.set('v.unchangedData', resData.unchangedData);
            helper.fn_calculate(component, component.get('v.isInit'), helper);
        }).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error, response);
        });
    },

    /**
     * 견적 품목 추가.
     *
     * @param component
     * @param event
     * @param helper
     */
    doAddMainItem : function (component, event, helper) {
        if(!$A.util.isEmpty(component.get('v.quoteWp.qliList'))) {
            helper.gfn_toast('기존 본체 제품을 삭제해 주세요.', 'w');
            return;
        }

        helper.fn_setCustomerName(component, event, helper);

        if($A.util.isEmpty(component.get('v.quoteWp.quote.CustomerName__c'))) {
            helper.gfn_toast('매수자가 선택 되어야 합니다.', 'w');
            return;
        }

        helper.gfn_createComponent(component, 'lsMSalesQuoteItemAddQa', {
            'quoteWp':component.getReference('v.quoteWp')
        }, 'slds-modal_medium');
    },

    doRegisterContract : function (component, event, helper) {
        const quoteId = component.get('v.quoteWp.quote.Id');
        const quoteWp = component.get('v.quoteWp');

        if($A.util.isEmpty(quoteId)) {
            helper.fn_checkValid(component, event, helper)
            && helper.apex(
                component, 'doRegisterContract', 'save', {
                    'oppty':quoteWp.oppty,
                    'quote':quoteWp.quote,
                    'qliList':quoteWp.qliList,
                    'qoiList':quoteWp.qoiList,
                    'deleteIds':component.get('v.deleteIds')
                }
            ).then(function ({resData, response}) {
                helper.gfn_toast('저장 되었습니다.', 's');
                helper.fn_navigateToContract(component, event, helper, resData);
            }).catch(function ({error, response}) {
                helper.gfn_ApexErrorHandle(error, response);
            });
        }
        else {
            if(quoteWp.amtWrapper.totalPrice < quoteWp.quote.LastQuoteAmt__c) {
                helper.gfn_toast('최종견적가가 합계 금액보다 클 수 없습니다.', 'e');
                return;
            }

            helper.fn_checkChangedData(component) ?
            helper.gfn_createComponent(component, 'lsMSalesQuoteConfirmQa', {
                'actionForQuote':component.get('c.doSaveForQa'),
                'actionForContract':component.get('c.doNaviToContract')
            }, 'slds-modal_medium') :
            helper.fn_navigateToContract(component, event, helper, quoteId);
        }

    },

    /**
     * 작업기 추가 QuickAction.
     *
     * @param component
     * @param event
     * @param helper
     */
    doAddWorkingMachine : function (component, event, helper) {
        helper.fn_setCustomerName(component, event, helper);

        helper.fn_checkValid(component, event, helper) &&
        helper.gfn_createComponent(component, 'lsMSalesAddGeneralMachineQa', {
        //helper.gfn_createComponent(component, 'lsMSalesAddWorkingMachineQa', {
            'quoteWp':component.getReference('v.quoteWp')
        }, 'slds-modal_medium');
        
    },

    doAddOtherWorkingMachine : function (component, event, helper) {
        // Validation Check
        const quoteWp = component.get('v.quoteWp');

        if($A.util.isEmpty(quoteWp.qliList[0])) {
            helper.gfn_toast('본체가 먼저 선택 되어야 합니다.', 'w');
            return;
        }

        helper.gfn_createComponent(component, 'lsMSalesAddOtherWorkingMachineQa', {
            'quoteWp':component.getReference('v.quoteWp')
        }, 'slds-modal_medium');
    },

    doCalculate : function (component, event, helper) {
        helper.fn_calculate(component, false, helper);
    },

    /**
     * 견적서 저장.
     *
     * @param component
     * @param event
     * @param helper
     */
    doSave : function (component, event, helper) {
        const quoteWp = component.get('v.quoteWp');

        helper.fn_checkValid(component, event, helper)
        && helper.apex(
            component, 'doSave', 'save', {
                'oppty':quoteWp.oppty,
                'quote':quoteWp.quote,
                'qliList':quoteWp.qliList,
                'qoiList':quoteWp.qoiList,
                'deleteIds':component.get('v.deleteIds')
            }
        ).then(function ({resData, response}) {
            helper.gfn_toast('저장 되었습니다.', 's');
            helper.fn_navigateToList(component, event, helper);
        }).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error, response);
        });
    },

    doSaveForQa : function (component, event, helper) {
        const quoteWp = component.get('v.quoteWp');

        helper.fn_checkValid(component, event, helper)
        && helper.apex(
            component, 'doSave', 'save', {
                'oppty':quoteWp.oppty,
                'quote':quoteWp.quote,
                'qliList':quoteWp.qliList,
                'qoiList':quoteWp.qoiList,
                'deleteIds':component.get('v.deleteIds')
            }
        ).then($A.getCallback(function ({resData, response}) {
            helper.gfn_toast('저장 되었습니다.', 's');
            helper.fn_navigateToContract(component, event, helper, resData);
        })).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error, response);
        });
    },

    /**
     * 고객 조회
     * @param component
     * @param event
     * @param helper
     */
    doSearchCustomer: function (component, event, helper) {
        helper.gfn_createComponent(
            component,
            'lsMSalesCustomerConsultSearchCustomerQa',
            {
                'customer': component.getReference('v.quoteWp.quote.CustomerName__r'),
                'phoneNumber': null
            },
            'slds-modal_medium'
        );
    },

    doModify : function (component, event, helper) {
        const index         = event.getSource().get('v.value');

        helper.gfn_createComponent(component, 'lsMSalesQuoteItemModifyQa', {
            'quoteWp':component.getReference('v.quoteWp'),
            'qli':component.getReference('v.quoteWp.qliList[' + index + ']'),
            'index':index
        }, 'slds-modal_medium');
    },

    doModifyForOtherWorkingMachine : function (component, event, helper) {
        const record = event.getSource().get('v.value');

        helper.gfn_createComponent(component, 'lsMSalesAddOtherWorkingMachineQa', {
            'quoteWp':component.getReference('v.quoteWp'),
            'qliWrapper':record
        }, 'slds-modal_medium');
    },

    doDelete : function (component, event, helper) {
        const targetEvent   = event.getSource();
        const quoteWp       = targetEvent.get('v.value');
        const index         = targetEvent.get('v.name');
        let deleteIds       = component.get('v.deleteIds');

        if(!quoteWp.qliWpList[index].isOtherWorkingMachine) {
            if (quoteWp.qliWpList[index].prod.Type__c === '본체') {
                const qliWpLength = quoteWp.qliWpList.length;
                const qoiListLength = quoteWp.qliWpList.length;
                quoteWp.product = null;

                // QuoteLineItem
                quoteWp.qliList.forEach((qli) => {
                    deleteIds.push(qli.Id);
                });

                // QuoteOtherItem
                quoteWp.qoiList.forEach((qoi) => {
                    deleteIds.push(qoi.Id);
                });

                quoteWp.qliList.splice(index, qliWpLength);
                quoteWp.qoiList.splice(index, qoiListLength);
                quoteWp.qliWpList.splice(index, qliWpLength);
            } else {
                quoteWp.qliList.forEach((qli, idx) => {
                    (idx === index) && deleteIds.push(qli.Id);
                });

                quoteWp.qliList.splice(index, 1);
                quoteWp.qliWpList.splice(index, 1);
            }
        } else {
            const record = targetEvent.get('v.title');

            quoteWp.qoiList.forEach((qoi, idx) => {
                if((qoi.ProductName__c === record.qliName && qoi.NetPrice__c === record.netPrice)) {
                    deleteIds.push(qoi.Id);
                    quoteWp.qoiList.splice(idx, 1);
                }
            });

            quoteWp.qliWpList.splice(index, 1);
        }

        helper.apex(
            component, 'doDelete', 'getQliDataForDelete', {
                'quoteWrapper':quoteWp
            }
        ).then(function ({resData, response}) {
            component.set('v.quoteWp', resData);
            component.set('v.deleteIds', deleteIds);
            helper.fn_initAmt(component);
        }).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error, response);
        });
    },

    /**
     * 견적/계약 List 화면으로 이동.
     *
     * @param component
     * @param event
     * @param helper
     */
    doPrev : function (component, event, helper) {
        helper.lacComService.doNaviService({
            "type": component.get('v.isCommunity') ? "comm__namedPage" : "standard__namedPage",
            "attributes": {
                "name": "lsMSalesQuoteContractList__c"
            }
        });
    },

    doNaviToContract : function (component, event, helper) {
        helper.lacComService.doNaviService({
            "type": component.get('v.isCommunity') ? "comm__namedPage" : "standard__namedPage",
            "attributes": {
                "name": "lsMSalesContract__c"
            },
            "state": {
                "recordId": component.get('v.quoteWp.quote.Id')
            }
        });
    },

    doCheckValidLastQuoteAmt : function (component, event, helper) {
        const cmp = event.getSource();
        const amtValue = cmp.get('v.value');
        console.log('amtValue = ['+amtValue+']');
        if(amtValue === 0 || amtValue === '0') {
            cmp.set('v.value', '');
        } else {
            if($A.util.isEmpty(amtValue)) {
                cmp.set('v.value', '0');
            }
        }
        (component.get('v.quoteWp.quote.LastQuoteAmt__c') <= 0) && helper.gfn_toast('최종견적가를 입력해 주세요.', 'w');
    },
});