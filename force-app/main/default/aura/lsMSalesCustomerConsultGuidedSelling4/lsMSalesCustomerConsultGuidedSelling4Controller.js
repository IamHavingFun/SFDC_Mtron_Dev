({
	/**
	 * 초기 거래
	 * @param component
	 * @param event
	 * @param helper
	 */
    doInit: function (component, event, helper) {

    	/*
    	 * ================================================================
    	 * [매우 중요] 전체 제품 조회에서 넘어온 경우에도
    	 * lsMSalesCustomerConsultGuidedSellingMain 컴포넌트의 fianlSelectProduct 핸들러에서
    	 * 이벤트 발생시 생성파라미터에 mobileStepVO 를 key로 전체를 넘기기 때문에
    	 * 바로 사용이 가능하다. 이점이 매우 중요하다.
    	 * ================================================================
    	 */
		helper.log(component, '[매우중요] mobileStepVO : ', JSON.parse(JSON.stringify(component.get('v.mobileStepVO'))));

    	helper.apex(
    		component, 'doInit', 'getProductVO', {
    			'product': component.get('v.mobileStepVO.bizData.productVO.product')
    		}
    	).then(function ({resData, response}) {
			component.set('v.productVO', resData);
		}).catch(function ({error, response}) {
    		helper.gfn_ApexErrorHandle(error, response);
    	});
    },

	/**
	 * 재고현환 조회
	 * @param component
	 * @param event
	 * @param helper
	 */
	doSearchInventory: function (component, event, helper) {
		helper.gfn_createComponent(
			component,
			'lsMSalesInventoryStatusQa',
			{
				'targetProduct': component.get('v.mobileStepVO.bizData.productVO.product')
			},
			'slds-modal_medium'
		);
	},

	/**
	 * 제원 현황
	 * @param component
	 * @param event
	 * @param helper
	 */
	doSpecification: function (component, event, helper) {
		helper.gfn_createComponent(
			component,
			'lsMSalesCustomerConsultSpecificationQa',
			{
				'productSeries': component.get('v.mobileStepVO.bizData.productSeriesVO.productSeries')
			},
			'slds-modal_large'
		);
	},

	/**
	 * 이전화면 자체 처리
	 * @param component
	 * @param event
	 * @param helper
	 */
	doPrevSelf: function (component, event, helper) {
		if(component.get('v.mobileStepVO.bizData.guidedSellingType') === 'C') {
			$A.enqueueAction(component.get('c.doPrev'));
		}
		else {
			component.getEvent('changeStep').setParams({
				message: {
					'targetStep': 0,
				}
			}).fire();
		}
	},

	/**
	 * 다음 화면 이동
	 * @param component
	 * @param event
	 * @param helper
	 */
	doNextSelf: function (component, event, helper) {
		//============================================================================
		// 전체 제품에서 넘어온 경우 step 변경이 안되기에 강제적으로 지정
		//============================================================================
		if(component.get('v.mobileStepVO.bizData.guidedSellingType') === 'A') {
			component.set('v.step', 4);
		}
		$A.enqueueAction(component.get('c.doNext'));
	},

});