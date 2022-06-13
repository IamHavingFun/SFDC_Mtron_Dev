/****************************************************************************************
  * @filename      : GuideActionContractSelfPayCheck_ba_ts
  * @projectname   : LS_PS
  * @author        : Park HE
  * @date          : 2020-07-17
  * @group         :
  * @group-content :
  * @description   :
  * @tester        :
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                    author          description
  * ===============================================================
    0.1     2020-07-17             Park HE         Create
****************************************************************************************/

@IsTest
private class GuideActionContractSelfPayCheck_ba_ts {
    @IsTest
    static void testBehavior() {
        TestDataBaseFactory.init();
        TestDataSalesFactory.init();

        Account testAccount = TestDataBaseFactory.businessOfficeAccount;
        Account testDealerAccount = TestDataBaseFactory.agencyAccount;
        testAccount.Dealer__c = testDealerAccount.Id;
        update testAccount;

        Opportunity testOpportunity = TestDataSalesFactory.baseOpportunity;
        testOpportunity.StageName = '계약';
        update testOpportunity;

        Contract__c testContract = TestDataSalesFactory.baseContract;
        testContract.SelfPayCollectDueDate__c = TestDataUtilFactory.d.addDays(-45);
        testContract.SelfPayContractAmt__c = 1000;
        testContract.SelfPayCollectAmt__c = 500;
        testContract.CustomerExpectedDate__c = TestDataUtilFactory.d;
        testContract.Customer__c = testAccount.Id;
        testContract.Opportunity__c = testOpportunity.Id;
        testContract.RecordTypeId = Schema.SObjectType.Contract__c.getRecordTypeInfosByDeveloperName().get('PerFarCorp').getRecordTypeId();
        update testContract;

        Database.executeBatch(new GuideActionContractSelfPayCheck_ba(), 200);
    }
}