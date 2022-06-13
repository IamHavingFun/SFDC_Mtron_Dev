/**
 * Created by I2MAX on 2022-04-05.
 */

@IsTest
private class AddSalesIncentiveItem_tr_ts {
    @IsTest
    static void testBehavior() {
        TestDataSalesFactory.init();

        AddSalesIncentive__c asi = new AddSalesIncentive__c();
        asi.Dealer__c = TestDataSalesFactory.baseAsset.Dealer__c;
        asi.Type__c = '사양차액지원';
        asi.Product__c = TestDataSalesFactory.baseAsset.Product2Id;
        asi.ApprovalStatus__c = '승인';
        asi.AddRate__c = 5;
        asi.LimitCount__c = 1;
        asi.Subject__c = 'TEST';
        insert asi;

        AddSalesIncentiveItem__c asii = new AddSalesIncentiveItem__c();
        asii.AddSalesIncentive__c = asi.Id;
        asii.Asset__c = TestDataSalesFactory.baseAsset.Id;
        insert asii;

        AddSalesIncentiveItem__c asiiCheck = asii.clone(false, false);
        try {
            insert asiiCheck;
        } catch (Exception e) {

        }

    }
}