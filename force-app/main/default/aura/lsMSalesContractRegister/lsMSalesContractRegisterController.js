/****************************************************************************************
 * @filename      : lsMSalesContractRegisterController.js
 * @projectname   :
 * @author        : i2max_my.Seo
 * @date          : 2020-06-24 오전 7:28
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
 0.1     2020-06-24 오전 7:28    i2max_my.Seo          Create
 ****************************************************************************************/
({
    /**
     * init.
     *
     * @param component
     * @param event
     * @param helper
     */
    doInit : function (component, event, helper) {
        const contractId = component.get('v.recordId');
        const params = helper.fn_getUrlParams();

        !$A.util.isEmpty(contractId) && component.set('v.isModify', params.isModify);
        component.set('v.isWait', params.isWait);
        !$A.util.isEmpty(component.get('v.mobileStepVO.bizData.contract')) && helper.fn_calculateTotalPrice(component);

        !$A.util.isEmpty(contractId)
        && helper.apex(
            component, 'doInit', 'init', {
                'contractId':contractId
            }
        ).then(function ({resData, response}) {
            component.set('v.mobileStepVO', resData);
            component.set('v.isStep', false);
            helper.fn_calculateTotalPrice(component);
            // helper.contractOrgData = JSON.stringify(resData.bizData.contract);
        }).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error, response);
        });

    },

    /**
     * 전자 계약서 저장 method.
     *
     * @param component
     * @param event
     * @param helper
     */
    doRegisterEFormContract : function (component, event, helper) {
        const contractId = component.get('v.mobileStepVO.bizData.contract.Id');

        if($A.util.isEmpty(contractId)) {
            helper.gfn_toast('계약 Id가 없습니다.', 'w');
            return;
        }

        if(!helper.fn_checkPriceValid(component, event, helper)) {
            return;
        }

        helper.fn_checkChangedData(component) ?
        helper.gfn_createComponent(component, 'lsMSalesContractConfirmQa', {
            'actionForContract':component.get('c.doSaveForQa'),
            'actionForEForm':component.get('c.doCreateEFormQa')
        }, 'slds-modal_medium') :
        $A.enqueueAction(component.get('c.doCreateEFormQa'));
    },

    /**
     * Eform QA 띄우는 method.
     *
     * @param component
     * @param event
     * @param helper
     */
    doCreateEFormQa : function (component, event, helper) {
        helper.gfn_createComponent(component, 'lsMSalesEFormQa', {
            'recordId':component.get('v.mobileStepVO.bizData.contract.Id'),
            'action':component.getReference('c.doPrevPage')
        }, 'slds-modal_medium', null, false);
    },

    /**
     * EformView QA 띄우는 method.
     *
     * @param component
     * @param event
     * @param helper
     */
    doCreateEFormViewQa : function (component, event, helper) {
        helper.gfn_createComponent(component, 'lsMSalesEFormViewQa', {
            'recordId':component.get('v.mobileStepVO.bizData.contract.Id')
        }, 'slds-modal_medium');
    },

    /**
     * 각 금액 타입에 따른 모달 생성.
     *
     * @param component
     * @param event
     * @param helper
     */
    doCreateAmtQa : function (component, event, helper) {
        const amtType = event.currentTarget.dataset.amttype;

        if(!component.get('v.isModify') && !component.get('v.isStep')) {
            helper.gfn_toast('수정할 수 없는 화면입니다.', 'w');
            return;
        }

        helper.gfn_createComponent(component, 'lsMSalesContractAmtQa',
            {
                'mobileStepVO':component.getReference('v.mobileStepVO'),
                'amtType':amtType,
                'totalPrice':component.get('v.mobileStepVO.bizData.quote.LastQuoteAmt__c'),
                'totalViewPrice':component.getReference('v.totalViewPrice')
            },
            'slds-modal_medium', null, false);
    },

    /**
     * 저장 또는 수정 method.
     *
     * @param component
     * @param event
     * @param helper
     */
    doSave : function (component, event, helper) {
        const mobileStepVO = component.get('v.mobileStepVO');
        const isCorporationAccount = mobileStepVO.bizData.isCorporationAccount;
        let tempDate;
        let tempCustomerDate    = mobileStepVO.dateData.tempCustomerYear + '-' + mobileStepVO.dateData.tempCustomerMonth + '-' + mobileStepVO.dateData.tempCustomerDay;

        if(component.get('v.isStep')) {
            // 인도 기일 valid Check.
            if( $A.util.isEmpty(mobileStepVO.dateData.tempCustomerYear)  ||
                $A.util.isEmpty(mobileStepVO.dateData.tempCustomerMonth) ||
                $A.util.isEmpty(mobileStepVO.dateData.tempCustomerDay)
            ) {
                helper.gfn_toast('인도 기일을 입력해 주세요.', 'w');
                return;
            }

            // Contract Setting.
            mobileStepVO.bizData.contract.Quote__c          = mobileStepVO.bizData.quote.Id;
            mobileStepVO.bizData.contract.Opportunity__c    = mobileStepVO.bizData.quote.Opportunity__c;
            mobileStepVO.bizData.contract.Customer__c       = mobileStepVO.bizData.quote.CustomerName__c;

            console.log('💥💥💥💥💥💥💥 isCorporationAccount : ', isCorporationAccount);
            tempDate = isCorporationAccount ? null : mobileStepVO.dateData.tempYear + '-' + mobileStepVO.dateData.tempMonth + '-' + mobileStepVO.dateData.tempDay;

            mobileStepVO.bizData.quote.Opportunity__r.StageName = '계약';
            if(!$A.util.isEmpty(mobileStepVO.bizData.tempDetailAddress)) mobileStepVO.bizData.quote.CustomerName__r.BillingStreet += ' ' + mobileStepVO.bizData.tempDetailAddress;
        }

        if((mobileStepVO.bizData.contract.UsedUndertakingAmt__c !== 0) && ($A.util.isEmpty(mobileStepVO.bizData.contract.Company__c) || $A.util.isEmpty(mobileStepVO.bizData.contract.UsedUndertakingModel__c) || $A.util.isEmpty(mobileStepVO.bizData.contract.UsedUndertakingYear__c))) {
            helper.gfn_toast('중고인수의 제조사 또는 연식 또는 모델명을 입력해주세요.', 'w');
            return;
        }

        helper.fn_checkPriceValid(component, event, helper)
        && helper.apex(
            component, 'doSave', 'saveContract', {
                'contract' : mobileStepVO.bizData.contract,
                'quote': mobileStepVO.bizData.quote,
                'qliList': mobileStepVO.bizData.qliList,
                'qoiList': mobileStepVO.bizData.qoiList,
                'tempDate':tempDate,
                'tempCustomerDate':tempCustomerDate
            }
        ).then(function ({resData, response}) {
            helper.gfn_toast(component.get('v.save'), 's');
            $A.enqueueAction(component.get('c.doPrevPage'));
        }).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error, response);
        });
    },

    /**
     * QuickAction 전달 용 계약 Id
     *
     * @param component
     * @param event
     * @param helper
     */
    doSaveForQa : function (component, event, helper) {
        const mobileStepVO = component.get('v.mobileStepVO');
        let tempDate;
        let tempCustomerDate    = mobileStepVO.dateData.tempCustomerYear + '-' + mobileStepVO.dateData.tempCustomerMonth + '-' + mobileStepVO.dateData.tempCustomerDay;

        helper.fn_checkPriceValid(component, event, helper)
        && helper.apex(
            component, 'doSave', 'saveContract', {
                'contract' : mobileStepVO.bizData.contract,
                'quote': mobileStepVO.bizData.quote,
                'qliList': mobileStepVO.bizData.qliList,
                'qoiList': mobileStepVO.bizData.qoiList,
                'tempDate':tempDate,
                'tempCustomerDate':tempCustomerDate
            }
        ).then($A.getCallback(function ({resData, response}) {
            helper.gfn_toast(component.get('v.save'), 's');
            helper.gfn_createComponent(component, 'lsMSalesEFormQa', {
                'recordId':resData,
                'action':component.getReference('c.doPrevPage')
            }, 'slds-modal_medium', null, false);
        })).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error, response);
        });
    },

    /**
     * 견적 계약 리스트로 이동 하는 method.
     *
     * @param component
     */
    doPrevPage : function (component) {
        component.find('lacComService').doNaviService({
            "type": component.get('v.isCommunity') ? "comm__namedPage" : "standard__namedPage",
            "attributes": {
                "name": "lsMSalesQuoteContractList__c"
            },
            "state": {
                "tabName":"Contract"
            }
        });
    },

    /**
     * PDI 상세 조회로 이동 하는 method.
     *
     * @param component
     */
    doNaviToPDI : function (component) {
        component.find('lacComService').doNaviService({
            "type": component.get('v.isCommunity') ? "comm__namedPage" : "standard__namedPage",
            "attributes": {
                "name": "lsMSalesPDIDetail__c"
            },
            "state": {
                "recordId":component.get('v.mobileStepVO.bizData.contract.Id')
            }
        });
    },
});