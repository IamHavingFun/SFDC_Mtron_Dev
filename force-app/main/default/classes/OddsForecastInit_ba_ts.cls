@IsTest
private class OddsForecastInit_ba_ts {
    @IsTest
    static void testBehavior() {
        TestDataOddsForecastFactory.init();
        Database.executeBatch(new OddsForecastInit_ba(System.today().addMonths(-1).toStartOfMonth()), 1);

        System.assertNotEquals(new OddsForecastInit_ba(), null);
    }
}