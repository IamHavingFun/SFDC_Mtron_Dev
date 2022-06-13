/****************************************************************************************
  * @filename      : OrderAutoCancelAlarm_ba
  * @projectname   :
  * @author        : i2max
  * @date          : 2021-04-15
  * @group         :
  * @group-content :
  * @description   : 처리일자 : 매월 25일
                     지난달 까지 출하 처리 하지 못한 건들을 주문 자동 취소 알림.
                     [판매문서번호] 입력 관련​: 주문 요청 하지 않을건들 대상.
  *
  * @tester        : OrderAutoCancelAlarm_ba_ts.cls
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2021-12-15         i2max          Create
    0.2     2022-03-03         i2max          ITVOC-2022-02-0684
****************************************************************************************/
public with sharing class OrderAutoCancelAlarm_ba implements Database.Batchable<SObject> {

	//============================================================================
	// 동일한 조건으로 쿼리를 해야하기에 OrderCancelUpdate_ba의 값을 참조함
	//============================================================================
	private static Date activityDate = System.today();

	public Database.QueryLocator start(Database.BatchableContext BC) {

		//============================================================================
		// OrderCancelUpdate_ba와 동일한 추출 조건
		// 조건 변경시 OrderCancelUpdate_ba 쿼리 조건 변경해야 함에 유의
		//============================================================================
		return Database.getQueryLocator([
				SELECT
						Id, Name, Division__c, PurposeOfOrder__c, BusinessOfficeRep__c, BusinessOfficeRep__r.IsActive,
						Dealer__r.OwnerId
				FROM Order__c
				WHERE Division__c = '공장주문'
				AND PurposeOfOrder__c = '재고보충'
				AND SalesDocNo__c = NULL
				AND Status__c NOT IN ('종료')
				AND OrderScheduleDate__c = NEXT_MONTH
				ORDER BY OrderScheduleDate__c ASC
		]);

	}

	public void execute(Database.BatchableContext BC, List<Order__c> scope) {

		List<Task> taskList = new List<Task>();
		String orderName;
		String salesRapId;
		for(Order__c order : scope) {
			orderName = order.Name;
			salesRapId = order.BusinessOfficeRep__c;
			if(order.BusinessOfficeRep__c == null) {
				salesRapId = order.Dealer__r.OwnerId;
			}
			if(String.isBlank(salesRapId) == false) {
				taskList.add(new Task(
						OwnerId = salesRapId,
						ActivityDate = OrderAutoCancelAlarm_ba.activityDate,
						Type__c = 'Guide',
						WhatId = order.Id,
						Subject = '[주문 진행 지연으로 인한 자동 취소 사전 경고]',
						Description = String.join(
								new List<String>{
										String.format('{0} 은 이번 달 말일까지 SAP 주문 입력이 되지 않을 경우, 다음 달 1일 자동 취소됩니다.', new List<String>{
												orderName
										})
								}, '\n'),
						CustomAlert__c = true,
						Status = 'Open'
				));
			}
		}

		//System.debug('taskList : ' + taskList);

		//============================================================================
		// 일괄처리를 하지 않고 부분 성공 허용
		// allOrNothing 을 false 처리하여 건건히는 수행되 되게끔 처리함.
		// 별도 로깅 처리없이 수행함. 로그 찍어도 볼 수 없음.
		//============================================================================
		List<Database.SaveResult> results = Database.insert(taskList, false);

	}

	public void finish(Database.BatchableContext BC) {

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