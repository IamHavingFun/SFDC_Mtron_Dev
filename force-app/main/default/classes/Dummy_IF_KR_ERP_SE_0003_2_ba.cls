/****************************************************************************************
  * @filename      : Dummy_IF_KR_ERP_SE_0003_2_ba
  * @projectname   :
  * @author        : i2max
  * @date          : 2020-05-11
  * @group         :
  * @group-content :
  * @description   : [자재-가격정보 - 실제품에 유효일자 기준 가격 업데이트]
  *                : ProductPriceEntry__c -> Product : update
  * @tester        : Dummy_IF_KR_ERP_SE_0003_ba_ts.cls
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2020-05-11      i2max          Create
*************a***************************************************************************/

public with sharing class Dummy_IF_KR_ERP_SE_0003_2_ba extends Dummy_IF_Batch{

	public String query;
	public Boolean isNextBatch = true;

	public Dummy_IF_KR_ERP_SE_0003_2_ba() {
		this(null);
	}

	public Dummy_IF_KR_ERP_SE_0003_2_ba(final String query) {
		this(query, true);
	}

	public Dummy_IF_KR_ERP_SE_0003_2_ba(final String query, final Boolean isNextBatch) {
		this.query = query;
		this.isNextBatch = isNextBatch;
	}

	/**
		 * Start
		 *
		 * @param BC : BatchableContext
		 *
		 * @return Database.QueryLocator
		 */
	public override Database.QueryLocator start(Database.BatchableContext BC) {

		//============================================================================
		// 후행 Dummy 데이터 삭제 배치 정보
		//============================================================================
		this.interfaceId = 'IF_KR_ERP_SE_0003_2';

		if(String.isNotBlank(this.query)) {
			return Database.getQueryLocator(this.query);
		} else {
			return Database.getQueryLocator([
					SELECT
							Id,
							Name,
							BasePrice__c,
							ExternalID__c,
							PriceType__c,
							Product__c,
							Product__r.DealerListPrice__c,
							Product__r.GovListPrice__c,
							Product__r.NhListPrice__c,
							StartDate__c,
							EndDate__c
					FROM ProductPriceEntry__c
					WHERE EndDate__c = 4000-12-31
					AND LastModifiedDate = TODAY
					AND Product__c != NULL
			]);
		}
	}



	/**
	 * 수행 로직 구현
	 *
	 * @param BC : BatchableContext
	 * @param targetScope : Batch Size 실행 리스트
	 */
	public override void execute(Database.BatchableContext BC, List<SObject> targetScope) {
		//============================================================================
		// 실제 SObject 형변환
		//============================================================================
		final List<ProductPriceEntry__c> scope = (List<ProductPriceEntry__c>)targetScope;

		//============================================================================
		// ProductCode 기준 Dummy 맵
		//============================================================================
		Map<String, IF_KR_ERP_SE_0003__c> DummyByProductCode = new Map<String, IF_KR_ERP_SE_0003__c>();
		String productCode;
		Set<Id> productIds = new Set<Id>();
		for(ProductPriceEntry__c dummy : scope) {
			productIds.add(dummy.Product__c);
		}

		Map<Id, Product2> product2Map = new Map<Id, Product2>();
		for(Product2 r :
		[
				SELECT Id, DealerListPrice__c, GovListPrice__c, NhListPrice__c
				FROM Product2
				WHERE Id IN : productIds
		]) {
			product2Map.put(r.Id, r);
		}

		Product2 p;
		for(ProductPriceEntry__c r : scope) {
			p = product2Map.get(r.Product__c);
			if(r.PriceType__c == 'FC') {p.DealerListPrice__c = r.BasePrice__c;}
			if(r.PriceType__c == 'FD') {p.NhListPrice__c     = r.BasePrice__c;}
			if(r.PriceType__c == 'FE') {p.GovListPrice__c    = r.BasePrice__c;}
			product2Map.put(r.Product__c, p);
		}

		System.Savepoint sp;
		try {
			sp = Database.setSavepoint();
			update product2Map.values();
		}
		catch(Exception e) {
			Database.rollback(sp);
			System.debug(System.LoggingLevel.ERROR, '::::: ERROR LOG ' + e);
		}
		finally {
		}
	}

	/**
	 * 개별적 finish 수행
	 * 후행배치가 먼저 수행이 되어야 한다.(에러 상관없이 수행되어야 함.)
	 *
	 * @param BC Database.BatchableContext
	 */
	public override void finish(Database.BatchableContext BC) {
		if(this.isNextBatch)    Database.executeBatch(new Dummy_IF_KR_ERP_SE_0036_ba(), 200);
		super.finish(BC);
	}
}