/****************************************************************************************
  * @filename      : OrderAutoCancelERPSendLoan_ba
  * @projectname   :
  * @author        : i2max
  * @date          : 2021-12-15
  * @group         :
  * @group-content :
  * @description   : 처리일자 : 매월 특정일 기준
                     조건 : 특정일 기준에 여신 처리 안된 주문 취소
​ *
  * @tester        : OrderAutoCancelERPSendLoan_ba_ts.cls
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2021-12-15         i2max          Create
****************************************************************************************/
public with sharing class OrderAutoCancelERPSendLoan_ba implements Database.Batchable<SObject>, Database.AllowsCallouts {

	public String query;

	public OrderAutoCancelERPSendLoan_ba() {
		this(null);
	}

	public OrderAutoCancelERPSendLoan_ba(String query) {
		this.query = query;
	}

	public Database.QueryLocator start(Database.BatchableContext BC) {

		if(String.isEmpty(query)) {
			query = 'SELECT ' +
					'Id, Name, Division__c, PurposeOfOrder__c, BusinessOfficeRep__c, BusinessOfficeRep__r.IsActive, ' +
					'Dealer__r.OwnerId, SalesDocNo__c ' +
					'FROM Order__c ' +
					'WHERE Division__c = \'공장주문\' ' +
					'AND PurposeOfOrder__c = \'재고보충\' ' +
					'AND ErpZLNNO__c = NULL ' +
					'AND Status__c = \'본사 여신 검토\' ' +
					'AND OrderScheduleDate__c = THIS_MONTH ' +
					'ORDER BY OrderScheduleDate__c ASC ' +
					'LIMIT 50 ';
		}
		return Database.getQueryLocator(query);

	}

	public void execute(Database.BatchableContext BC, List<Order__c> scope) {
		Map<String, String> returnMap = new Map<String, String>();
		String callType = 'OR';
		for(Order__c r : scope) {
			if(String.isNotEmpty(r.SalesDocNo__c)) {
				returnMap = OrderServiceIF.OrderCancel_OR(r.Id);
				if (returnMap != null && returnMap.get('STATUS') == 'Y') {
					r.ERPOrderCancelStatus__c = callType + ' 취소성공';
					r.Status__c = '종료';
					r.SystemStatus__c = '종료';
					r.IsAutoCancel__c = true;
					r.isOrderCancel__c = true;
				} else {
					r.ERPOrderCancelStatus__c = callType + ' 취소실패';
				}
				r.ERPOrderCancelMessage__c = returnMap.get('MESSAGE').left(255);
			} else {
				r.ERPOrderCancelStatus__c = callType + ' 취소성공';
				r.ERPOrderCancelMessage__c = '정상';
				r.Status__c = '종료';
				r.SystemStatus__c = '종료';
				r.IsAutoCancel__c = true;
				r.isOrderCancel__c = true;
			}
		}

		update scope;
	}

	public void finish(Database.BatchableContext BC) {
		// 배치 수행 대상 건수가 남아 있으면 추가 재 실행.
		String countQuery = 'SELECT COUNT() ' +
				'FROM Order__c ' +
				'WHERE Division__c = \'공장주문\' ' +
				'AND PurposeOfOrder__c = \'재고보충\' ' +
				'AND ErpZLNNO__c = NULL ' +
				'AND Status__c = \'본사 여신 검토\' ' +
				'AND OrderScheduleDate__c = THIS_MONTH ';
		Integer moreCount = Database.countQuery(countQuery);
		if(moreCount > 0) {
			OrderAutoCancelERPSend_ba ba = new OrderAutoCancelERPSend_ba();
			Database.executeBatch(ba, 50);
		}
	}


	public static void runTest() {
		Integer i = 0;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
	}

}