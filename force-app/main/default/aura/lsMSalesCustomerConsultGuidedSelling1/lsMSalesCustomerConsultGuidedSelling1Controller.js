({
    /**
     *
     * @param component
     * @param event
     * @param helper
     */
    doInit: function (component, event, helper) {
        component.set('v.accountRecordTypeOptions', component.get('v.mobileStepVO.infoData.accountRecordTypeList'));
        component.set('v.accountCustomerTypeOptions', component.get('v.mobileStepVO.infoData.accountCustomerTypeList'));
        !$A.util.isEmpty(component.find('customerType').get('v.value')) && $A.enqueueAction(component.get('c.doGetFarmInfo'));
    	// helper.apex(
    	// 	component, 'doInit', 'getFarmingInfo', {}
    	// ).then(function ({resData, response}) {
        //     component.set('v.resData', resData);
        //     // 이전 데이터를 물고 있을 경우 영농유형에 따른 영농규모를 세팅
        //     if(!$A.util.isEmpty(component.get('v.mobileStepVO.bizData.prodSerRecStd.FarmingForm__c'))) {
        //     	helper.fn_getFarmingSizeOptions(component, event, helper);
		// 	}
    	// }).catch(function ({error, response}) {
    	// 	helper.gfn_ApexErrorHandle(error, response);
    	// });
    },

	/**
	 * 영농유형 선택
	 * @param component
	 * @param event
	 * @param helper
	 */
	doSelectFarmForm: function (component, event, helper) {
		component.find('farmFormItem').forEach(function(item){
			if(item.getElement() === event.currentTarget) {
				$A.util.addClass(event.currentTarget, 'box_select');
				component.set('v.mobileStepVO.bizData.prodSerRecStd.FarmingForm__c', event.currentTarget.dataset.value);
				// 영농규모 구함
				$A.enqueueAction(component.get('c.doGetFarmingSizeOptions'));
			}
			else {
				$A.util.removeClass(item.getElement(), 'box_select')
			}
		});
	},

	/**
	 * 영농형태 선택시 디펜던시 영농규모 구함
	 * @param component
	 * @param event
	 * @param helper
	 */
	doGetFarmingSizeOptions: function (component, event, helper) {
		// 기존의 데이터를 초기화
		component.set('v.mobileStepVO.bizData.prodSerRecStd.FarmingSize__c', null);
		// 영농 규모를 구함
		helper.fn_getFarmingSizeOptions(component, event, helper);
	},

    doGetCustomerTypeOptions : function (component, event, helper) {
        helper.apex(
            component, 'doGetCustomerType', 'getCustomerDataByRecordType', {
                recordTypeId: component.find('recordType').get('v.value')
            }
        ).then(({resData}) => {
            component.set('v.mobileStepVO.infoData.accountCustomerTypeList', resData.customerTypeList);
            component.set('v.accountCustomerTypeOptions', resData.customerTypeList);
            component.set('v.mobileStepVO.bizData.customerVO.customer', resData.newAccount);

            component.set('v.mobileStepVO.bizData.customerVO.isPersonAccount', resData.isPersonAccount);

            // combobox option 변화에 따른 값 초기화
            component.set('v.resData.farmingForm', null);
            component.set('v.mobileStepVO.bizData.customerVO.customer.CustomerType__c', null);
            component.set('v.mobileStepVO.bizData.prodSerRecStd.FarmingForm__c', null);
        }).catch(({error}) => {
            helper.gfn_ApexErrorHandle(error);
        });
    },

    doGetFarmInfo : function (component, event, helper) {
        helper.apex(
        	component, 'doGetFarmInfo', 'getFarmingInfo', {customerType: component.find('customerType').get('v.value')}
        ).then(function ({resData, response}) {
            component.set('v.resData', resData);
            // 이전 데이터를 물고 있을 경우 영농유형에 따른 영농규모를 세팅
            if(!$A.util.isEmpty(component.get('v.mobileStepVO.bizData.prodSerRecStd.FarmingForm__c'))) {
            	helper.fn_getFarmingSizeOptions(component, event, helper);
        	}
        }).catch(function ({error, response}) {
        	helper.gfn_ApexErrorHandle(error, response);
        });
    },

	/**
	 * Step 업무의 Self doNext
	 * 필수값등 valid 체크 로직 필요시 자체 구현
	 * @param component
	 * @param event
	 * @param helper
	 */
	doNextSelf: function (component, event, helper) {
		helper.fn_checkValid(component, helper)
		&& $A.enqueueAction(component.get('c.doNext'));
	}
});