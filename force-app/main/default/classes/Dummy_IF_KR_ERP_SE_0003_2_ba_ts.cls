/****************************************************************************************
  * @filename      : Dummy_IF_KR_ERP_SE_0003_2_ba_ts
  * @projectname   :
  * @author        : i2max_my.Seo
  * @date          : 2020-05-11 오후 5:04
  * @group         :
  * @group-content :
  * @description   :
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author            description
  * ===============================================================
    0.1     2020-05-11 오후 5:04     i2max_my.Seo         Create
****************************************************************************************/
@IsTest
private class Dummy_IF_KR_ERP_SE_0003_2_ba_ts {
	@IsTest
	static void testBehavior() {
		TestDataBaseFactory.init();
		TestDataDummyBatchFactory.init();
		//============================================================================
		// 필요시 Dummy 데이터 변경 및 추가
		//============================================================================
		Product2 product = TestDataProductFactory.baseProduct2.clone(false, true);
		product.ProductCode = '000000000000000001';
		insert product;

		List<ProductPriceEntry__c> updateProductPriceEntries = new List<ProductPriceEntry__c>();
		updateProductPriceEntries.add(
				new ProductPriceEntry__c(
						ExternalID__c = product.ProductCode + '/' + 'FC' + '/' + Datetime.now().format('yyyy-MM-dd'),
						BasePrice__c  = 10000,
						PriceType__c  = 'FC',
						Product__c    = product.Id,
						StartDate__c  = Date.today(),
						EndDate__c    = Dummy_IF_BatchUtil.getIFDate('40001231')
				)
		);
		updateProductPriceEntries.add(
				new ProductPriceEntry__c(
						ExternalID__c = product.ProductCode + '/' + 'FD' + '/' + Datetime.now().format('yyyy-MM-dd'),
						BasePrice__c  = 10000,
						PriceType__c  = 'FD',
						Product__c    = product.Id,
						StartDate__c  = Date.today(),
						EndDate__c    = Dummy_IF_BatchUtil.getIFDate('40001231')
				)
		);
		updateProductPriceEntries.add(
				new ProductPriceEntry__c(
						ExternalID__c = product.ProductCode + '/' + 'FE' + '/' + Datetime.now().format('yyyy-MM-dd'),
						BasePrice__c  = 10000,
						PriceType__c  = 'FE',
						Product__c    = product.Id,
						StartDate__c  = Date.today(),
						EndDate__c    = Dummy_IF_BatchUtil.getIFDate('40001231')
				)
		);

		upsert updateProductPriceEntries ProductPriceEntry__c.ExternalID__c;

		//============================================================================
		// 배치 실행
		//============================================================================\
		Database.executeBatch(new Dummy_IF_KR_ERP_SE_0003_2_ba(), 200);
	}
}