({
    /**
     * doInit 초기호출
     *
     * @param component
     * @param event
     * @param helper
     */
    doInit : function(component, event, helper) {
        helper.lacComService = component.find('lacComService');

        helper.apex(
            component, 'getWeeklyReportList', 'getWeeklyReportList', null
        ).then(function ({resData, response}) {
            component.set('v.wrapperClass', resData);
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
                 "objectApiName": recordType,
                 "actionName": "view"
             }
         });
     },
});