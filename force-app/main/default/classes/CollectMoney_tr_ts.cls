/**
 * Created by ms on 2020-05-06.
 */

@IsTest
private class CollectMoney_tr_ts {
    @IsTest
    static void testBehavior() {
        TestDataBaseFactory.init();

        CollectMoney__c collectMoney = TestDataBizFactory.baseCollectMoney.clone(false, true);
        collectMoney.Division__c = '계획';

        TestDataBaseFactory.agencyAccount.ERPCode__c = collectMoney.CustomerCode__c;
        update TestDataBaseFactory.agencyAccount;

        insert collectMoney;
    }
}