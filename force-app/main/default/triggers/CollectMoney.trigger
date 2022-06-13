trigger CollectMoney on CollectMoney__c (before insert, after insert) {
    new CollectMoney_tr().run();
}