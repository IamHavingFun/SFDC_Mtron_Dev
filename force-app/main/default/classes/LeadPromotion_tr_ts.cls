/****************************************************************************************
 * @filename      : LeadPromotion_tr_ts
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
private class LeadPromotion_tr_ts {
    @IsTest
    static void testBehavior() {
        Lead newLead = TestDataSalesFactory.baseLead.clone(false, true);

        insert newLead;
    }
}