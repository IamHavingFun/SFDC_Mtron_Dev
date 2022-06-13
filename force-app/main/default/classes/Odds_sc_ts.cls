@IsTest
private class Odds_sc_ts {
    @IsTest
    static void testBehavior() {
        Odds_sc.runSchedule();
        Odds_sc.abortSchedule();
    }
}