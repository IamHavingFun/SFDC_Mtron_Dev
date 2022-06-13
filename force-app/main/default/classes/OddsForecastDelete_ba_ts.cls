@IsTest
private class OddsForecastDelete_ba_ts {
    @IsTest
    static void testBehavior() {
        Forecast__c forecast = TestDataOddsForecastFactory.baseForecast.clone(false, true);
        forecast.BaseYearMonth__c = forecast.BaseYearMonth__c.addYears(-2);
        forecast = TestDataOddsForecastFactory.setExternalKeyForForecast(forecast);

        insert forecast;

        Database.executeBatch(new OddsForecastDelete_ba(System.today().toStartOfMonth()), 1);

        System.assertNotEquals(new OddsForecastDelete_ba(), null);

    }
}