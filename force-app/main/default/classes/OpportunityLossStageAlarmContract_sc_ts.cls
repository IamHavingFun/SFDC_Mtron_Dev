@IsTest
private class OpportunityLossStageAlarmContract_sc_ts {
    @IsTest
    static void testBehavior() {
        OpportunityLossStageAlarmContract_sc.runSchedule();
        OpportunityLossStageAlarmContract_sc.abortSchedule();
    }
}