@IsTest
private class OrderCancelAlarm_sc_ts {
    @IsTest
    static void testBehavior() {
        OrderCancelAlarm_sc.runSchedule();
        OrderCancelAlarm_sc.abortSchedule();
    }
}