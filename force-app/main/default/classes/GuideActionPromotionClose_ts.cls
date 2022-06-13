/****************************************************************************************
  * @filename      : GuideActionPromotionClose_ts
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
private class GuideActionPromotionClose_ts {
    @IsTest
    static void testBehavior() {
        TestDataSalesFactory.init();
        Campaign campaign = TestDataSalesFactory.baseCampaign;
        campaign.IsActive = true;

        update campaign;

        GuideActionPromotionClose.init(campaign.Id);
        GuideActionPromotionClose.setPromotionClose(campaign.Id);

        campaign.Status ='프로모션 완료';
        update campaign;
        GuideActionPromotionClose.init(campaign.Id);
    }
}