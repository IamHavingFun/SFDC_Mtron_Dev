({
    /**
     * valid Check
     * @param component
     * @param helper
     * @returns {boolean}
     */
    fn_checkValid: function (component, helper) {

        if($A.util.isEmpty(component.get('v.mobileStepVO.bizData.productVO.product'))) {
            helper.gfn_toast('제품이 선택되지 않았습니다. 확인후 제품을 선택하세요.', 'w');
            return false;
        }

        if(component.get('v.mobileStepVO.bizData.customerVO.isPersonAccount') && $A.util.isEmpty(component.get('v.mobileStepVO.bizData.customerVO.customer.LastName'))) {
            helper.gfn_toast('신규고객명을 입력하시거나 또는 고객조회후 기등록 고객을 선택하세요.', 'w');
            return false;
        }

        if(!component.get('v.mobileStepVO.bizData.customerVO.isPersonAccount') && $A.util.isEmpty(component.get('v.mobileStepVO.bizData.customerVO.customer.Name'))) {
            helper.gfn_toast('신규고객명을 입력하시거나 또는 고객조회후 기등록 고객을 선택하세요.', 'w');
            return false;
        }

        // B2C, B2B : 고객 또는 대표번호 공통 valid
        if(
                $A.util.isEmpty(component.get('v.phoneNumber[0]'))
            ||  $A.util.isEmpty(component.get('v.phoneNumber[1]'))
            ||  $A.util.isEmpty(component.get('v.phoneNumber[2]'))
        ) {
            console.log('💥💥💥💥💥💥💥 ', component.get('v.phoneNumber[0]'));
            console.log('💥💥💥💥💥💥💥 ', component.get('v.phoneNumber[1]'));
            console.log('💥💥💥💥💥💥💥 ', component.get('v.phoneNumber[2]'));
            helper.gfn_toast('전화번호를 입력하시기 바랍니다.', 'w');
            return false;
        }

        if(
                !helper.mfn_isOnlyNumber(component.get('v.phoneNumber[1]'))
            ||  !helper.mfn_isOnlyNumber(component.get('v.phoneNumber[2]'))
        ) {
            helper.gfn_toast('전화번호는 숫자만 입력하시기 바랍니다.', 'w');
            return false;
        }

        if(
                component.get('v.phoneNumber[1]').length !== 3
            &&  component.get('v.phoneNumber[1]').length !== 4
        ) {
            helper.gfn_toast('전화번호는 중간자리는 3~4자리 숫자를 입력하시기 바랍니다.', 'w');
            return false;
        }

        if(component.get('v.phoneNumber[2]').length !== 4) {
            helper.gfn_toast('전화번호는 마지막자리는 4자리 숫자를 입력하시기 바랍니다.', 'w');
            return false;
        }

        // B2B : 대표번호 valid
        if(!component.get('v.mobileStepVO.bizData.customerVO.isPersonAccount')) {
            if(
                    component.get('v.phoneNumber[0]').length < 2
                ||  component.get('v.phoneNumber[0]').length > 4
            ) {
                helper.gfn_toast('지역번호는 2~4자리 숫자를 입력하시기 바랍니다.', 'w');
                return false;
            }
        }

        // B2B : Contact 휴대폰
        if(!component.get('v.mobileStepVO.bizData.customerVO.isPersonAccount')) {
            if(
                $A.util.isEmpty(component.get('v.contactPhoneNumber[0]'))
                ||  $A.util.isEmpty(component.get('v.contactPhoneNumber[1]'))
                ||  $A.util.isEmpty(component.get('v.contactPhoneNumber[2]'))
            ) {
                helper.gfn_toast('전화번호를 입력하시기 바랍니다.', 'w');
                return false;
            }

            if(
                !helper.mfn_isOnlyNumber(component.get('v.contactPhoneNumber[1]'))
                ||  !helper.mfn_isOnlyNumber(component.get('v.contactPhoneNumber[2]'))
            ) {
                helper.gfn_toast('전화번호는 숫자만 입력하시기 바랍니다.', 'w');
                return false;
            }

            if(
                component.get('v.contactPhoneNumber[1]').length !== 3
                &&  component.get('v.contactPhoneNumber[1]').length !== 4
            ) {
                helper.gfn_toast('전화번호는 중간자리는 3~4자리 숫자를 입력하시기 바랍니다.', 'w');
                return false;
            }

            if(component.get('v.contactPhoneNumber[2]').length !== 4) {
                helper.gfn_toast('전화번호는 마지막자리는 4자리 숫자를 입력하시기 바랍니다.', 'w');
                return false;
            }

            if($A.util.isEmpty(component.get('v.mobileStepVO.bizData.customerVO.customerContact.LastName'))) {
                helper.gfn_toast('이름을 입력하시기 바랍니다.', 'w');
                return false;
            }
        }

        if($A.util.isEmpty(component.get('v.mobileStepVO.bizData.customerVO.customer.CustomerType__c'))) {
            helper.gfn_toast('고객유형을 선택하세요.', 'w');
            return false;
        }

        if($A.util.isEmpty(component.get('v.mobileStepVO.bizData.prodSerRecStd.FarmingForm__c'))) {
            helper.gfn_toast('사용형태를 선택하세요.', 'w');
            return false;
        }

        if($A.util.isEmpty(component.get('v.mobileStepVO.bizData.prodSerRecStd.FarmingSize__c'))) {
            helper.gfn_toast('영농규모를 선택하세요.', 'w');
            return false;
        }

        if($A.util.isEmpty(component.get('v.mobileStepVO.bizData.customerVO.cupi.IsCUPI__c')) || component.get('v.mobileStepVO.bizData.customerVO.cupi.IsCUPI__c') === false)
        {
            helper.gfn_toast('[개인정보 수집에 동의] 동의하시기 바랍니다.', 'w');
            return false;
        }

        if($A.util.isEmpty(component.get('v.mobileStepVO.bizData.customerVO.cupi.ReceiveSMS__c')) || component.get('v.mobileStepVO.bizData.customerVO.cupi.ReceiveSMS__c') === false)
        {
            helper.gfn_toast('[개인정보 활용 동의(SMS)] 동의하시기 바랍니다.', 'w');
            return false;
        }

        if(!component.get('v.mobileStepVO.bizData.isAuthenticated')) {
            helper.gfn_toast('입력하신 휴대전화번호에 대한 인증이 처리되지 않았습니다. 상단의 [인증]을 통해 인증 과정을 진행 바랍니다.', 'w');
            return false;
        }

        return true;
    },

    /**
     * 전화번호 3개 항목을 join 하여 PersonMobilePhone 에 세팅
     * @param component
     * @param helper
     */
    fn_joinPhoneNumber: function (component, helper) {
        const phoneNumber = component.get('v.phoneNumber');
        const refinedPhoneNumber = $A.util.isEmpty(phoneNumber) ? '' : phoneNumber.join("-");

        component.get('v.mobileStepVO.bizData.customerVO.isPersonAccount') ?
        component.set('v.mobileStepVO.bizData.customerVO.customer.PersonMobilePhone', refinedPhoneNumber) :
        component.set('v.mobileStepVO.bizData.customerVO.customer.Phone', refinedPhoneNumber);
    },

    /**
     * 전화번호 3개 항목을 join 하여 Contact의 Phone 에 세팅
     * @param component
     * @param helper
     */
    fn_joinContactPhoneNumber: function (component, helper) {
        const phoneNumber = component.get('v.contactPhoneNumber');
        const refinedPhoneNumber = $A.util.isEmpty(phoneNumber) ? '' : phoneNumber.join("-");

        component.set('v.mobileStepVO.bizData.customerVO.customerContact.Phone', refinedPhoneNumber);
    },

    /**
     * PersonMobilePhone 값을 split하여 전화번호 3개 항목으로 분리
     * @param component
     * @param helper
     */
    fn_splitPersonMobilePhone: function (component, helper) {
        const personMobilePhone = component.get('v.mobileStepVO.bizData.customerVO.customer.PersonMobilePhone');
        component.set('v.phoneNumber', $A.util.isEmpty(personMobilePhone) ? [] : personMobilePhone.split('-'));
    },

    fn_getFarmingSizeOptions : function (component) {
        this.apex(
            component, 'fn_getFarmingSizeOptions', 'getFarmingSizeOptions', {
                farmingForm: component.get('v.farmingForm')
            }
        ).then(({resData}) => {
            component.set('v.farmingAreaList', resData);
        }).catch(({error}) => {
            this.gfn_ApexErrorHandle(error);
        });
    }
});