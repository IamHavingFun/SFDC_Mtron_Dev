/****************************************************************************************
 * @filename      : PromotionController_ts
 * @projectname   :
 * @author        : i2max_my.Seo
 * @date          : 2020-07-09 오후 02:04
 * @group         :
 * @group-content :
 * @description   :
 * @tester        :
 * @reference     :
 * @copyright     : Copyright ⓒ I2max. All Rights Reserved.
 * @modification Log
 * ===============================================================
 * ver     date                     author              description
 * ===============================================================
 0.1     2020-07-09 오후 02:04      i2max_my.Seo         Create
 ****************************************************************************************/

@IsTest
private class PromotionController_ts {
    @IsTest
    static void testBehavior() {
        TestDataBaseFactory.init();
        TestDataSalesFactory.init();
        TestDataBizFactory.init();

        DealerArea__c da = TestDataBizFactory.baseDealerArea;
        da.State__c = '경기';
        update da;

        Campaign campaign = TestDataSalesFactory.baseCampaign;
        campaign.IsActive = true;
        campaign.TestDriveDueDate__c = TestDataUtilFactory.d;
        campaign.StartDate = TestDataUtilFactory.d.addDays(7);
        campaign.EndDate = TestDataUtilFactory.d.addDays(14);
        campaign.PublicYn__c = true;
        campaign.ProductId__c = TestDataProductFactory.baseProduct2.Id;
        campaign.TestDriveStartTime__c = '09:00';
        update campaign;
        ///////////////////////////////////////////////////////////////////////////
        PromotionController old_pc = new PromotionController();
        ///////////////////////////////////////////////////////////////////////////
        ApexPages.currentPage().getParameters().put('campaignId', TestDataSalesFactory.baseCampaign.Id);
        PromotionController pc = new PromotionController();
        ///////////////////////////////////////////////////////////////////////////
        Campaign campaign2 = campaign.clone(false, true);
        campaign2.PublicYn__c = false;
        insert campaign2;

        ShareSetting__c setting = new ShareSetting__c();
        setting.Account__c = TestDataBaseFactory.agencyAccount.Id;
        setting.Campaign__c = campaign2.Id;
        insert setting;

        ApexPages.currentPage().getParameters().put('campaignId', campaign2.Id);
        PromotionController pc3 = new PromotionController();
        ///////////////////////////////////////////////////////////////////////////
        
        System.assertEquals(pc.infoCUPI_T, null);
        System.assertEquals(pc.infoReceiveSM_T, null);
        System.assertEquals(pc.infoCUPIThirdParty_T, null);

        pc.soStateV = '경기';
        pc.doChangeState();

        pc.doChangeArea();

        pc.soDealerV = '선택';
        pc.doChangeDealer();
        pc.soDealerV = TestDataBaseFactory.agencyAccount.Id;
        pc.doChangeDealer();

        pc.soRequestDate = '2020. 01. 01.';
        pc.soRequestTime = '09:00';
        RecordType rt = [
                SELECT  Id
                FROM RecordType
                WHERE SobjectType = 'Lead' AND IsActive = TRUE AND DeveloperName = 'Promotion'
        ];
        pc.infoName = 'test';
        pc.infoTel = '010-1111-1111';
        Lead l = TestDataSalesFactory.baseLead;
        l.RecordTypeId = rt.Id;
        update l;
        pc.promotionSave();

    }
}