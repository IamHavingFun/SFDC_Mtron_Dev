/**
 * Created by MS on 2020-07-31.
 */

@IsTest
private class Opportunity_tr_ts {
    @IsTest
    static void testBehavior() {
        Opportunity oppty = TestDataSalesFactory.baseOpportunity;
        update oppty;
    }
}