/****************************************************************************************
  * @filename      : LsMSalesOpptyDetail_ts
  * @projectname   :
  * @author        : i2max_my.Seo
  * @date          : 2020-08-05 오전 8:23
  * @group         :
  * @group-content :
  * @description   : 
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author            description
  * ===============================================================
    0.1     2020-08-05 오전 8:23     i2max_my.Seo         Create
****************************************************************************************/
@IsTest
private class LsMSalesOpptyDetail_ts {
    @IsTest
    static void testBehavior() {
        LsMSalesOpptyDetail.init(TestDataSalesFactory.baseOpportunity.Id);
    }
}