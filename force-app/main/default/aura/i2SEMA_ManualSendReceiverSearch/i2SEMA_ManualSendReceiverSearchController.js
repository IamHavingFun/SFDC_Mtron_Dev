/****************************************************************************************
 * @filename       : i2SEMA_ManualSendReceiverSearchController.js
 * @projectname    : i2SEMA Core
 * @author         : i2max_byeon.jw
 * @date           : 2020-04-10 오전 8:54
 * @group          :
 * @group-content  :
 * @description    :
 * @copyright      : Copyright © I2max. All Rights Reserved.
 * @modification Log
 * ===============================================================
 * ver     date                author              description
 * ===============================================================
 0.1     2020-04-10 오전 8:54     i2max_byeon.jw       Create
 ****************************************************************************************/
({
    doInit : function(component,event,helper){
        // Base Initialize
        helper.gfn_baseInitialize(component,[])
            .then((returnData,response) => {
                // Component Initialize
                helper.apex(component
                    ,'doInit'
                    ,'initialize'
                    ,{
                        reqData : component.get('v.requestData')
                    })
                    .then((returnData,response)=>{
                        const data = returnData.data;
                        component.set('v.referenceData',data.referenceData);
                    })
                    .catch((error,response)=>{
                        helper.gfn_ApexErrorHandle(error,response);
                    });
            })
            .catch((error,response) => {
                helper.gfn_ApexErrorHandle(error,response);
            })
    },
    /**
     * @description 전체 선택
     */
    checkAllToggle : function(component,event,helper){
        let referenceData = component.get('v.referenceData');
        let checked = event.getSource().get('v.checked');

        helper.gfn_makeArray(referenceData.records).forEach( record => {
            // // [20.08.25] LS Mtron - 수신자 선택불가 옵션 추가
            if( record.disabled !== true ){
                record.selected = checked;
            }
        });
        component.set('v.referenceData',referenceData);
    },
    /**
     * @description 수신자 설정 이벤트
     */
    fireReceiverEvent : function(component,event,helper){
        let referenceData = component.get('v.referenceData');
        let selectedIds = helper.gfn_makeArray(referenceData.records).filter(record => {
            // // [20.08.25] LS Mtron - 수신자 선택불가 옵션 추가
            return record.selected === true && record.disabled !== true;
        }).map(selectedRecord => {
            return selectedRecord.Id;
        });

        let receiverEvent = component.getEvent('receiverEvent');
        receiverEvent.setParams({
            selectedIds : selectedIds
        });
        receiverEvent.fire();
    }
});