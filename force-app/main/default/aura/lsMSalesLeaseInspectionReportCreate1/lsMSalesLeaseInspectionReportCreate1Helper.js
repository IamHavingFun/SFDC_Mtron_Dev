/****************************************************************************************
 * @filename      : lsMSalesLeaseInspectionReportCreate1Helper.js
 * @author        : I2MAX
 * @date          : 2021-04-15
 * @group         :
 * @group-content :
 * @description   :
 * @tester        :
 * @reference     :
 * @release       : v1.0.0
 * @copyright     : Copyright © I2max. All Rights Reserved.
 * @modification Log
 * ===============================================================
 * ver     date                    author        description
 * ===============================================================
 0.1     2021-04-15         I2MAX          Create
 ****************************************************************************************/
({
    fn_validCheck: function (component) {
        const leaseInspectionReport = component.get('v.mobileStepVO.bizData.leaseInspectionReport');

        //================================================================================================================
        // 리스 물건
        //================================================================================================================
        // 검사구분
        if($A.util.isEmpty(leaseInspectionReport.InspectionType__c)) {
            return false;
        }

        //================================================================================================================
        // 검수내용
        //================================================================================================================
        if($A.util.isEmpty(leaseInspectionReport.IsHandOver__c)) {
            return false;
        }
        if($A.util.isEmpty(leaseInspectionReport.IsCorrect__c)) {
            return false;
        }
        if($A.util.isEmpty(leaseInspectionReport.IsStored__c)) {
            return false;
        }
        if($A.util.isEmpty(leaseInspectionReport.IsLeaseChecked__c)) {
            return false;
        }

        //================================================================================================================
        // 리스물건 상태
        //================================================================================================================
        // 외부 상태
        if($A.util.isEmpty(leaseInspectionReport.ExternalStatus__c)) {
            return false;
        }
        // 내부 상태
        if($A.util.isEmpty(leaseInspectionReport.InternalStatus__c)) {
            return false;
        }
        // 전체적인 상태
        if($A.util.isEmpty(leaseInspectionReport.WholeStatus__c)) {
            return false;
        }

        return true;
    },
});