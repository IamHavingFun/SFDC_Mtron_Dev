/****************************************************************************************
 * @filename      : PartnerHomeOpportunityList_ts
 * @projectname   : 
 * @author        : SEOKHO LEE
 * @date          : 2020-08-06 오전 8:31
 * @group         :
 * @group-content :
 * @description   :
 * @tester        :
 * @reference     :
 * @copyright     : Copyright © I2max. All Rights Reserved.
 * @modification Log
 * ===============================================================
 * ver     date                     author              description
 * ===============================================================
 0.1     2020-08-06 오전 8:31        SEOKHO LEE          Create
 ****************************************************************************************/

@IsTest
private class PartnerHomeOpportunityList_ts {
    @isTest
    static void testBehavior() {
        TestDataSalesFactory.init();
        PartnerHomeOpportunityList.init();
        PartnerHomeOpportunityList.getOpportunityList();
    }
}