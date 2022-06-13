({
    /**
     * 초기 거래
     * @param component
     * @param event
     * @param helper
     */
    doInit: function (component, event, helper) {
        const guidedSellingType = component.get('v.mobileStepVO.bizData.guidedSellingType');

        // 전화번호 분리
        helper.fn_splitPersonMobilePhone(component, helper);
        const privacyText = "LS엠트론에서 고객님께 더 나은 구매조건을 제공하기 위해\n위와 같은 개인정보활용에 동의를 구하고 합니다\n개인정보 활용동의는 개인정보보호법 등의 법률에 따라 반드시 필요한 절차이며, LS엠트론에서 판매하는 제품의 판매/상담/서비스/마케팅제공을 위해 최소한의 정보만 수집/이용하게 됩니다.";
        //\n\nLS엠트론 개인정보 처리방침 확인\nhttps://www.lsmtron.co.kr/page/popup/privacy.asp";
        component.set('v.privacyText', privacyText);
        component.set('v.farmingForm', component.get('v.mobileStepVO.bizData.prodSerRecStd.FarmingForm__c'));
        component.set('v.farmingSize', component.get('v.mobileStepVO.bizData.prodSerRecStd.FarmingSize__c'));
        component.set('v.accountRecordTypeId', component.get('v.mobileStepVO.bizData.customerVO.customer.RecordTypeId'));
        (guidedSellingType === 'A') && component.set('v.mobileStepVO.bizData.customerVO.isPersonAccount', true);


        //============================================================================
        // 처음에는 무조건 초기화하였으나, main에서 첫세팅을 하고 데애터를 유지함.
        // 따라서 init 주석처리. controller에서도 주석처리함.
        //============================================================================
        /*
                helper.apex(
                    component, 'doInit', 'getNewCustomerCardData', {}
                ).then(function ({resData, response}) {
                    //============================================================================
                    // 매번 기존 무시하고 신규 레코드 생성 매핑
                    //============================================================================
                    component.set('v.mobileStepVO.bizData.customerVO.customer', resData.newPersonAccount);
                    component.set('v.mobileStepVO.bizData.customerVO.cupi', resData.newCUPI);
                }).catch(function ({error, response}) {
                    helper.gfn_ApexErrorHandle(error, response);
                });`
        */
        helper.apex(
            component, 'doInit', 'getDefaultData', {
                customerType: component.get('v.mobileStepVO.bizData.customerVO.customer.CustomerType__c'),
                farmInfo: component.get('v.mobileStepVO.bizData.prodSerRecStd.FarmingForm__c'),
                guidedSellingType: guidedSellingType
            }
        ).then(({resData}) => {
            component.set('v.closeDateList', resData.closeDateList);
            component.set('v.farmingFormList', resData.farmFormList);
            component.set('v.farmingAreaList', resData.farmAreaList);
            !$A.util.isEmpty(resData.guidedSellingType) && component.set('v.mobileStepVO.infoData.accountRecordTypeList', resData.guidedSellingType);
        }).catch(({error}) => {
            helper.gfn_ApexErrorHandle(error);
        });
    },

    doPrevSelf: function (component, event, helper) {
        // 전화번호를 개인 모바일 필드에 적용
        helper.fn_joinPhoneNumber(component, helper);
        $A.enqueueAction(component.get('c.doPrev'));
    },

    /**
     * 고객 조회
     * @param component
     * @param event
     * @param helper
     */
    doSearchCustomer: function (component, event, helper) {
        let paramObject = {};
        const isPersonAccount = component.get('v.mobileStepVO.bizData.customerVO.isPersonAccount');

        if(isPersonAccount) {
            paramObject = {
                customer: component.getReference('v.mobileStepVO.bizData.customerVO.customer'),
                phoneNumber: component.getReference('v.phoneNumber'),
                accountRecordTypeId: component.getReference('v.mobileStepVO.bizData.customerVO.customer.RecordTypeId'),
                customerName: component.getReference('v.customerName'),
                isPhoneCheck: component.getReference('v.mobileStepVO.bizData.isAuthenticated')
            };
        } else {
            paramObject = {
                customer: component.getReference('v.mobileStepVO.bizData.customerVO.customer'),
                phoneNumber: component.getReference('v.phoneNumber'),
                accountRecordTypeId: component.getReference('v.mobileStepVO.bizData.customerVO.customer.RecordTypeId'),
                customerName: component.getReference('v.customerName'),
                action: component.getReference('c.doGetCustomerDataForGuidedSellingTypeA'),
                contactPhoneNumber: component.getReference('v.contactPhoneNumber'),
                customerContact: component.getReference('v.mobileStepVO.bizData.customerVO.customerContact'),
                isPhoneCheck: component.getReference('v.mobileStepVO.bizData.isAuthenticated')
            };
        }

        if($A.util.isEmpty(component.get('v.mobileStepVO.bizData.customerVO.customer.RecordTypeId'))) {
            helper.gfn_toast('고객타입을 지정해주세요.', 'w');
            return;
        }
        helper.gfn_createComponent(component, 'lsMSalesCustomerConsultSearchCustomerQa', paramObject, 'slds-modal_medium');
    },

    doGetCustomerDataForGuidedSellingTypeA : function (component, event, helper) {
        helper.apex(
            component, 'doGetCustomerDataForGuidedSellingTypeA', 'getCustomerDataForGuidedSellingType', {
                accountId: component.get('v.mobileStepVO.bizData.customerVO.customer.Id')
            }
        ).then(({resData}) => {
            component.set('v.mobileStepVO.infoData.accountCustomerTypeList', resData.customerTypeList);
            component.set('v.farmingFormList', resData.farmFormList);
            component.set('v.farmingAreaList', resData.farmAreaList);
            component.set('v.mobileStepVO.bizData.customerVO.customer', resData.customer);
            component.set('v.farmingForm', resData.customer.FarmingForm__c);
            component.set('v.farmingSize', resData.customer.FarmingArea__c);

            // recordType 추가로 split 대상 필드가 분리됨.
            !$A.util.isEmpty(resData.customer.PersonMobilePhone) ?
            component.set('v.phoneNumber', resData.customer.PersonMobilePhone.split('-')) :
            component.set('v.phoneNumber', resData.customer.Phone.split('-'));

            !$A.util.isEmpty(resData.customer.PersonMobilePhone) ?
            component.set('v.mobileStepVO.bizData.customerVO.isPersonAccount', true) :
            component.set('v.mobileStepVO.bizData.customerVO.isPersonAccount', false);

            /*
            * pop up을 띄우는 parent cmp 관계없이 세팅. -> 때에 따라서는 아무 의미없는 코드
            * 현재는 lsMSalesCustomerConsultCard에서만 사용
            * */
            !$A.util.isEmpty(resData.customer.LastName) ?
            component.set('v.customerName', resData.customer.LastName) :
            component.set('v.customerName', resData.customer.Name);
        }).catch(({error}) => {
            helper.gfn_ApexErrorHandle(error);
        });
    },


    /**
     * 핸드폰 인증 modal pop up
     *
     * @param component
     * @param event
     * @param helper
     */
    doPhoneAuthenticate : function (component, event, helper) {
        const phoneNumber = (!component.get('v.mobileStepVO.bizData.customerVO.isPersonAccount')) ? component.get('v.contactPhoneNumber').join('-') : component.get('v.phoneNumber').join('-');

        console.log('💥💥💥💥💥💥💥 phoneNumber : ', phoneNumber);

        !$A.util.isEmpty(phoneNumber)
        ? helper.gfn_createComponent(component, 'lsMSalesCustomerConsultAuthQa', {
            phoneNumber: phoneNumber,
            isAuthenticated: component.getReference('v.mobileStepVO.bizData.isAuthenticated')
        }, 'slds-modal_medium')
        : helper.gfn_toast('번호를 입력해주세요.', 'w');
    },

    /**
     * 공백제거
     * @param component
     * @param event
     * @param helper
     */
    doReplaceWhiteSpace: function (component, event, helper) {
        helper.mfn_removeWhiteSpace(component, event, helper);
    },

    /**
     * 상담종료
     * @param component
     * @param event
     * @param helper
     */
    doCloseConsult: function (component, event, helper) {
        // B2C 여부
        const isPersonAccount = component.get('v.mobileStepVO.bizData.customerVO.isPersonAccount');

        // 전화번호를 개인 모바일 필드에 적용
        helper.fn_joinPhoneNumber(component, helper);
        !isPersonAccount && helper.fn_joinContactPhoneNumber(component, helper);
/*
        let lastName = component.get('v.mobileStepVO.bizData.customerVO.customer.LastName');
        component.set('v.mobileStepVO.bizData.customerVO.customer.LastName', lastName.replace(/\s/gi, ''));

        let phoneNumber1 = component.get('v.phoneNumber[1]');
        component.set('v.phoneNumber[1]', phoneNumber1.replace(/\s/gi, ''));

        let phoneNumber2 = component.get('v.phoneNumber[2]');
        component.set('v.phoneNumber[2]', phoneNumber2.replace(/\s/gi, ''));
*/
        const customerName = component.get('v.customerName');

        if(isPersonAccount) {
            component.set('v.mobileStepVO.bizData.customerVO.customer.LastName', customerName);
            component.set('v.mobileStepVO.bizData.customerVO.customer.IsPhoneCheck__pc', true);
        } else {
            component.set('v.mobileStepVO.bizData.customerVO.customer.Name', customerName);
            component.set('v.mobileStepVO.bizData.customerVO.customerContact.IsPhoneCheck__c', true);
        }

        component.set('v.mobileStepVO.bizData.prodSerRecStd.FarmingForm__c', component.get('v.farmingForm'));
        component.set('v.mobileStepVO.bizData.prodSerRecStd.FarmingSize__c', component.get('v.farmingSize'));
        // component.set('v.mobileStepVO.bizData.customerVO.customer.RecordTypeId', component.get('v.accountRecordTypeId'));

        //============================================================================
        // 이름, 전화번호가 모두 없을 경우에는 바로 상담 종료
        //============================================================================
        if(helper.fn_checkValid(component, helper)) {
            helper.log(component, '💥💥💥💥💥💥💥 ', JSON.stringify(component.get('v.mobileStepVO.bizData')));

            helper.apex(
                component, 'doCloseConsult', 'consultSave', {
                    //============================================================================
                    // BizData만 넘김
                    //============================================================================
                    'bizData': component.get('v.mobileStepVO.bizData')
                }
            ).then(function ({resData, response}) {
                helper.gfn_toast('정상처리 되었습니다.', 's');

                if(event.getSource().get('v.value') === 'quote') {
                    // 견적화면 이동
                    component.find('lacComService').doNaviService({
                        "type": component.get('v.isCommunity') ? "comm__namedPage" : "standard__namedPage",
                        "attributes": {
                            "name": "lsMSalesQuoteRegister__c"
                        },
                        "state": {
                            "opptyId": resData.Id
                        }
                    });
                }
                else {
                    //============================================================================
                    // 고객상담 main 이동
                    // 자신의 url 은 navi 가 안되므로 window reload 처리함
                    //============================================================================
                    window.location.reload(true);
                }
            }).catch(function ({error, response}) {
                helper.gfn_ApexErrorHandle(error, response);
            });

        }
    },

    /**
     * 사용형태에 따른 영농규모 불러오는 method
     *
     * @param component
     * @param event
     * @param helper
     */
    doSelectFarmForm : function (component, event, helper) {
        helper.fn_getFarmingSizeOptions(component);
    },

    // 2021-03-16 추가
    /**
     * Account의 Customer Type List 가져오는 method
     *
     * @param component
     * @param event
     * @param helper
     */
    doGetCustomerTypeOptions : function (component, event, helper) {
        helper.apex(
            component, 'doGetCustomerTypeOptions', 'getCustomerDataByRecordType', {
                recordTypeId: component.get('v.mobileStepVO.bizData.customerVO.customer.RecordTypeId')}
        ).then(({resData}) => {
            component.set('v.mobileStepVO.infoData.accountCustomerTypeList', resData.customerTypeList);
            // recordType을 변경하면서 여러가지 필드들이 수동적으로 reset필요.
            //고객 유형 reset
            component.set('v.mobileStepVO.bizData.customerVO.customer.CustomerType__c', null);
            // 사용 형태 reset
            component.set('v.farmingFormList', null);
            component.set('v.mobileStepVO.bizData.prodSerRecStd.FarmingForm__c', null);
            // 영농 규모 reset
            component.set('v.farmingAreaList', null);
            component.set('v.mobileStepVO.bizData.prodSerRecStd.FarmingSize__c', null);

            component.set('v.mobileStepVO.bizData.customerVO.isPersonAccount', resData.isPersonAccount);

            if (!$A.util.isEmpty(component.get('v.mobileStepVO.bizData.customerVO.customer.Id')) &&
                (component.get('v.mobileStepVO.bizData.customerVO.customer.RecordTypeId')) !== component.get('v.accountRecordTypeId')
            ) {
                component.set('v.customerName', null);
                component.set('v.phoneNumber[0]', null);
                component.set('v.phoneNumber[1]', null);
                component.set('v.phoneNumber[2]', null);
                component.set('v.mobileStepVO.bizData.customerVO.customer', resData.newAccount);
            }
        }).catch(({error}) => {
            helper.gfn_ApexErrorHandle(error);
        });
    },

    /**
     * 고객유형에 따른 사용형태 불러오는 method
     *
     * @param component
     * @param event
     * @param helper
     */
    doGetFarmInfoOptions : function (component, event, helper) {
        helper.apex(
            component, 'doGetFarmInfo', 'getFarmingInfo', {
                customerType: component.get('v.mobileStepVO.bizData.customerVO.customer.CustomerType__c')
            }
        ).then(function ({resData, response}) {
            component.set('v.farmingFormList', resData.farmingForm);
        }).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error, response);
        });
    },

});