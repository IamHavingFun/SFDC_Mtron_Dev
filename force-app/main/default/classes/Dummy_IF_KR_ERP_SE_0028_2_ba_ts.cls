/****************************************************************************************
  * @filename      : Dummy_IF_KR_ERP_SE_0028_2_ba_ts
  * @projectname   :
  * @author        : i2max_my.Seo
  * @date          : 2020-05-11 오후 5:13
  * @group         :
  * @group-content :
  * @description   :
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author            description
  * ===============================================================
    0.1     2020-05-11 오후 5:13     i2max_my.Seo         Create
****************************************************************************************/
@IsTest
private class Dummy_IF_KR_ERP_SE_0028_2_ba_ts {
	@IsTest
	static void testBehavior() {
		TestDataBaseFactory.init();
		TestDataDummyBatchFactory.init();
		//============================================================================
		// 필요시 Dummy 데이터 변경 및 추가
		//============================================================================
		IF_KR_ERP_SE_0003__c dummy1 = TestDataDummyBatchFactory.erpSe0003dummyDataProduct.clone(false, true);
		dummy1.ProductCode__c = null;

		IF_KR_ERP_SE_0003__c dummy2 = TestDataDummyBatchFactory.erpSe0003dummyDataProduct.clone(false, true);
		dummy2.ProductCode__c = '00000002';
		dummy2.MA_NORMAL_YN__c = 'Y';

		insert new List<IF_KR_ERP_SE_0003__c>{
				dummy1, dummy2
		};
		//============================================================================
		// 배치 실행
		//============================================================================\
		Database.executeBatch(new Dummy_IF_KR_ERP_SE_0028_2_ba(), 200);
	}
}