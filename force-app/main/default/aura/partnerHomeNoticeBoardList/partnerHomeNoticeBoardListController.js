/****************************************************************************************
 * @filename      : partnerProfileInfo.js
 * @projectname   : LWC_I2MAX
 * @author        : i2max_my.Seo
 * @date          : 2020-03-10 오전 9:33
 * @group         :
 * @group-content :
 * @description   :
 * @tester        :
 * @reference     :
 * @copyright     : Copyright © I2max. All Rights Reserved.
 * @modification Log
 * ===============================================================
 * ver     date                     author              description
 * ===============================================================
 0.1     2020-03-10 오전 9:33     i2max_my.Seo          Create
 ****************************************************************************************/
({
    //-------------------------------------------------------------
    // 초기화
    //-------------------------------------------------------------
    doInit : function(component, event, helper){
        helper.apex(
            component, 'doInit', 'init', null
        ).then(function ({resData, response}) {
            // component.set('v.resData', resData);
            helper.fn_getNoticeBoardList(component, event, helper);
        }).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error, response);
        });
    },
    doNaviService : function(component, event, helper) {
        const recordId = event.currentTarget.dataset.recordid;
        component.find('lacComService').doNaviService({
            "type": "standard__recordPage",
            "attributes": {
                "recordId": recordId,
                "objectApiName": 'NoticeBoard__c',
                "actionName": "view"
            }
        });
    },

    /**
     * 공지사항 목록 화면으로.
     * @param component
     * @param event
     * @param helper
     */
    doViewAllPage : function(component, event, helper) {
        component.find('lacComService').doNaviService({
            "type": "standard__objectPage",
            "attributes": {
                "objectApiName": "NoticeBoard__c",
                    "actionName": "list"
            },
            "state": {
                "filterName": "00B1m000000S8BJEA0"
            }
        });
    }

});