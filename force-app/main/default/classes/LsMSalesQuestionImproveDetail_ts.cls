/****************************************************************************************
 * @filename      : LsMSalesQuestionImproveDetail_ts
 * @projectname   : 
 * @author        : SEOKHO LEE
 * @date          : 2020-07-07 오전 11:19
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
 0.1     2020-07-07 오전 11:19        SEOKHO LEE          Create
 ****************************************************************************************/

@IsTest
private class LsMSalesQuestionImproveDetail_ts {
    @isTest
    static void testBehavior() {
        LsMSalesQuestionImproveDetail.WrapperData wrapperData = LsMSalesQuestionImproveDetail.init(TestDataBaseFactory.baseCase.Id);
        System.assertNotEquals(wrapperData.typeList, null);
        System.assertEquals(wrapperData.sitePathPrefix, null);

    }
}