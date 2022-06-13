/****************************************************************************************
 * @filename      : LsMSalesWarrantyClaimCreate_ts
 * @projectname   :
 * @author        : SEOKHO LEE
 * @date          : 2020-07-15 오전 10:31
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
 0.1     2020-07-15 오전 10:31        SEOKHO LEE          Create
 ****************************************************************************************/

@IsTest
private class MobileAppVersionCheck_ts {
	@isTest
	static void testBehavior() {
		MobileAppVersionCheck apex = new MobileAppVersionCheck();
		System.debug(apex.appVersionJsonString);
	}
}