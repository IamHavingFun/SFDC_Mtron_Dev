@IsTest
private class OddsDelete_ba_ts {
    @IsTest
    static void testBehavior() {
        Odds__c odds = TestDataOddsForecastFactory.baseOdds.clone(false, true);
        odds.BaseYearMonth__c = odds.BaseYearMonth__c.addYears(-1);
        odds = TestDataOddsForecastFactory.setExternalKeyForOdds(odds);

        insert odds;

        Database.executeBatch(new OddsDelete_ba(System.today().toStartOfMonth()), 1);

        System.assertNotEquals(new OddsDelete_ba(), null);
    }
}