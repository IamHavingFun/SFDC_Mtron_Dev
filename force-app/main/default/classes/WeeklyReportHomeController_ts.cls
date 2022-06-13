/****************************************************************************************
  * @filename      : WeeklyReportHomeController_ts
  * @projectname   :
  * @author        : jy.kim
  * @date          : 2020-04-23
  * @group         :
  * @group-content :
  * @description   :
  * @tester        :
  * @reference     : WeeklyReportHomeController
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2020-04-23         jy.kim          Create
****************************************************************************************/

@IsTest
private class WeeklyReportHomeController_ts {
    @TestSetup
    static void setData() {
        Date BaseDate = Date.today();
        Date thisWeekStartDate = BaseDate.toStartOfWeek().addDays(1); // 이번주 월요일
        Date lastWeekStartDate = thisWeekStartDate.addDays(-7);       // 저번주 월요일
        List<WeeklyReport__c> weeklyReport_List = new List<WeeklyReport__c>();
        weeklyReport_List.add(new WeeklyReport__c(Name = 'Test', ThisWeekStartDate__c = thisWeekStartDate));
        weeklyReport_List.add(new WeeklyReport__c(Name = 'Test', ThisWeekStartDate__c = lastWeekStartDate));
        insert weeklyReport_List;
    }

    @IsTest
    static void testBehavior() {
        WeeklyReportHomeController.getWeeklyReportList();
    }
}