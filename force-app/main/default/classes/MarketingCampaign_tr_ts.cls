/****************************************************************************************
  * @filename      : MarketingCampaign_tr_ts
  * @author        : I2MAX
  * @date          : 2021-03-11
  * @group         :
  * @group-content :
  * @description   : 
  * @reference     :
  * @release       : v1.0.0
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author         description
  * ===============================================================
    1.0     2021-03-11           I2MAX           Create
****************************************************************************************/
@IsTest
private class MarketingCampaign_tr_ts {
    @IsTest
    static void testBehavior() {
        //==============================================================================
        // Data Setting
        //==============================================================================
        MarketingCampaign__c marketingCampaign = new MarketingCampaign__c(
                StartDate__c = TestDataUtilFactory.d.addDays(7),
                EndDate__c = TestDataUtilFactory.d.addDays(30),
                Dealer__c = TestDataBaseFactory.agencyAccount.Id,
                CampaignName__c = 'TestMarketingCampaign'
        );

        //==============================================================================
        // Logic Test
        //==============================================================================
        Test.startTest();

        insert marketingCampaign;

        marketingCampaign.PlanBudget__c = 1000000;
        marketingCampaign.Status__c = '종료';
        marketingCampaign.ApprovalStatus__c = '승인';

        update marketingCampaign;

        Test.stopTest();
    }
}