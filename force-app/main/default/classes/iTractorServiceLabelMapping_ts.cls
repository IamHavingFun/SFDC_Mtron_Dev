/**
 * Created by ms on 2021-11-16.
 */

@IsTest
private class iTractorServiceLabelMapping_ts {
    @IsTest
    static void testBehavior() {
        TriggerHandler.bypass('Account_tr');
        TriggerHandler.bypass('Asset_tr');
        TriggerHandler.bypass('i2SEMA_AutomaticNotification_tr');

        TestDataBaseFactory.init();
        TestDataSalesFactory.init();
        Account pa = TestDataBaseFactory.personAccount.clone(false, true);
        pa.PersonMobilePhone = '010-1111-2222';
        pa.RecordTypeId = TestDataUtilFactory.getRecordTypeId('Account', 'PersonAccount');
        System.debug(pa);
        insert pa;

        Asset testAsset = null;
        iTractorServiceUtil.validate(testAsset);

        testAsset = TestDataSalesFactory.baseAsset.clone(false, true);
        testAsset.Name = '96991542222';
        testAsset.AccountId = pa.id;
        testAsset.InventoryType__c = '실판매';
        insert testAsset;

        Asset soqlAst = [SELECT id, name, Customer__c,Account.Name, AccountID,isNHContact__c, Dealer__c, Account.PersonMobilePhone, Account.IsPersonAccount,  Customer__r.PersonMobilePhone, Product2Id , Product2.Name,
                Dealer__r.Name,
                Dealer__r.Mobile__c
        FROM Asset WHERE id = :testAsset.id];

        System.debug(soqlAst);
        iTractorServiceLabelMapping.Supplies1(soqlAst,'aaaa');
        iTractorServiceLabelMapping.Supplies2(soqlAst);
        iTractorServiceLabelMapping.Supplies3(soqlAst,'aaaaa','bbbbb');

        TriggerHandler.clearAllBypasses();
    }
}