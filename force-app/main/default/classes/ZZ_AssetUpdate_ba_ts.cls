/****************************************************************************************
  * @filename      : ZZ_AssetUpdate_ba_ts
  * @projectname   :
  * @author        : jy.kim
  * @date          : 2020-04-23
  * @group         :
  * @group-content :
  * @description   :
  * @tester        :
  * @reference     : WeeklyReport_ba
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2020-04-23         jy.kim          Create
****************************************************************************************/

@IsTest
private class ZZ_AssetUpdate_ba_ts {
	@IsTest
	static void testBehavior1() {
		ZZ_AssetUpdateForAR_ba.runTest();
	}

	@IsTest
	static void testBehavior2() {
		ZZ_AssetUpdateForCollect_ba.runTest();
	}

	@IsTest
	static void testBehavior3() {
		ZZ_AssetForARUpdate_ba.runTest();
	}

	@IsTest
	static void testBehavior4() {
		ZZ_AssetForCollectUpdate_ba.runTest();
	}

	@IsTest
	static void testBehavior5() {
		ZZ_AssetUpdate_ba.runTest();
	}

	@IsTest
	static void testBehavior6() {
		ZZ_OrderUpdate_ba.runTest();
	}
}