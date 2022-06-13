({
    /**
     * doInit 초기호출
     *
     * @param component
     * @param event
     * @param helper
     */
    doInit: function (component, event, helper) {
        helper.lacComService = component.find('lacComService');

        helper.apex(
            component, 'getShareSettingItems', 'getShareSettingItems', {
                'recordId': component.get('v.recordId'),
                'sObjectName': component.get('v.sObjectName')
            }
        ).then(function ({resData, response}) {
            component.set('v.resShareData', resData);
        }).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error, response);
        });
    },
    /**
     * doDelete 공개 범위 삭제
     *
     * @param component
     * @param event
     * @param helper
     */
    doDelete : function(component, event, helper){
         const ShareId = event.getSource().get("v.value");
         helper.apex(
             component, 'getShareSettingDelete', 'getShareSettingDelete', {
                 'recordId': component.get('v.recordId'),
                 'shareId': ShareId,
                 'sObjectName': component.get('v.sObjectName')
             }
         ).then(function ({resData, response}) {
             helper.gfn_toast($A.get("{!$Label.c.partnerShareDeleteMsg}"),'s');
             $A.get("e.force:refreshView").fire();
         }).catch(function ({error, response}) {
             helper.gfn_ApexErrorHandle(error, response);
         });
    },
    /**
     * doNaviService 상세 레코드 이동
     *
     * @param component
     * @param event
     * @param helper
     */
     doNaviService : function(component, event, helper) {
         const recordId = event.currentTarget.dataset.recordid;
         const recordType = event.currentTarget.dataset.recordtype;

         helper.lacComService.doNaviService({
             "type": "standard__recordPage",
             "attributes": {
                 "recordId": recordId,
                 "actionName": "view"
             }
         });
     },
     /**
      * doPopup 공개 범위 설정 Component Call
              *
              * @param component
              * @param event
              * @param helper
              */
     doPopup : function(component, event, helper) {
        helper.gfn_createComponent(component, 'noticeBoardPartnerShare',
            {
                'recordId' : component.get('v.recordId'),
                'sObjectName' : component.get('v.sObjectName'),
            }, 'slds-modal--large');
     }
});