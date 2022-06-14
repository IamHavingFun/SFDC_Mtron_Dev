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
    @IsTest
    static void testBehavior2() {
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

        Asset asset = new Asset();
        asset.Name              = '1234567891';
        asset.BatchNo__c        = '1234567891';
        asset.Product2Id        = TestDataProductFactory.baseProduct2.Id;
        asset.Contract__c       = TestDataSalesFactory.baseContract.Id;
        asset.Dealer__c         = TestDataBaseFactory.agencyAccount.Id;
        asset.AccountId         = TestDataBaseFactory.governmentOrNHAccount.Id;
        asset.InventoryType__c  = '대리점재고';
        asset.Product2          = TestDataProductFactory.baseProduct2;
        insert asset;

        AddSalesIncentiveItem__c asiiCheck = asii.clone(false, false);
        try {
            asiiCheck.Asset__c = asset.Id;
            insert asiiCheck;
        } catch (Exception e) {

        }

    }
}