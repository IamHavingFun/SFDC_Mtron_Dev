trigger AddSalesIncentiveItem on AddSalesIncentiveItem__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new AddSalesIncentiveItem_tr().run();
}