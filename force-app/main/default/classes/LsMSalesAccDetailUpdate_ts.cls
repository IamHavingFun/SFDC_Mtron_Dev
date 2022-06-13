/****************************************************************************************
 * @filename      : LsMSalesAccDetailUpdate_ts
 * @projectname   :
 * @author        : i2max.seo
 * @date          : 2020-07-07 오전 11:27
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
 0.1     2020-07-07 오전 11:27      i2max.seo          Create
 ****************************************************************************************/

@IsTest
private class  LsMSalesAccDetailUpdate_ts{
	@IsTest
	static void testBehavior() {
		Boolean isValid = LsMSalesAccDetailUpdate.checkDate('2020-02-01');
		Boolean isValid2 = LsMSalesAccDetailUpdate.checkDate('2020-02-31');
	}
}