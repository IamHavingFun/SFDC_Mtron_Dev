@IsTest
private class OpportunityLossStageUpdateContract_sc_ts {
    @IsTest
    static void testBehavior() {
        OpportunityLossStageUpdateContract_sc.runSchedule();
        OpportunityLossStageUpdateContract_sc.abortSchedule();
    }
}