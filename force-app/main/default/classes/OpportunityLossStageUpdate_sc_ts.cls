@IsTest
private class OpportunityLossStageUpdate_sc_ts {
    @IsTest
    static void testBehavior() {
        OpportunityLossStageUpdate_sc.runSchedule();
        OpportunityLossStageUpdate_sc.abortSchedule();
    }
}