/**
 * Created by ms on 2020-05-06.
 */

@IsTest
private class ActualSales_tr_ts {
    @IsTest
    static void testBehavior() {
        TestDataBaseFactory.init();

        ActualSales__c actualSales = TestDataBizFactory.baseActualSales.clone(false, true);
        actualSales.Division__c = '계획';

        TestDataBaseFactory.agencyAccount.ERPCode__c = actualSales.CustomerCode__c;
        update TestDataBaseFactory.agencyAccount;

        insert actualSales;
    }
}