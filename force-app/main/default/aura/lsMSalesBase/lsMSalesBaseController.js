/****************************************************************************************
 * @filename      : lsMSalesBaseController.js
 * @projectname   :
 * @author        : i2max_my.Seo
 * @date          : 2020-06-05 오후 1:46
 * @group         :
 * @group-content :
 * @description   :
 * @tester        :
 * @reference     :
 * @copyright     : Copyright © I2max. All Rights Reserved.
 * @modification Log
 * ===============================================================
 * ver     date                    author              description
 * ===============================================================
 0.1     2020-06-05 오후 1:46    i2max_my.Seo          Create
 ****************************************************************************************/
({
    /**
     * current user의 LDS 레코드 데이터의 변경시 적용
     * @param component
     * @param event
     * @param helper
     */
    doRecordUpdated: function (component, event, helper) {
        let changeType = event.getParams().changeType;
        if (changeType === "CHANGED") {
            component.find("currentUserLoader").reloadRecord();
        }
    },

    /**
     * 테이블에 데이터 Append시 사용
     * @param component
     * @param event
     * @param helper
     */
    util_Load : function(component, event, helper) {
        const message = event.getParam("message");
        const oldData = component.get("v.recordList");

        //-------------------------------------------------------------
        // 이벤트 메시지 로깅
        //-------------------------------------------------------------
        helper.gfn_log(component, 'util_Load: message : ', message);

        //-------------------------------------------------------------
        // Server Apex의 Method를 search 로 고정
        //-------------------------------------------------------------
        helper.apex(component, 'util_Load', message.apexCallMethodName, {
            // message의 searchTerm 을 reqData key로 사용
            'reqData' : JSON.stringify(message.searchTerm),
            'pageSize' : message.pageSize,
            'pageNumber' : message.pageNumber
        },null,true).then(function ({resData, response}) {
            // resData 전체 세팅
            component.set("v.resData", resData);
            // resData의 recordList만 세팅
            if($A.util.isEmpty(resData.recordList)){
                component.set("v.recordList", resData);
                helper.gfn_callPageFrame(component, resData);
            }
            else {
                component.set("v.recordList", oldData.concat(resData.recordList));
                helper.gfn_callPageFrame(component, resData.recordList, resData.totalSize);
            }
        }).catch(function({error, response}){
            helper.gfn_ApexErrorHandle(error, response);
        });
    },

    /**
     * 금액 입력 받을때 keydown으로 0만 있는 경우 0을 제거 해준다.
     * 수정일 : 2020/09/14
     * 요청자 : 최희웅
     * 관련 ITVOC : https://lsmtron.lightning.force.com/lightning/r/ITVOC__c/a0s2w000000ZPUuAAO/view
     *
     * @param component
     * @param event
     * @param helper
     */
    doInputFocusNumber : function (component, event, helper) {
        const cmp = event.getSource();
        const amtValue = cmp.get('v.value');
        if(amtValue === 0 || amtValue === '0') {
            cmp.set('v.value', '');
        }
    },
    /**
     * 금액 입력 받을때 keydown으로 0만 있는 경우 0을 제거 해준다.
     * 수정일 : 2020/09/14
     * 요청자 : 최희웅
     * 관련 ITVOC : https://lsmtron.lightning.force.com/lightning/r/ITVOC__c/a0s2w000000ZPUuAAO/view
     *
     * @param component
     * @param event
     * @param helper
     */
    doInputBlurNumber : function (component, event, helper) {
        const cmp = event.getSource();
        const amtValue = cmp.get('v.value');
        // console.log('amtValue ==> ' + amtValue);
        if($A.util.isEmpty(amtValue) || amtValue === 0 || amtValue === '0') {
            cmp.set('v.value', '0');
        }
    },
});