/****************************************************************************************
  * @filename      : LsMSalesContractList_ts
  * @projectname   :
  * @author        : i2max_my.Seo
  * @date          : 2020-07-13 오후 12:58
  * @group         :
  * @group-content :
  * @description   : 
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author            description
  * ===============================================================
    0.1     2020-07-13 오후 12:58     i2max_my.Seo         Create
****************************************************************************************/
@IsTest
private class LsMSalesContractList_ts {
    @IsTest
    static void testBehavior() {
        lsMSalesContractList.search('{"name":"test"}', 10, 1);
    }
}