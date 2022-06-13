/****************************************************************************************
  * @filename      : OrderDeliverySeqUpdate_ba_ts
  * @author        : I2MAX
  * @date          : 2021-11-15
  * @group         :
  * @group-content :
  * @description   :
  * @reference     :
  * @release       : v1.0.0
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author        description
  * ===============================================================
    1.0     2021-11-15                  I2MAX.YR        Create
****************************************************************************************/


@IsTest
private class IF_KR_ERP_SE_0042_Service_ts {
	@IsTest
	static void testBehavior() {

		TestDataBaseFactory.init();
		TestDataSalesFactory.init();
		TestDataDummyBatchFactory.init();
		TestDataBizFactory.init();
		//============================================================================
		// 필요시 Dummy 데이터 변경 및 추가
		//============================================================================

		Account testBusinessAccount = TestDataBaseFactory.businessOfficeAccount.clone(false, true);
		testBusinessAccount.ERPCode__c = '71I';
		insert testBusinessAccount;

		Account testAccount = TestDataBaseFactory.agencyAccount.clone(false, true);
		testAccount.BusinessOffice__c = testBusinessAccount.Id;
		insert testAccount;

		List<IF_KR_ERP_SE_0042.INPUT_T_DATA> inputList = new List<IF_KR_ERP_SE_0042.INPUT_T_DATA>();
		IF_KR_ERP_SE_0042.INPUT_T_DATA inputTData = new IF_KR_ERP_SE_0042.INPUT_T_DATA();
		inputTData.CHARG        = TestDataSalesFactory.baseAsset.BatchNo__c;
		inputTData.KUNNR_FROM   = testAccount.ERPCode__c;
		inputTData.KUNNR_TO     = testAccount.ERPCode__c;
		inputTData.ZREASON      = '01';
		inputList.add(inputTData);

		try {
			IF_KR_ERP_SE_0042_Service.createDeliveryRecords(inputList);
		} catch (Exception e) {

		}
//		IF_KR_ERP_SE_0042_Service.runTest();
	}
	@IsTest
	static void testBehavior2() {

		TestDataBaseFactory.init();
		TestDataSalesFactory.init();
		TestDataDummyBatchFactory.init();
		TestDataBizFactory.init();
		//============================================================================
		// 필요시 Dummy 데이터 변경 및 추가
		//============================================================================

		Account testBusinessAccount = TestDataBaseFactory.businessOfficeAccount.clone(false, true);
		testBusinessAccount.ERPCode__c = '71I';
		insert testBusinessAccount;

		Account testAccount = TestDataBaseFactory.agencyAccount.clone(false, true);
		testAccount.BusinessOffice__c = testBusinessAccount.Id;
		insert testAccount;

		List<IF_KR_ERP_SE_0042.INPUT_T_DATA> inputList = new List<IF_KR_ERP_SE_0042.INPUT_T_DATA>();
		IF_KR_ERP_SE_0042.INPUT_T_DATA inputTData = new IF_KR_ERP_SE_0042.INPUT_T_DATA();
		inputTData.CHARG        = TestDataSalesFactory.baseAsset.BatchNo__c;
		inputTData.KUNNR_FROM   = testAccount.ERPCode__c;
		inputTData.KUNNR_TO     = testAccount.ERPCode__c;
		inputTData.ZREASON      = '03';
		inputList.add(inputTData);

		try {
			IF_KR_ERP_SE_0042_Service.createDeliveryRecords(inputList);
		} catch (Exception e) {

		}
	}
}