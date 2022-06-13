/****************************************************************************************
 * @filename      : lsMSalesHomeController.js
 * @projectname   :
 * @author        : SEOKHO LEE
 * @date          : 2020-06-30 오전 11:01
 * @group         :
 * @group-content :
 * @description   : [모바일] 홈
 * @tester        :
 * @reference     :
 * @copyright     : Copyright © I2max. All Rights Reserved.
 * @modification Log
 * ===============================================================
 * ver     date                     author              description
 * ===============================================================
 0.1     2020-06-30 오전 11:01      SEOKHO LEE          Create
 ****************************************************************************************/
({
    /**
     * init
     * @param component
     * @param event
     * @param helper
     */
    doInit: function (component, event, helper) {
        component.set('v.todayDate', helper.gfn_date(component.get('v.todayDate')));
        helper.apex(
            component, 'doInit', 'init', {}
        ).then(function ({resData, response}) {
            component.set('v.loginUser', resData);
            $A.enqueueAction(component.get('c.doGuideCount'));
        }).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error, response);
        });
    },
    /**
     * doGuideCount
     * @param component
     * @param event
     * @param helper
     */
    doGuideCount: function (component, event, helper) {
        helper.apex(
            component, 'doGuideCount', 'getGuideCount', {}
        ).then(function ({resData, response}) {
            component.set('v.guideCount', resData);
        }).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error, response);
        });
    },
    /**
     * 가이드 목록 페이지
     * @param component
     * @param event
     * @param helper
     */
    doGuideList : function (component, event, helper) {
        component.find('lacComService').doNaviService({
            "type": component.get('v.isCommunity') ? "comm__namedPage" : "standard__namedPage",
            "attributes": {
                "name": event.currentTarget.dataset.url
            }
        })
    },
    /**
     * 해당 URL에 해당하는 페이지 이동
     * @param component
     * @param event
     * @param helper
     */
    doMappingPage : function (component, event, helper) {
        component.find('lacComService').doNaviService({
        "type": component.get('v.isCommunity') ? "comm__namedPage" : "standard__namedPage",
        "attributes": {
            "name": event.currentTarget.dataset.url
            }
         })
    },
})