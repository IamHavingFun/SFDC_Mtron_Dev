@IsTest
private class OddsForecastProcess_ba_ts {
    @IsTest
    static void testBehavior() {

        TestDataProductFactory.init();

        Opportunity opportunity1 = TestDataSalesFactory.baseOpportunity.clone(false, true);
        opportunity1.StageName = opportunity1.SystemStatus__c = '상담';
        opportunity1.Dealer__c = TestDataOddsForecastFactory.baseOdds.Dealer__c;
        opportunity1.InterestModel__c = TestDataOddsForecastFactory.baseOdds.Product__c;
        opportunity1.CustomerExpectedDate__c = opportunity1.CloseDate;
        opportunity1.DeliveryDate__c = opportunity1.CloseDate;

        Opportunity opportunity2 = opportunity1.clone(false, true);
        opportunity2.StageName = opportunity2.SystemStatus__c = '견적';

        Opportunity opportunity3 = opportunity1.clone(false, true);
        opportunity3.StageName = opportunity3.SystemStatus__c = '계약';

        Opportunity opportunity4 = opportunity1.clone(false, true);
        opportunity4.StageName = opportunity4.SystemStatus__c = '인도';

        insert new List<Opportunity> {
            opportunity1, opportunity2, opportunity3, opportunity4
        };

        Database.executeBatch(new OddsForecastProcess_ba(TestDataOddsForecastFactory.baseOdds.BaseYearMonth__c, 0), 1);

        System.assertNotEquals(new OddsForecastProcess_ba(), null);
    }

}