/****************************************************************************************
  * @filename      : GuideActionPromotionCreate_ba_ts
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
private class GuideActionPromotionCreate_ba_ts {
    @IsTest
    static void testBehavior() {
        TestDataBaseFactory.init();
        TestDataSalesFactory.init();

        Account testBusinessAccount = TestDataBaseFactory.businessOfficeAccount;
        Account testAccount = TestDataBaseFactory.agencyAccount.clone(false, true);
        testAccount.BusinessOffice__c = testBusinessAccount.Id;
        insert testAccount;

        Campaign testCampaign2 = TestDataSalesFactory.baseCampaign.clone(false, true);
        testCampaign2.RecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Promotion').getRecordTypeId();
        testCampaign2.PublicYn__c = false;
        testCampaign2.StartDate = TestDataUtilFactory.d;
        testCampaign2.IsActive = true;
        insert testCampaign2;

        Database.executeBatch(new GuideActionPromotionCreate_ba(), 200);

        Campaign testCampaign = TestDataSalesFactory.baseCampaign.clone(false, true);
        testCampaign.RecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Promotion').getRecordTypeId();
        testCampaign.PublicYn__c = true;
        testCampaign.StartDate = TestDataUtilFactory.d;
        testCampaign.IsActive = true;
        insert testCampaign;

        ShareSetting__c testShareSetting = new ShareSetting__c(Account__c = testAccount.Id, Campaign__c = testCampaign2.Id);
        insert testShareSetting;

        Database.executeBatch(new GuideActionPromotionCreate_ba(), 200);
    }
}