({
    /**
     * 초기 거래
     * @param component
     * @param event
     * @param helper
     */
    doInit: function (component, event, helper) {
    	helper.apex(
    		component, 'doInit', 'getProductSeriesVOSSpecifications', {
    		    'productSeriesId': component.get('v.productSeries.Id')
    		}
    	).then(function ({resData, response}) {
			component.set('v.resData', resData);
    	}).catch(function ({error, response}) {
    		helper.gfn_ApexErrorHandle(error, response);
    	});
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