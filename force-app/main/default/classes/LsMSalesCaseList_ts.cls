/****************************************************************************************
  * @filename      : LsMSalesCaseList_ts
  * @author        : i2max_my.Seo
  * @date          : 2020-11-27 오전 8:05
  * @group         :
  * @group-content :
  * @description   : 
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author            description
  * ===============================================================
    0.1     2020-11-27 오전 8:05     i2max_my.Seo         Create
****************************************************************************************/
@IsTest
private class LsMSalesCaseList_ts {
    @IsTest
    static void testBehavior() {
        LsMSalesCaseList.getSearch('{"searchStatus":"Progress"}',1,1);
        LsMSalesCaseList.getSearch('{"searchStatus":"Completed"}',1,1);
    }
}