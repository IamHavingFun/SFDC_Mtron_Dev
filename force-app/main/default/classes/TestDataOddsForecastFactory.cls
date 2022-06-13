/****************************************************************************************
  * @filename      : TestDataOddsForecastFactory
  * @projectname   : 
  * @author        : i2max
  * @date          : 2021-05-06
  * @group         : 
  * @group-content : 
  * @description   : 
  * @tester        : TestDataOddsForecastFactory_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2021-05-06         i2max          Create
****************************************************************************************/
@IsTest
public class TestDataOddsForecastFactory {

    public static void init() {}

    public static Odds__c createOdds(final Boolean isInsert) {
        Odds__c odds = new Odds__c();

        odds.Dealer__c = TestDataBaseFactory.businessOfficeAccount.Id;
        odds.Product__c = TestDataProductFactory.baseProduct2.Id;
        odds.BaseYearMonth__c = System.today().addMonths(-1).toStartOfMonth();
        odds.ConsultingCount__c = 0;
        odds.ConsultingLossCount__c = 0;
        odds.QuoteCount__c = 0;
        odds.QuoteLossCount__c = 0;
        odds.ContractCount__c = 0;
        odds.ContractLossCount__c = 0;
        odds.DeliveryCount__c = 0;
        odds.QuoteOddsRate__c = 0;
        odds.ContractOddsRate__c = 0;
        odds.DeliveryOddsRate__c = 0;
        odds.TotalCount__c = 0;
        odds.TotalOddsRate__c = 0;

        odds = setExternalKeyForOdds(odds);

        if(isInsert) insert odds;

        return odds;
    }

    public static Odds__c baseOdds {get;set;}

    static {
        baseOdds = createOdds(true);
    }

    public static Odds__c setExternalKeyForOdds(final Odds__c odds) {
        odds.ExternalKey__c = ((Datetime)odds.BaseYearMonth__c).format('yyyyMM') + '_' + odds.Dealer__c + '_' + odds.Product__c;
        return odds;
    }

    public static Forecast__c createForecast(final Boolean isInsert) {
        Forecast__c forecast = new Forecast__c();

        forecast.Dealer__c = baseOdds.Dealer__c;
        forecast.Product__c = baseOdds.Product__c;
        forecast.BaseYearMonth__c = baseOdds.BaseYearMonth__c.addMonths(1).toStartOfMonth();

        forecast = setExternalKeyForForecast(forecast);

        if(isInsert) insert forecast;

        return forecast;
    }

    public static Forecast__c baseForecast {get;set;}

    static {
        baseForecast = createForecast(true);
    }

    public static Forecast__c setExternalKeyForForecast(final Forecast__c forecast) {
        forecast.ExternalKey__c = ((Datetime)forecast.BaseYearMonth__c).format('yyyyMM') + '_' + forecast.Dealer__c + '_' + forecast.Product__c;
        return forecast;
    }


}