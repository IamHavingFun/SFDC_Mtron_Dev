/**
 * Created by MS on 2020-06-24.
 */
/****************************************************************************************
  * @filename      : lsMSalesPDICreateStep2Controller.js
  * @projectname   : LS_PS
  * @author        : MS
  * @date          : 2020-06-24 14 02
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
    0.1     2020-06-24 14 02       Park He         Create
****************************************************************************************/
({
    /**
     *
     * @param component
     * @param event
     * @param helper
     */
    doInit: function (component, event, helper) {
        if(component.get('v.mobileStepVO.bizData.isViewMode') == false){
            var options = [{'label': '예', 'value': 'true'},{'label': '아니요', 'value': 'false'}];
            component.set('v.options',options);
        }
    },
	/**
	 * Step 업무의 Self doNext
	 * 필수값등 valid 체크 로직 필요시 자체 구현
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
});