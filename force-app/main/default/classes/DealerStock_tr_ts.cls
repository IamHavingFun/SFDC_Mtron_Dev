/**
 * Created by ms on 2020-05-06.
 */

@IsTest
private class DealerStock_tr_ts {
    @IsTest
    static void testBehavior() {
        TestDataBaseFactory.init();

        DealerStock__c dealerStock = TestDataBizFactory.baseDealerStock.clone(false, true);
        dealerStock.Division__c = '계획';

        TestDataBaseFactory.agencyAccount.ERPCode__c = dealerStock.CustomerCode__c;
        update TestDataBaseFactory.agencyAccount;

        insert dealerStock;
    }
}