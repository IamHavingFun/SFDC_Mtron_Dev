/**
 * Created by MS on 2020-07-02.
 */

({
    /**
     * 기대번호에 따른 data 조회 및 세팅.
     *
     * @param component
     * @param event
     * @param helper
     */
    doSearch : function (component, event, helper) {
        helper.apex(
            component, 'doSearch', 'getPDIData', {assetName:component.get('v.mobileStepVO.bizData.asset.Name')}
        ).then(({resData, response}) => {
            component.set('v.mobileStepVO', resData);
        }).catch(({error, response}) => {
            helper.gfn_ApexErrorHandle(error, response);
        });
    },

    /**
     *
     * @param component
     * @param event
     * @param helper
     */
    doSelected: function (component, event, helper) {
        const recordId = event.currentTarget.dataset.recordid;
        let items = component.find('item');
        items = $A.util.isArray(items) ? items : [items];

        items.forEach(item => {
            if(item.getElement() === event.currentTarget) {
                console.log('000000000000');
                component.get('v.mobileStepVO.bizData.targetContracts').some((record) => {
                    if(record.Id === recordId) {
                        //============================================================================
                        // 선택된 제품시리즈VO 세팅[유의]
                        //============================================================================
                        component.set('v.mobileStepVO.bizData.contract', record);
                        if(record.ContractLineItem__r.length > 0) component.set('v.mobileStepVO.bizData.contractItem', record.ContractLineItem__r[0]);
                        helper.log(component, '@@@@@@@@@@@',component.get('v.mobileStepVO.bizData.contract'));
                        return true;
                    }
                });
                $A.util.addClass(event.currentTarget, 'box_select');
            }
            else {
                console.log('11111111111');
                $A.util.removeClass(item.getElement(), 'box_select')

            }
        });
    },


    /**
     * 다음
     * @param component
     * @param event
     * @param helper
     */
    doNextSelf: function (component, event, helper) {
        console.log(JSON.stringify(component.get('v.mobileStepVO.bizData.contract')));
        helper.fn_checkValid(component, helper) && $A.enqueueAction(component.get('c.doNext'));
    },
    /**
     * 홈으로
     * @param component
     * @param event
     * @param helper
     */
    doCancel: function (component, event, helper) {
        component.find('lacComService').doNaviService({
            "type": component.get('v.isCommunity') ? "comm__namedPage" : "standard__namedPage",
            "attributes": {
                "name": "lsMSalesHome__c"
            }
        });
    }
});