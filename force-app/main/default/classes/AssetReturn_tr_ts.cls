/****************************************************************************************
  * @filename      : AssetReturn_tr_ts
  * @projectname   : LS
  * @author        : Park JW
  * @date          : 2020-07-20 오후 2:23
  * @group         :
  * @group-content :
  * @description   :
  * @tester        :
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                      author          description
  * ===============================================================
    0.1     2020-07-20 오후 2:23           Park JW         Create
****************************************************************************************/

@IsTest
private class AssetReturn_tr_ts {
	@IsTest
	static void testBehavior() {

		TestDataBaseFactory.init();
		TestDataDummyBatchFactory.init();
		TestDataSalesFactory.init();

		Asset testAsset = TestDataSalesFactory.baseAsset.clone(false, true);
		testAsset.Name = 'Test1000';
		testAsset.Order__c = null;
		insert testAsset;

		AssetReturn__c ar = new AssetReturn__c();
		ar.Asset__c = testAsset.Id;
		ar.ApprovalStatus__c = '요청';
		ar.RequestUser__c = UserInfo.getUserId();
		ar.SalesOwner__c = UserInfo.getUserId();
		ar.SalesManager__c = UserInfo.getUserId();
		ar.ReturnType__c = '품질 문제';
		insert ar;

		ar.ApprovalStatus__c = '승인';
		update ar;

	}
}