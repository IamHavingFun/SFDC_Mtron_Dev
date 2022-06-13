/****************************************************************************************
  * @filename      : lsMSalesCreateNewOpptyQa_ts
  * @projectname   : LS
  * @author        : Park JW
  * @date          : 2020-08-06 오후 2:17
  * @group         :
  * @group-content :
  * @description   :
  * @tester        :
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                      author          description
  * ===============================================================
    0.1     2020-08-06 오후 2:17           Park JW         Create
****************************************************************************************/

@IsTest
private class lsMSalesCreateNewOpptyQa_ts {
    @IsTest
    static void testBehavior() {
        TestDataBaseFactory.init();
        // TestDataSalesFactory배포시 에러남
        //TestDataSalesFactory.init();

        //Lead testLead = TestDataSalesFactory.baseLead;

        Campaign campaign = new Campaign();
        campaign.Name = 'test Campaign';
        campaign.TestDriveOwner__c = TestDataBaseFactory.agencyUser.Id;
        insert campaign;

        Lead testLead = new Lead();
        testLead.LastName       = 'testing';
        testLead.WebApex__c     = true;
        testLead.Dealer__c      = TestDataBaseFactory.agencyAccount.Id;
        testLead.MobilePhone    = '010-0000-0002';
        testLead.CampaignId__c  = campaign.Id;
        testLead.Status         = '시승예약';
        insert testLead;

        lsMSalesCreateNewOpptyQa.init(testLead.Id);
        try {
            lsMSalesCreateNewOpptyQa.init(testLead.Id);
        } catch(Exception e){
            System.debug('error : ' + e.getMessage());
            Boolean expectedExceptionThrown = e.getMessage().contains('Script-thrown exception') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }
    }
}