({
    /**
     * 초기거래
     * @param component
     * @param event
     * @param helper
     */
    doInit: function (component, event, helper) {

        const reqData = component.get('v.reqData');
        const productType = component.get('v.mobileStepVO.bizData.productType');
        reqData.productType = $A.util.isEmpty(productType) ? '트랙터' : productType;

    	helper.apex(
    		component, 'doInit', 'getProductSeriesVOSForType', {
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
        //============================================================================
        // 최종적으로 체크후 다음단계 이동
        //============================================================================
        $A.enqueueAction(component.get('c.doNextSelf'));
    },

    /**
     * 다음 단계로 이동
     * @param component
     * @param event
     * @param helper
     */
    doNextSelf: function (component, event, helper) {
        helper.fn_checkValid(component, helper)
        && $A.enqueueAction(component.get('c.doNext'));
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