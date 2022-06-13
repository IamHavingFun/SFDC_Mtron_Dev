({
	/**
	 * customer 조회
	 * @param component
	 * @param event
	 * @param helper
	 */
    doSearch: function (component, event, helper) {
        const accountRecordTypeId = component.get('v.accountRecordTypeId');

        !$A.util.isEmpty(accountRecordTypeId) && component.set('v.reqData.accountRecordTypeId', accountRecordTypeId);

		if(helper.fn_checkValid(component, helper)) {
			helper.apex(
				component, 'doSearch', 'search', {
					'reqData': JSON.stringify(component.get('v.reqData'))
				}
			).then(function ({resData, response}) {
				component.set('v.modelAccountList', resData);
			}).catch(function ({error, response}) {
				helper.gfn_ApexErrorHandle(error, response);
			});
		}
    },

	/**
	 * customer 선택
     * 추가된 소스로 중복 소스가 많아짐.
     *
	 * @param component
	 * @param event
	 * @param helper
	 */
	doChoice: function (component, event, helper) {
		const customer = JSON.parse(JSON.stringify(event.getSource().get('v.value')));
		component.set('v.customer', customer);
        customer.Contacts && component.set('v.customerContact', customer.Contacts[0]);

		helper.fn_setCustomerData(component, event);
        customer.Contacts && helper.fn_setCustomerContactData(component);

		// B2B일 때만 실행.
		const action = component.get('v.action');
		!!action && $A.enqueueAction(action);

		helper.gfn_closeQuickAction();
	},

	/**
	 * close
	 * @param component
	 * @param event
	 * @param helper
	 */
	doCancel : function(component, event, helper) {
		helper.gfn_closeQuickActionModal(component);
	}
});