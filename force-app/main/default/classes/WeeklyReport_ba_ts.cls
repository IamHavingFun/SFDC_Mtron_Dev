/****************************************************************************************
  * @filename      : WeeklyReport_ba_ts
  * @projectname   :
  * @author        : jy.kim
  * @date          : 2020-04-23
  * @group         :
  * @group-content :
  * @description   :
  * @tester        :
  * @reference     : WeeklyReport_ba
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2020-04-23         jy.kim          Create
****************************************************************************************/

@IsTest
private class WeeklyReport_ba_ts {
    @TestSetup
    static void setData() {
        Date BaseDate = Date.today();
        User user = [Select Id, toLabel(BusinessOffice__c), fm_BusinessOffice__c, Name FROM User WHERE BusinessOffice__c != null AND IsActive = true limit 1];

        List<Activity__c> activity_List = new List<Activity__c>();
        activity_List.add(new Activity__c(Date__c = BaseDate, OwnerId = user.Id, Subject__c = '시장동향입수', Division__c = '대동', IsWeeklyReport__c = true));
        activity_List.add(new Activity__c(Date__c = BaseDate, OwnerId = user.Id));
        activity_List.add(new Activity__c(Date__c = BaseDate, OwnerId = user.Id, Subject__c = '전시회업무', Division__c = '대동', IsWeeklyReport__c = true));
        insert activity_List;

        Event event = new Event(OwnerId = user.Id, StartDateTime = BaseDate.addDays(7), EndDateTime = BaseDate.addDays(7));
        insert event;
    }

    @IsTest
    static void testBehavior() {
        test.startTest();
        WeeklyReport_ba batch = new WeeklyReport_ba();
        Database.executeBatch(batch);
        WeeklyReport_ba batch2 = new WeeklyReport_ba('20200220');
        Database.executeBatch(batch2);
        test.stopTest();
    }
}