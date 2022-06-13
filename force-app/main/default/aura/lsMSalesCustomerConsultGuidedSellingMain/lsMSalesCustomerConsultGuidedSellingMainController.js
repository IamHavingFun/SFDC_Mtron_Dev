({

    /**
     * 초기
     * @param component
     * @param event
     * @param helper
     */
    doInit: function (component, event, helper) {
    	component.set('v.isLoading', true);
    },

    /**
     * 가이드셀링 타입을 선택
     * (맟춤형 트랙터 추천, 전체 모델 보기)
     * @param component
     * @param event
     * @param helper
     */
    doSelectGuidedSellingType: function (component, event, helper) {
        component.find('guidedSellingItem').forEach(function(item){
            if(item.getElement() === event.currentTarget) {
                $A.util.addClass(event.currentTarget, 'box_select');
                const guidedSellingType = event.currentTarget.dataset.value;
                //============================================================================
                // 전체 초기화
                //============================================================================
                component.set('v.mobileStepVO.bizData', {});
                //============================================================================
                // 전체 초기화 후 가이드셀링 타입 지정
                //============================================================================
                component.set('v.mobileStepVO.bizData.guidedSellingType', guidedSellingType);

                //============================================================================
                // 맞춤형 트랙터 추천
                //============================================================================
                if(guidedSellingType === 'C') {
                    $A.enqueueAction(component.get('c.doNextSelf'));
                }
                //============================================================================
                // 전체 모델 보기 QA
                //============================================================================
                else {
                    helper.gfn_createComponent(
                        component,
                        'lsMSalesProductSearchQa',
                        {
                            // 바인딩 되는 선택 제품
                            'product': component.getReference('v.mobileStepVO.bizData.productVO.product'),
                            // 바인딩 되는 선택 제품시리즈
                            'productSeries': component.getReference('v.mobileStepVO.bizData.productSeriesVO.productSeries'),
                            // 바인딩 선택시 수행 Action
                            'finalAction': component.get('c.doFinalSelectProduct')
                        },
                        'slds-modal_large'
                    );
                }
            }
            else {
                $A.util.removeClass(item.getElement(), 'box_select')
            }
        });
    },

    /**
     * 제품QA에서 제품선택이후 처리해야할 action
     * 업무별로 구현을 해야한다.[유의]
     * @param component
     * @param event
     * @param helper
     */
    doFinalSelectProduct: function (component, event, helper) {
        helper.log(component, 'main 최종선택된 제품 : ', component.get('v.mobileStepVO.bizData.productVO.product'));
        helper.log(component, 'main 최종선택된 제품 Series : ', component.get('v.mobileStepVO.bizData.productSeriesVO.productSeries'));

        component.getEvent('changeStep').setParams({
            message: {
                'targetStep': 4,
                //============================================================================
                // step 컴포넌트 생성에 필요한 요소 전달용 : componentParams 사용할 것
                //============================================================================
                'componentParams': {
                    //============================================================================
                    // step 컴포넌트에 공통으로 사용하는 mobileStepVO를 통채로 넘긴다.[매우 중요]
                    //============================================================================
                    'mobileStepVO': component.get('v.mobileStepVO')
                }
            }
        }).fire();
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
    },

});