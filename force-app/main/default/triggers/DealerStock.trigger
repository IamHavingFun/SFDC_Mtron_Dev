trigger DealerStock on DealerStock__c (before insert, after insert) {
    new DealerStock_tr().run();
}