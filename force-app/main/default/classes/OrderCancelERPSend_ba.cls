/****************************************************************************************
  * @filename      : OrderCancelERPSend_ba
  * @projectname   :
  * @author        : i2max
  * @date          : 2021-04-15
  * @group         :
  * @group-content :
  * @description   : 처리일자 : 매월 20일
                     조건 : 금일 자동 취소된 건들에 대한 ERP 로 전송
​ *
  * @tester        : OrderCancelERPSend_ba_ts.cls
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2021-04-15         i2max          Create
****************************************************************************************/
public with sharing class OrderCancelERPSend_ba implements Database.Batchable<SObject>, Database.AllowsCallouts {

	public Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator([
				SELECT  Id,
						Name,
						Status__c,
						SystemStatus__c,
						Division__c,
						isOrderCancel__c,
						IsAutoCancel__c,
						ERPOrderCancelStatus__c,
						ERPOrderCancelMessage__c
				FROM    Order__c
				WHERE   IsAutoCancel__c = TRUE
				AND     LastModifiedDate = TODAY
				AND     SalesDocNo__c != NULL
		]);

	}

	public void execute(Database.BatchableContext BC, List<Order__c> scope) {
		Map<String, String> returnMap = new Map<String, String>();
		String callType = '';
		for(Order__c r : scope) {
			if(r.Division__c == '전수배' && String.isEmpty(r.ERPOrderCancelStatus__c)) {
				// 전수배 주문 취소
				callType = 'ZORT';
				returnMap = OrderServiceIF.OrderCancel_ZORT(r.Id);
			} else {
				// 공장주문 취소
				callType = 'OR';
				returnMap = OrderServiceIF.OrderCancel_OR(r.Id);
			}
			if(returnMap != null && returnMap.get('STATUS') == 'Y') r.ERPOrderCancelStatus__c = callType+' 취소성공';
			else                                                    r.ERPOrderCancelStatus__c = callType+' 취소실패';
			r.ERPOrderCancelMessage__c = returnMap.get('MESSAGE').left(255);
		}

		update scope;
	}

	public void finish(Database.BatchableContext BC) {
		// 전수배 반품 주문 취소 처리.
		OrderCancelERPSend2_ba ba = new OrderCancelERPSend2_ba();
		Database.executeBatch(ba, 1);
	}

}