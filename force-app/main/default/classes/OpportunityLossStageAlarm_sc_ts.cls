@IsTest
private class OpportunityLossStageAlarm_sc_ts {
    @IsTest
    static void testBehavior() {
        OpportunityLossStageAlarm_sc.runSchedule();
        OpportunityLossStageAlarm_sc.abortSchedule();
    }
}