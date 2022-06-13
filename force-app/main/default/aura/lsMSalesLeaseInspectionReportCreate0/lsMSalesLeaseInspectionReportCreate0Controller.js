/****************************************************************************************
 * @filename      : lsMSalesLeaseInspectionReportCreate0Controller.js
 * @author        : I2MAX
 * @date          : 2021-03-29
 * @group         :
 * @group-content :
 * @description   :
 * @tester        :
 * @reference     :
 * @release       : v1.0.0
 * @copyright     : Copyright © I2max. All Rights Reserved.
 * @modification Log
 * ===============================================================
 * ver     date                    author         description
 * ===============================================================
 1.0     2021-03-29         I2MAX            Create
 ****************************************************************************************/
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
            component, 'doSearch', 'getLeaseInspectionReportData', {assetName:component.get('v.mobileStepVO.bizData.leaseInspectionReport.Asset__r.Name')}
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
                component.get('v.mobileStepVO.setData.targetContracts').some((record) => {
                    if(record.Id === recordId) {
                        //============================================================================
                        // 선택된 제품시리즈VO 세팅[유의]
                        //============================================================================
                        component.set('v.mobileStepVO.bizData.contract', record);
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

    doCancel: function (component, event, helper) {
        component.find('lacComService').doNaviService({
            "type": component.get('v.isCommunity') ? "comm__namedPage" : "standard__namedPage",
            "attributes": {
                "name": "lsMSalesHome__c"
            }
        });
    }
});