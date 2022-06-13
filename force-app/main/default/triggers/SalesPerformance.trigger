trigger SalesPerformance on SalesPerformance__c (before insert, after insert) {
    new SalesPerformance_tr().run();
}