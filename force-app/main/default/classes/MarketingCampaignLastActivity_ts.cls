/****************************************************************************************
  * @filename      : MarketingCampaignLastActivity_ts
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
private class MarketingCampaignLastActivity_ts {
    @IsTest
    static void testBehavior() {
        //==============================================================================
        // Data Setting
        //==============================================================================
        MarketingCampaign__c marketingCampaign = new MarketingCampaign__c(
                StartDate__c = TestDataUtilFactory.d.addDays(-7),
                EndDate__c = TestDataUtilFactory.d.addDays(30),
                Dealer__c = TestDataBaseFactory.agencyAccount.Id,
                CampaignName__c = 'TestMarketingCampaign'
        );

        insert marketingCampaign;

        //==============================================================================
        // Logic Test
        //==============================================================================
        System.assertNotEquals(null, MarketingCampaignLastActivityController.init(marketingCampaign.Id));
    }
}