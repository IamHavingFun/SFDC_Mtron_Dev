({
    /**
     * 초기 거래
     * @param component
     * @param event
     * @param helper
     */
    doInit: function (component, event, helper) {

        let horsePowerList = component.get('v.mobileStepVO.bizData.productSeriesVO.productSeries.HorsePowerList__c');
        horsePowerList = $A.util.isEmpty(horsePowerList) ? [] : horsePowerList.split(';');
        horsePowerList.sort((a, b) => a - b);

        const horsePowerItems = horsePowerList.map((value, index, horsePowerList) => {
            return (index % 2 === 0) && [value, horsePowerList[index+1]];
        }).filter((item) => item);

        component.set('v.horsePowerItems', horsePowerItems);

/*
        let options1 = component.get('v.mobileStepVO.bizData.productSeriesVO.productSeries.Option1__c');
        component.set('v.options1', $A.util.isEmpty(options1) ? [] : options1.split(';').sort((a, b) => a.localeCompare(b)).map(value => { return {'label': value, 'value': value} }));

        let options2 = component.get('v.mobileStepVO.bizData.productSeriesVO.productSeries.Option2__c');
        component.set('v.options2', $A.util.isEmpty(options2) ? [] : options2.split(';').sort((a, b) => a.localeCompare(b)).map(value => { return {'label': value, 'value': value} }));

        let options3 = component.get('v.mobileStepVO.bizData.productSeriesVO.productSeries.Option3__c');
        component.set('v.options3', $A.util.isEmpty(options3) ? [] : options3.split(';').sort((a, b) => a.localeCompare(b)).map(value => { return {'label': value, 'value': value} }));

        let options4 = component.get('v.mobileStepVO.bizData.productSeriesVO.productSeries.Option4__c');
        component.set('v.options4', $A.util.isEmpty(options4) ? [] : options4.split(';').sort((a, b) => a.localeCompare(b)).map(value => { return {'label': value, 'value': value} }));
*/

        // 선택한 제품시리즈에서 조회용 제품시리즈로 기본 데이터 세팅
        // 1. 기본 Series__c 값 세팅
        component.set('v.mobileStepVO.infoData.searchProductSeries.Series__c', component.get('v.mobileStepVO.bizData.productSeriesVO.productSeries.Series__c'));

        $A.enqueueAction(component.get('c.doSearchProducts'));
    },

    /**
     * 마력 선택 : lighting:input 을 이용하기에 이벤트 처리를 통한 데이터 세팅
     * @param component
     * @param event
     * @param helper
     */
    doSelectHorsePowerItem : function (component, event, helper) {
        let horsePowerItems = component.find('horsePowerItem');
        horsePowerItems = $A.util.isArray(horsePowerItems) ? horsePowerItems : [horsePowerItems];
        horsePowerItems.forEach((item) => {
            if(event.getSource() === item) {
                event.getSource().set('v.checked', true);
                component.set('v.mobileStepVO.infoData.searchProductSeries.HorsePower__c', event.getSource().get('v.value'));
            }
            else {
                item.set('v.checked', false);
            }
        });

        $A.enqueueAction(component.get('c.doSearchProducts'));
    },

    /**
     * 제품리스트 조회
     * @param comment
     * @param event
     * @param helper
     */
    doSearchProducts: function(component, event, helper) {
        //============================================================================
        // 해당 제품시리즈의 마력조건 제품리스트 조회
        //============================================================================
        helper.apex(
            component, 'doSelectHorsePowerItem', 'getProducts', {
                'searchProductSeries': component.get('v.mobileStepVO.infoData.searchProductSeries')
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
                $A.util.addClass(event.currentTarget, 'box_select');
            }
            else {
                $A.util.removeClass(item.getElement(), 'box_select')
            }
        });
    },


    /**
     * 다음 단계로 이동
     * @deprecated : 다음단계 대신 선택 버튼으로 치환됨
     * @param component
     * @param event
     * @param helper
     */
/*
    doNextSelf: function (component, event, helper) {
        if(helper.fn_checkValid(component, helper)) {
            helper.apex(
                component, 'doNextSelf', 'getProduct', {
                    'searchProductSeries': component.get('v.mobileStepVO.infoData.searchProductSeries')
                }
            ).then($A.getCallback(function ({resData, response}) {
                /!*
                 * ================================================================
                 * 1. 최종 선택된 제품을 넘김
                 * 2. lsMSalesProductSearchQa 에서 handler 처리
                 * ================================================================
                 *!/
                component.getEvent('fianlSelectProduct').setParams({
                    message: {
                        'product': resData,
                        'productSeries': component.get('v.mobileStepVO.bizData.productSeriesVO.productSeries')
                    }
                }).fire();
            })).catch(function ({error, response}) {
                helper.gfn_ApexErrorHandle(error, response);
            });

        }
    },
*/

    /**
     * 제품 선택
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
                    'product': component.get('v.product'),
                    'productSeries': component.get('v.mobileStepVO.bizData.productSeriesVO.productSeries')
                }
            }).fire();

        }
    }

});