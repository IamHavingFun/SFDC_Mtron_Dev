/****************************************************************************************
 * @filename      :
 * @projectname   :
 * @author        : i2max_Junseok.Kwon
 * @date          : 2020-03-30 오전 9:30
 * @group         :
 * @group-content :
 * @description   :
 * @tester        :
 * @reference     :
 * @copyright     : Copyright © I2max. All Rights Reserved.
 * @modification Log
 * =========================================================================
 * ver     date                    author                    description
 * =========================================================================
 0.1     2020-03-30 오전 9:30     i2max_Junseok.Kwon        Create
 ****************************************************************************************/

({
    //-------------------------------------------------------------
    // 초기화
    //-------------------------------------------------------------
    doInit : function(component, event, helper){

        helper.lacComService = component.find('lacComService');

        helper.apex(
            component, 'doInit', 'init', null
        ).then(function ({resData, response}) {
            component.set('v.dealerDataList', resData.dealerDataList);
            component.set('v.serviceDataList', resData.serviceDataList);
            component.set('v.targetList', resData.targetList);
            component.set('v.dealerAccount', resData.dealerAccount);
            component.set('v.isApproval', resData.isApproval);
            component.set('v.assetCount', resData.assetCount);
            component.set('v.totalIncentiveAmount', resData.totalIncentiveAmount);
            component.set('v.totalIncentiveRate', resData.totalIncentiveRate);
            component.set('v.processYearMonth', resData.processYearMonth);
            component.set('v.processDate', resData.processDate);
        }).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error, response);
        });
    },
    doApprove : function(component, event, helper){
        helper.apex(
            component, 'doApprove', 'approve', {'targetList' : component.get('v.targetList')}
        ).then(function ({resData, response}) {
            helper.gfn_toast('정상 승인 처리 되었습니다', 's');
            var approveButton = component.find('approveButton');
            approveButton.set('v.disabled',true);
        }).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error, response);
        });
    },

    /**
     * save.
     *
     * @param component
     * @param event
     * @param helper
     */
    doExcel : function (component, event, helper) {
        const processYearMonth = component.get('v.processYearMonth');
        helper.apex(
            component, 'doExcel', 'excelDownload', null
        ).then(function ({resData, response}) {
            var strFile = "data:application/excel;base64,"+resData;
            download(strFile, "판매장려지급_"+processYearMonth+".xls", "application/excel");
        }).catch(function ({error, response}) {
            helper.gfn_ApexErrorHandle(error, response);
        });

    },

});