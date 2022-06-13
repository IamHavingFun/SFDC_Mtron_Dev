/****************************************************************************************
  * @filename      : GuideActionLeadConfirm_ba_ts
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
private class GuideActionLeadConfirm_ba_ts {
    @IsTest
    static void testBehavior() {
        TestDataBaseFactory.init();
        TestDataSalesFactory.init();

        User testUser = TestDataBaseFactory.agencyUser;
        Campaign testCampaign = TestDataSalesFactory.baseCampaign.clone(false, true);
        testCampaign.TestDriveOwner__c = testUser.Id;
        insert testCampaign;

        Lead testLoad = TestDataSalesFactory.baseLead.clone(false, true);
        testLoad.isTestDriveConfirmed__c = false;
        testLoad.TestDriveDate__c = null;
        testLoad.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('TestDrive').getRecordTypeId();
        testLoad.CampaignId__c = testCampaign.Id;
//        testLoad.CreatedDate = System.today().addDays(-5);
        insert testLoad;

        Test.setCreatedDate(testLoad.Id, System.today().addDays(-5));

        Database.executeBatch(new GuideActionLeadConfirm_ba(), 200);
    }
}