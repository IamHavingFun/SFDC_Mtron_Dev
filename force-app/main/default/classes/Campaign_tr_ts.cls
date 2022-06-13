/****************************************************************************************
  * @filename      : Campaign_tr_ts
  * @projectname   :
  * @author        : i2max_my.Seo
  * @date          : 2020-08-11 오후 1:22
  * @group         :
  * @group-content :
  * @description   : 
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author            description
  * ===============================================================
    0.1     2020-08-11 오후 1:22     i2max_my.Seo         Create
****************************************************************************************/
@IsTest
private class Campaign_tr_ts {
    @IsTest
    static void testBehavior() {
        TestDataSalesFactory.baseOpportunity.CampaignId = TestDataSalesFactory.baseCampaign.Id;

        update TestDataSalesFactory.baseOpportunity;

        TestDataSalesFactory.baseCampaign.TotalNumber__c     = 10;
        TestDataSalesFactory.baseCampaign.AssignNumber__c    = 10;

        update TestDataSalesFactory.baseCampaign;
    }
}