({
    /**
     * valid check
     * @param component
     * @param helper
     * @returns {boolean}
     */
    fn_checkValid: function (component, helper) {
        if($A.util.isEmpty(component.get('v.reqData.name'))) {
            helper.gfn_toast('고객명을 입력하세요', 'w');
            return false
        }

        return true;
    },

    fn_setCustomerData : function (component, event) {
        const customer = component.get('v.customer');

        // recordType 추가로 split 대상 필드가 분리됨.
        !$A.util.isEmpty(customer.PersonMobilePhone) ?
        component.set('v.phoneNumber', customer.PersonMobilePhone.split('-')) :
        component.set('v.phoneNumber', customer.Phone.split('-'));

        /*
        * pop up을 띄우는 parent cmp 관계없이 세팅. -> 때에 따라서는 아무 의미없는 코드
        * 현재는 lsMSalesCustomerConsultCard에서만 사용
        * */
        !$A.util.isEmpty(customer.LastName) ?
        component.set('v.customerName', customer.LastName) :
        component.set('v.customerName', customer.Name);

        // 전화번호 인증 여부
        component.set('v.isPhoneCheck', customer.IsPhoneCheck__pc);

    },

    fn_setCustomerContactData : function (component) {
        const customerContact = component.get('v.customerContact');

        component.set('v.contactPhoneNumber', customerContact.Phone.split('-'));

        // 전화번호 인증 여부
        component.set('v.isPhoneCheck', customerContact.IsPhoneCheck__c);

    },
});