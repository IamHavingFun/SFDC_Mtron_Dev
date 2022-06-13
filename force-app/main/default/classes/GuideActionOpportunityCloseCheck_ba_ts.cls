/****************************************************************************************
  * @filename      : GuideActionOpportunityCloseCheck_ba_ts
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
private class GuideActionOpportunityCloseCheck_ba_ts {
    @IsTest
    static void testBehavior() {
        Opportunity newOppty = TestDataSalesFactory.baseOpportunity.clone(false, true);
        newOppty.StageName          = '상담';
        newOppty.SystemStatus__c    = '상담';
        newOppty.RecordTypeId       = TestDataUtilFactory.getRecordTypeId('Opportunity', 'PerFarCorp');
        newOppty.ActivityCheck__c   = false;
        newOppty.AccountId          = TestDataBaseFactory.personAccount.Id;

        insert newOppty;

        Test.setCreatedDate(newOppty.Id, TestDataUtilFactory.d.addDays(-90));

        Database.executeBatch(new GuideActionOpportunityCloseCheck_ba(), 1);
    }
}