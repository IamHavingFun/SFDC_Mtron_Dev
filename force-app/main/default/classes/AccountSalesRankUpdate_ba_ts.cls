/****************************************************************************************
  * @filename      : AccountSalesRankUpdate_ba_ts
  * @projectname   :
  * @author        : i2max_my.Seo
  * @date          : 2020-08-18 오전 9:41
  * @group         :
  * @group-content :
  * @description   : 
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author            description
  * ===============================================================
    0.1     2020-08-18 오전 9:41     i2max_my.Seo         Create
****************************************************************************************/
@IsTest
private class AccountSalesRankUpdate_ba_ts {
    @IsTest
    static void testBehavior() {
        TestDataBaseFactory.init();

        Database.executeBatch(new AccountSalesRankUpdate_ba(), 200);
    }
}