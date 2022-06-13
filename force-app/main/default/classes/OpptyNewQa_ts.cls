/****************************************************************************************
  * @filename      : OpptyNewQa_ts
  * @projectname   :
  * @author        : i2max_my.Seo
  * @date          : 2020-07-17 오전 10:22
  * @group         :
  * @group-content :
  * @description   : 
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author            description
  * ===============================================================
    0.1     2020-07-17 오전 10:22     i2max_my.Seo         Create
****************************************************************************************/
@IsTest
private class OpptyNewQa_ts {
    @IsTest
    static void testBehavior() {
        System.assertNotEquals(OpptyNewQa.save(TestDataSalesFactory.baseOpportunity.clone(false, true)), null);
    }
}