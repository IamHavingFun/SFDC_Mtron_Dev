trigger ActualSales on ActualSales__c (before insert, after insert) {
    new ActualSales_tr().run();
}