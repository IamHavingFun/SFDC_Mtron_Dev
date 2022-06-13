/****************************************************************************************
  * @filename      : GuideActionQuoteCheck_ba_ts
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
private class GuideActionQuoteCheck_ba_ts {
    @IsTest
    static void testBehavior() {
        Opportunity newOppty = TestDataSalesFactory.baseOpportunity.clone(false, true);
        newOppty.AccountId      = TestDataBaseFactory.personAccount.Id;
        newOppty.RecordTypeId   = TestDataUtilFactory.getRecordTypeId('Opportunity', 'PerFarCorp');

        insert newOppty;

        Quote__c newQuote = TestDataSalesFactory.baseQuote.clone(false, true);
        newQuote.Opportunity__c = newOppty.Id;

        insert newQuote;


        Test.setCreatedDate(newQuote.Id, TestDataUtilFactory.d.addDays(-8));

        Database.executeBatch(new GuideActionQuoteCheck_ba(), 1);
    }
}