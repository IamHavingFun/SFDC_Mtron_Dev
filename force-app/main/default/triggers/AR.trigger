trigger AR on AR__c (before insert, after insert, before update, after update) {
    new AR_tr().run();
}