({
    /**
     * 초기 거래
     * @param component
     * @param event
     * @param helper
     */
    doInit: function (component, event, helper) {
        // 전화번호 분리
        //helper.fn_splitPersonMobilePhone(component, helper);
        const privacyText = "LS엠트론에서 고객님께 더 나은 구매조건을 제공하기 위해\n위와 같은 개인정보활용에 동의를 구하고 합니다\n개인정보 활용동의는 개인정보보호법 등의 법률에 따라 반드시 필요한 절차이며, LS엠트론에서 판매하는 제품의 판매/상담/서비스/마케팅제공을 위해 최소한의 정보만 수집/이용하게 됩니다.";
        //\n\nLS엠트론 개인정보 처리방침 확인\nhttps://www.lsmtron.co.kr/page/popup/privacy.asp";
        component.set('v.privacyText', privacyText);
        component.set('v.farmingForm', '');
        component.set('v.farmingSize', '');

        helper.apex(
            component, 'doInit', 'customerInit', {
                asset: component.get('v.mobileStepVO.bizData.asset')
            }
        ).then(({resData}) => {
            //component.set('v.mobileStepVO.claimData', resData);
            component.set('v.claimData', resData);
            $A.enqueueAction(component.get('c.doGetCustomerTypeOptions'));
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
        const isPersonAccount = component.get('v.claimData.customerVO.isPersonAccount');

        if(isPersonAccount) {
            paramObject = {
                customer: component.getReference('v.claimData.customerVO.customer'),
                phoneNumber: component.getReference('v.phoneNumber'),
                accountRecordTypeId: component.getReference('v.claimData.customerVO.customer.RecordTypeId'),
                customerName: component.getReference('v.customerName'),
                isPhoneCheck: component.getReference('v.claimData.isAuthenticated'),
                action: component.getReference('c.doGetCustomerSearchSelected')
            };
        } else {
            paramObject = {
                customer: component.getReference('v.claimData.customerVO.customer'),
                phoneNumber: component.getReference('v.phoneNumber'),
                accountRecordTypeId: component.getReference('v.claimData.customerVO.customer.RecordTypeId'),
                customerName: component.getReference('v.customerName'),
                action: component.getReference('c.doGetCustomerSearchSelected'),
                contactPhoneNumber: component.getReference('v.contactPhoneNumber'),
                customerContact: component.getReference('v.claimData.customerVO.customerContact'),
                isPhoneCheck: component.getReference('v.claimData.isAuthenticated')
            };
        }

        if($A.util.isEmpty(component.get('v.claimData.customerVO.customer.RecordTypeId'))) {
            helper.gfn_toast('고객타입을 지정해주세요.', 'w');
            return;
        }

        helper.gfn_createComponent(component, 'lsMSalesCustomerConsultSearchCustomerQa', paramObject, 'slds-modal_medium');
    },

    doGetCustomerSearchSelected : function (component, event, helper) {
        helper.apex(
            component, 'doGetCustomerSearchSelected', 'getCustomerSearchSelected', {
                accountId: component.get('v.claimData.customerVO.customer.Id')
            }
        ).then(({resData}) => {
            component.set('v.farmingFormList', resData.farmFormList);
            component.set('v.farmingAreaList', resData.farmAreaList);
            //component.set('v.claimData.customerVO.customer', resData.customer);
            component.set('v.claimData.customerVO.customer.FarmingForm__c', resData.customer.FarmingForm__c);
            component.set('v.claimData.customerVO.customer.FarmingArea__c', resData.customer.FarmingArea__c);

            !$A.util.isEmpty(resData.customer.PersonMobilePhone) ?
                component.set('v.claimData.customerVO.isPersonAccount', true) :
                component.set('v.claimData.customerVO.isPersonAccount', false);

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

        // component.set('v.claimData.isAuthenticated', true);

        const phoneNumber = (!component.get('v.claimData.customerVO.isPersonAccount')) ? component.get('v.contactPhoneNumber').join('-') : component.get('v.phoneNumber').join('-');
        console.log('💥💥💥💥💥💥💥 phoneNumber : ', phoneNumber);
        !$A.util.isEmpty(phoneNumber) && phoneNumber !== '--'
            ? helper.gfn_createComponent(component, 'lsMSalesCustomerConsultAuthQa', {
                phoneNumber: phoneNumber,
                isAuthenticated: component.getReference('v.claimData.isAuthenticated')
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

    doCancel : function (component, event, helper) {
        component.find('lacComService').doNaviService({
            "type": component.get('v.isCommunity') ? "comm__namedPage" : "standard__namedPage",
            "attributes": {
                "name": "lsMSalesHome__c"
            },
        });
    },
    /**
     * 고객등록 종료
     * @param component
     * @param event
     * @param helper
     */
    doCustomerSave: function (component, event, helper) {
        // B2C 여부
        const isPersonAccount = component.get('v.claimData.customerVO.isPersonAccount');
console.log('isPersonAccount ==> ' + isPersonAccount);

        // 전화번호를 개인 모바일 필드에 적용
        helper.fn_joinPhoneNumber(component, helper);
        !isPersonAccount && helper.fn_joinContactPhoneNumber(component, helper);

        const customerName = component.get('v.customerName');

        if(isPersonAccount) {
            component.set('v.claimData.customerVO.customer.LastName', customerName);
        } else {
            component.set('v.claimData.customerVO.customer.Name', customerName);
        }


//        component.set('v.claimData.customerVO.customer.FarmingForm__c', component.get('v.farmingForm'));
//        component.set('v.claimData.customerVO.customer.FarmingArea__c', component.get('v.farmingSize'));


        //============================================================================
        // 이름, 전화번호가 모두 없을 경우에는 바로 상담 종료
        //============================================================================
        if(helper.fn_checkValid(component, helper)) {

            helper.apex(
                component, 'doCustomerSave', 'customerSave', {
                    //============================================================================
                    // BizData만 넘김
                    //============================================================================
                    'claimData': component.get('v.claimData')
                }
            ).then(function ({resData, response}) {
                helper.gfn_toast('해당 자산에 대한 고객정보 업데이트가 정상 처리 되었습니다.', 's');
                $A.enqueueAction(component.get('c.doNext'));
            }).catch(function ({error, response}) {
                helper.gfn_ApexErrorHandle(error, response);
            });

        }

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
                recordTypeId : component.get('v.claimData.customerVO.customer.RecordTypeId')}
        ).then(({resData}) => {

            component.set('v.claimData.accountRecordTypeList', resData.accountRecordTypeList);
            component.set('v.claimData.accountCustomerTypeList', resData.customerTypeList);
            // recordType을 변경하면서 여러가지 필드들이 수동적으로 reset필요.
            component.set('v.claimData.customerVO.isPersonAccount', resData.isPersonAccount);
            //고객 유형 reset
            component.set('v.claimData.customerVO.customer.CustomerType__c', null);
            // 사용 형태 reset
            component.set('v.farmingFormList', null);
            component.set('v.claimData.customerVO.customer.FarmingForm__c', null);
            // 영농 규모 reset
            component.set('v.farmingAreaList', null);
            component.set('v.claimData.customerVO.customer.FarmingArea__c', null);

            component.set('v.customerName', null);
            component.set('v.phoneNumber[0]', null);
            component.set('v.phoneNumber[1]', null);
            component.set('v.phoneNumber[2]', null);

            // 법인 담당자 휴대폰 값 초기화.
            component.set('v.claimData.customerVO.customerContact.LastName', null);
            component.set('v.contactPhoneNumber[0]', null);
            component.set('v.contactPhoneNumber[1]', null);
            component.set('v.contactPhoneNumber[2]', null);

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
                customerType: component.get('v.claimData.customerVO.customer.CustomerType__c')
            }
        ).then(function ({resData, response}) {
            component.set('v.farmingFormList', resData.farmingForm);
            // 사용 형태 reset
            component.set('v.claimData.customerVO.customer.FarmingForm__c', null);
            // 영농 규모 reset
            component.set('v.claimData.customerVO.customer.FarmingArea__c', null);
        }).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error, response);
        });
    },

    /**
     * 사용형태에 따른 영농규모 불러오는 method
     *
     * @param component
     * @param event
     * @param helper
     */
    doSelectFarmForm : function (component, event, helper) {
        helper.apex(
            component, 'doGetFarmingAreaOptions', 'getFarmingSizeOptions', {
                farmingForm : component.get('v.claimData.customerVO.customer.FarmingForm__c')
            }
        ).then(function ({resData, response}) {
            component.set('v.farmingAreaList', resData);
            // 영농 규모 reset
            component.set('v.claimData.customerVO.customer.FarmingArea__c', null);
        }).catch(function (error) {
            helper.gfn_ApexErrorHandle(error, response);
        });
    },
});