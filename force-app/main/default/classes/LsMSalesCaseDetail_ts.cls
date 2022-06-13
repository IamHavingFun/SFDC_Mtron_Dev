/****************************************************************************************
  * @filename      : LsMSalesCaseDetail_ts
  * @author        : i2max_my.Seo
  * @date          : 2020-11-27 오전 8:08
  * @group         :
  * @group-content :
  * @description   : 
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author            description
  * ===============================================================
    0.1     2020-11-27 오전 8:08     i2max_my.Seo         Create
****************************************************************************************/
@IsTest
private class LsMSalesCaseDetail_ts {
    @IsTest
    static void testBehavior() {
        LsMSalesCaseDetail.WrapperData wrapperData = LsMSalesCaseDetail.init(TestDataBaseFactory.baseNewCase.Id);
        System.assertNotEquals(wrapperData.typeList, null);
        System.assertEquals(wrapperData.sitePathPrefix, null);
    }
}