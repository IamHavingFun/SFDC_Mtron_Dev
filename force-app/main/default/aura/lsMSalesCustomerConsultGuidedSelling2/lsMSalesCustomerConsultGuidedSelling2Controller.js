({
	/**
	 * 초기 거래
	 * @param component
	 * @param event
	 * @param helper
	 */
    doInit: function (component, event, helper) {

        const reqData = component.get('v.reqData');
        //============================================================================
        // 영농형태, 영농규모 선택값 세팅
        //============================================================================
        reqData.farmingForm = component.get('v.mobileStepVO.bizData.prodSerRecStd.FarmingForm__c');
        reqData.farmingSize = component.get('v.mobileStepVO.bizData.prodSerRecStd.FarmingSize__c');

    	helper.apex(
    		component, 'doInit', 'getProductSeriesVOS', {
    		    'reqData': JSON.stringify(reqData)
    		}
    	).then(function ({resData, response}) {
			component.set('v.recordList', resData);
    	}).catch(function ({error, response}) {
    		helper.gfn_ApexErrorHandle(error, response);
    	});
    },

	/**
	 * 제품 시리즈 선택
	 * @param component
	 * @param event
	 * @param helper
	 */
	doSelectProductSeries: function (component, event, helper) {

		let items = component.find('productSeriesItem');
		items = $A.util.isArray(items) ? items : [items];

		items.forEach(item => {
			if(item.getElement() === event.currentTarget) {
				const productSeriesId = event.currentTarget.dataset.value;
				component.get('v.recordList').some((vo) => {
					if(vo.productSeries.Id === productSeriesId) {
						//============================================================================
						// 선택된 제품시리즈VO 세팅[유의]
						//============================================================================
						component.set('v.mobileStepVO.bizData.productSeriesVO', vo);
						return true;
					}
				});
				$A.util.addClass(event.currentTarget, 'box_select');
			}
			else {
				$A.util.removeClass(item.getElement(), 'box_select')
			}
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