/****************************************************************************************
  * @filename      : ActualSalesDailyUpdate_ba_sc_ts
  * @projectname   :
  * @author        : i2max_my.Seo
  * @date          : 2020-08-19 오전 10:10
  * @group         :
  * @group-content :
  * @description   :
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author            description
  * ===============================================================
    0.1     2020-08-19 오전 10:10     i2max_my.Seo         Create
****************************************************************************************/
@IsTest
private class ActualSalesDailyUpdate_ba_sc_ts {
	@IsTest
	static void testBehavior() {
		ActualSalesDailyUpdate_ba_sc.runSchedule();
		ActualSalesDailyUpdate_ba_sc.abortSchedule();
		ActualSalesDailyUpdate_ba_sc.excuteBatch();
	}
}