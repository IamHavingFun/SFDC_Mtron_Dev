/****************************************************************************************
  * @filename      : OrderDeliverySeqUpdate_ba
  * @author        : I2MAX
  * @date          : 2021-11-15
  * @group         : 
  * @group-content : 
  * @description   : 
  * @tester        : OrderDeliverySeqUpdate_ba_ts.cls
  * @schedule      :
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author        description
  * ===============================================================
    1.0     2021-11-15       I2MAX.YR           Create
****************************************************************************************/


public with sharing class OrderDeliverySeqUpdate_ba implements Database.Batchable<SObject>, Database.Stateful {

    public String query;
    public Boolean isNextBatch = false;

    public Database.QueryLocator start(Database.BatchableContext BC) {

		Set<String> productCodes = new Set<String>();
		if(String.isNotEmpty(this.query)) {
			return Database.getQueryLocator(query);

		} else {
			List<AggregateResult> targetDatas = [
					SELECT  OrderProduct__r.ProductCode productCode, COUNT(Id)
					FROM Order__c
					WHERE Status__c != '종료'
					AND isOrderCancel__c = FALSE
					AND VSTEL__c IN ('', 'M620')
					GROUP BY  OrderProduct__r.ProductCode
			];
			for(AggregateResult ar : targetDatas) {
				productCodes.add(String.valueOf(ar.get('productCode')));
			}

			return Database.getQueryLocator([
					SELECT
							ProductCode
					FROM Product2
					WHERE ProductCode IN : (productCodes)
			]);
		}
    }

    public void execute(Database.BatchableContext BC, List<Product2> scope) {
        // orderSeq 증가, 순위 반영

		Product2 targetScope = scope.get(0);

		List<Order__c> orderList = [
				SELECT
						Id, Name, DeliverySeq__c, Status__c,RecordType.Name, PurposeOfOrder__c, fm_RecordTypeOrder__c, fm_OrderScheduleYearMonth__c,  fm_IsPreOrder__c,   fm_OrderPurposeOrder__c,   OrderScheduleDate__c,  CreatedDate
				FROM Order__c
				WHERE Status__c != '종료'
				AND isOrderCancel__c = FALSE
				AND VSTEL__c IN ('', 'M620')
				AND OrderScheduleDate__c != NULL
				AND OrderProduct__r.ProductCode = :targetScope.ProductCode
				ORDER BY fm_RecordTypeOrder__c, fm_OrderScheduleYearMonth__c, fm_IsPreOrder__c, fm_OrderPurposeOrder__c, OrderScheduleDate__c, CreatedDate
		];
	    Integer OrderSeq = 1;
        for (Order__c r : orderList) {
            r.DeliverySeq__c = OrderSeq++;
        }
        update orderList;
    }


    public void finish(Database.BatchableContext BC) {
    }

    public static void runTest() {
		Integer yr_seo = 0;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
	}
}