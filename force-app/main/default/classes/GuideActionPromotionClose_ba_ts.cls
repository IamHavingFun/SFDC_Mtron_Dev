/****************************************************************************************
  * @filename      : GuideActionPromotionClose_ba_ts
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
private class GuideActionPromotionClose_ba_ts {
    @IsTest
    static void testBehavior() {
        TestDataBaseFactory.init();
        TestDataSalesFactory.init();

        Account testBusinessAccount = TestDataBaseFactory.businessOfficeAccount;
        Account testAccount = TestDataBaseFactory.agencyAccount.clone(false, true);
        testAccount.BusinessOffice__c = testBusinessAccount.Id;
        insert testAccount;

        Campaign testCampaign = TestDataSalesFactory.baseCampaign.clone(false, true);
        testCampaign.RecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Promotion').getRecordTypeId();
        testCampaign.PublicYn__c = true;
        testCampaign.Status = '프로모션 종료';
        testCampaign.EndDate = Date.today().addDays(-1);
        insert testCampaign;
        System.debug('campid ==> ' + testCampaign.Id);
        Campaign testCampaign2 = TestDataSalesFactory.baseCampaign.clone(false, true);
        testCampaign2.RecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Promotion').getRecordTypeId();
        testCampaign2.PublicYn__c = false;
        insert testCampaign2;

        ShareSetting__c testShareSetting = new ShareSetting__c(Account__c = testAccount.Id, Campaign__c = testCampaign2.Id);
        insert testShareSetting;

        GuideActionPromotionClose_ba guideActionPromotionCloseBa = new GuideActionPromotionClose_ba();
        Database.executeBatch(new GuideActionPromotionClose_ba(), 50);
        Database.executeBatch(new GuideActionPromotionClose_ba(testCampaign.Id), 50);
        Database.executeBatch(new GuideActionPromotionClose_ba(testCampaign2.Id), 50);
    }
}