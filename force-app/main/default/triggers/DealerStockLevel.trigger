/**
 * Created by MS on 2020-07-22.
 */

trigger DealerStockLevel on DealerStockLevel__c (before insert, after insert) {
    new DealerStockLevel_tr().run();
}