/**
 * Created by MS on 2020-06-24.
 */
/****************************************************************************************
  * @filename      : lsMSalesPDICreateStep1Controller.js
  * @projectname   : LS_PS
  * @author        : MS
  * @date          : 2020-06-24 11 13
  * @group         :
  * @group-content :
  * @description   :
  * @tester        :
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                    author          description
  * ===============================================================
    0.1     2020-06-24 11 13       Park He         Create
****************************************************************************************/
({
    /**
     *
     * @param component
     * @param event
     * @param helper
     */
    doInit: function (component, event, helper) {
        const pdi = component.get('v.mobileStepVO.bizData.pdi');
        if($A.util.isEmpty(pdi)) {
            helper.gfn_toast('해당 계약건에 대한 PDI 데이터가 존재 하지 않습니다.', 'w');
            return;
        }
        if(component.get('v.mobileStepVO.bizData.isViewMode') == false){
            var options = [{'label': '예', 'value': 'true'},{'label': '아니요', 'value': 'false'}];
            component.set('v.options',options);
        }
    },

	/**
	 *
	 * @param component
	 * @param event
	 * @param helper
	 */
	doNextSelf: function (component, event, helper) {
	    console.log('step1에서 netx ::::: ' + JSON.stringify(component.get('v.mobileStepVO.bizData.pdi')));

		helper.fn_checkValid(component, helper) &&
		$A.enqueueAction(component.get('c.doNext'));

	},
	/**
     *
     * @param component
     * @param event
     * @param helper
     */
	gfn_getInputRadioCheckedList: function(component, event, helper){
         let targetValue = event.getSource().get('v.value');
         var myCheckList = component.find('mycheck');
         myCheckList.forEach(function(checkbox){
            checkbox.set('v.value', targetValue);
        });
    },
    doPreSelf: function (component, event, helper) {
        component.find('lacComService').doNaviService({
            "type": component.get('v.isCommunity') ? "comm__namedPage" : "standard__namedPage",
            "attributes": {
                "name": "lsMSalesContractRegister__c"
            },
            "state": {
                "recordId": component.get("v.mobileStepVO.bizData.contract.Id")
            }
        });
	},
});