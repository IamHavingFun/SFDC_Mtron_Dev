/****************************************************************************************
 * @filename      : lsMSalesStepContainerBaseController.js
 * @projectname   :
 * @author        : i2max_my.Seo
 * @date          : 2020-06-05 오후 12:53
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
 0.1     2020-06-05 오후 12:53    i2max_my.Seo          Create
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
    }
});