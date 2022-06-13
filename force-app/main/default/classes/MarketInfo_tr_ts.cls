@IsTest
private class MarketInfo_tr_ts {
    @IsTest
    static void testBehavior() {
        TestDataBaseFactory.init();

        MarketInfo__c marketInfo = TestDataBizFactory.baseMarketInfo.clone(false, true);
        marketInfo.Division__c = '실적';

        insert marketInfo;
    }
}