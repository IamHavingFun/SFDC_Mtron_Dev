@IsTest
private class WeeklyReport_sc_ts {
    static testMethod void testBehavior() {
        Test.startTest();
        String cronExp = '0 0 0 5 10 ?';
        System.schedule('WeeklyReport_sc', cronExp, new WeeklyReport_sc());
        Test.stopTest();
    }
}