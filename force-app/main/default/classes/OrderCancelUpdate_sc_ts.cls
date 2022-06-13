@IsTest
private class OrderCancelUpdate_sc_ts {
    @IsTest
    static void testBehavior() {
        OrderCancelUpdate_sc.runSchedule();
        OrderCancelUpdate_sc.abortSchedule();
    }
}