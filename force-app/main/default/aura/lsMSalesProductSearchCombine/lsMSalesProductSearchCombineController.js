({
    /**
     * 초기 거래
     * @param component
     * @param event
     * @param helper
     */
    doInit: function (component, event, helper) {

    	const searchProduct = component.get('v.searchProduct');
		searchProduct.ProductType__c = component.get('v.productType');

    	helper.apex(
    		component, 'doInit', 'init', {
    		    'searchProduct': searchProduct
    		}
    	).then(function ({resData, response}) {
            component.set('v.seriesOptions', resData.combineOptions);
            // 전체 거래
            $A.enqueueAction(component.get('c.doChangeSeries'));
    	}).catch(function ({error, response}) {
    		helper.gfn_ApexErrorHandle(error, response);
    	});
    },

	/**
	 * 옵션 변경시 검색
	 * @param component
	 * @param event
	 * @param helper
	 */
	doChangeSeries: function (component, event, helper) {
		// 이전 리스트 초기화
		component.set('v.recordList', null);
		// 선택된 제품을 초기화
		component.set('v.product', null);

		helper.apex(
			component, 'doChangeSeries', 'search', {
				'searchProduct': component.get('v.searchProduct')
			}
		).then(function ({resData, response}) {
			component.set('v.recordList', resData);
		}).catch(function ({error, response}) {
			helper.gfn_ApexErrorHandle(error, response);
		});
	},

	/**
	 * 최종 제품 선택
	 * @param component
	 * @param event
	 * @param helper
	 */
	doSelectProduct: function (component, event, helper) {
	    let productItems = component.find('productItem');

	    productItems = $A.util.isArray(productItems) ? productItems : [productItems];

        productItems.forEach(item => {
			if(item.getElement() === event.currentTarget) {
				const productId = event.currentTarget.dataset.value;
				component.get('v.recordList').some((product) => {
					if(product.Id === productId) {
						//============================================================================
						// producVO의 데이터를 지정한다.
						//============================================================================
						component.set('v.product', product);
						return true;
					}
				});
				$A.util.addClass(event.currentTarget, 'select');
			}
			else {
				$A.util.removeClass(item.getElement(), 'select')
			}
		});
	},

	/**
	 * 최종 선택시 처리
	 * @param component
	 * @param event
	 * @param helper
	 */
	doChoice: function (component, event, helper) {
		if(helper.fn_checkValid(component, helper)) {
			/*
			 * ================================================================
			 * 1. 최종 선택된 제품을 넘김
			 * 2. lsMSalesProductSearchQa 에서 handler 처리
			 * ================================================================
			 */
			component.getEvent('fianlSelectProduct').setParams({
				message: {
					'product': component.get('v.product')
				}
			}).fire();
		}
	},

	/**
	 * 닫기
	 * @param comment
	 * @param event
	 * @param helper
	 */
	doClose: function (comment, event, helper) {
		helper.gfn_closeQuickAction();
	}
});