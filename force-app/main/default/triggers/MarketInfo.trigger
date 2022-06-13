trigger MarketInfo on MarketInfo__c (before insert, after insert) {
    new MarketInfo_tr().run();
}