/****************************************************************************************
  * @filename      : GuideActionContractPDICheck_ba_ts
  * @projectname   : LS_PS
  * @author        : Park HE
  * @date          : 2020-07-09
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
    0.1     2020-07-09             Park HE         Create
****************************************************************************************/

@IsTest
private class GuideActionContractPDICheck_ba_ts {
    @IsTest
    static void testBehavior() {
        TestDataBaseFactory.init();
        TestDataSalesFactory.init();

        Account testAccount = TestDataBaseFactory.businessOfficeAccount;
        Account testDealerAccount = TestDataBaseFactory.agencyAccount;
        testAccount.Dealer__c = testDealerAccount.Id;
        update testAccount;

        Opportunity testOpportunity = TestDataSalesFactory.baseOpportunity;
        testOpportunity.StageName = '인도';
        update testOpportunity;

        Contract__c testContract = TestDataSalesFactory.baseContract;
        testContract.Customer__c = testAccount.Id;
        testContract.Opportunity__c = testOpportunity.Id;
        testContract.RecordTypeId = Schema.SObjectType.Contract__c.getRecordTypeInfosByDeveloperName().get('PerFarCorp').getRecordTypeId();
        testContract.IsLWSRegistration__c = false;
        testContract.CustomerExpectedDate__c = TestDataUtilFactory.d.addDays(-60);
        update testContract;

        Database.executeBatch(new GuideActionContractPDICheck_ba(), 200);
    }
}