({
    /**
     * 초기 거래
     * @param component
     * @param event
     * @param helper
     */
    doInit: function (component, event, helper) {

        component.set('v.recordList', [
            {label:'트랙터', value:'트랙터'},
            {label:'콤바인', value:'콤바인'},
            {label:'이앙기', value:'이앙기'},
        ]);

        component.set('v.mobileStepVO.bizData.productType', component.get('v.recordList')[0]);

/*        helper.apex(
            component, 'doInit', 'init', {}
        ).then(function ({resData, response}) {
            component.set('v.recordList', resData.interestProductTypeOptions);
            //============================================================================
            // 초기 productType 세팅
            //============================================================================
            component.set('v.mobileStepVO.bizData.productType', component.get('v.recordList')[0]);
        }).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error, response);
        });*/
    },

    /**
     * 선택시 제품타입 세팅
     * @param component
     * @param event
     * @param helper
     */
    doTabActive: function (component, event, helper) {
        const tabName = event.currentTarget.dataset.tabid;
        component.set('v.tabName', tabName);

        component.set('v.mobileStepVO.bizData.productType', event.currentTarget.dataset.id);
    },

    /**
     * 최종제품선택 이벤트 처리
     * 최종 컴포넌트에서 이벤트 발생함.
     * @param component
     * @param event
     * @param helper
     */
    handleFinalSelectProduct: function (component, event, helper) {
        helper.log(component, 'handleFinalSelectProduct message : ', JSON.stringify(event.getParam('message')));
        /*
         * ================================================================
         * 제품검색 QA 에 바인딩된 제품 속성에 이벤트 파라미터로 넘어온 제품 바인딩
         * ================================================================
         */
        component.set('v.product', event.getParam('message').product);
        component.set('v.productSeries', event.getParam('message').productSeries);

        /*
         * ================================================================
         * lsMSalesCustomerConsultGuidedSellingMain 페이지에서
         * 위임처리 요청한 Action을 처리함
         * ================================================================
         */
        const finalAction = component.get('v.finalAction');
        if(!$A.util.isEmpty(finalAction)) {
            $A.enqueueAction(finalAction);
            helper.gfn_closeQuickAction();
        }
    },

});