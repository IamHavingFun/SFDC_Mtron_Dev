/****************************************************************************************
  * @filename      : OrderCancelAlarm_ba
  * @projectname   : 
  * @author        : i2max
  * @date          : 2021-04-15
  * @group         : 
  * @group-content : 
  * @description   : 처리일자 : 매월 15일
                     대상자 : 농협/관납 : 영업사원에게, 대리점 주문 : 대리점주 & 영업사원
                     메세지 내용
                     제목 : [확정 지연으로 인한 주문 취소 사전 경고]
                     내용 : {주문번호}가 {상태}인 단계에서 최종 확정되지 못한 상태로 해당 납품요청월의 차월 15일이 도래하였으며, 금월 20일까지 "출하 대기" 단계로 확정되지 못할 시, 본 주문은 자동으로 취소됩니다.
  *
  * @tester        : OrderCancelAlarm_ba_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2021-04-15         i2max          Create
****************************************************************************************/
public with sharing class OrderCancelAlarm_ba implements Database.Batchable<SObject> {

    //============================================================================
    // 동일한 조건으로 쿼리를 해야하기에 OrderCancelUpdate_ba의 값을 참조함
    //============================================================================
    // 조건이 되는 상태 값들
    private static Set<String> targetStatus = OrderCancelUpdate_ba.getTargetStatus();

    private static Set<String> targetRecordTypes = new Set<String> {
            '관납/농협'
    };
    private static Date activityDate = System.today();
    // 현재월의 20일까지 주문처리를 독려하기 위한 DueDate(월 20일)
    private static String actionDueData = System.today().toStartOfMonth().addDays(19).format();

    public Database.QueryLocator start(Database.BatchableContext BC) {

        //============================================================================
        // OrderCancelUpdate_ba와 동일한 추출 조건
        // 조건 변경시 OrderCancelUpdate_ba 쿼리 조건 변경해야 함에 유의
        //============================================================================
        return Database.getQueryLocator([
            SELECT  Id,
                    Name,
                    Status__c,
                    OrderScheduleDate__c,
                    BusinessOfficeRep__c,
                    OrderAccount__r.CustomerType__c,
                    DealerRep__c,
                    RecordType.Name
            FROM    Order__c
            WHERE   (OrderScheduleDate__c <= LAST_MONTH AND OrderScheduleDate__c != NULL)
            AND     Status__c IN :targetStatus
            AND     BusinessOfficeRep__c != NULL
        ]);

    }

    public void execute(Database.BatchableContext BC, List<Order__c> scope) {

        List<Task> taskList = new List<Task>();
        String preStatus;
        String orderName;
        String orderScheduleDate;
        String alertOrderScheduleDate;

        Set<Id> targetOwners = new Set<Id>();
        for(Order__c order : scope) {
            targetOwners.add(order.BusinessOfficeRep__c);
            if(targetRecordTypes.contains(order.RecordType.Name) == false) targetOwners.add(order.DealerRep__c);
        }
        Map<Id,User> activeUserMap = new Map<Id,User> ([
                SELECT Id FROM User WHERE Id IN :targetOwners AND IsActive = TRUE
        ]);
        for(Order__c order : scope) {
            orderName = order.Name;
            preStatus = order.Status__c;
            orderScheduleDate = ((Datetime)order.OrderScheduleDate__c).format('yyyy-MM');
            alertOrderScheduleDate = OrderCancelAlarm_ba.actionDueData;

            // 주문 유형이 농협관납이 아니면 대리점주도 포함한다.
            targetOwners = new Set<Id>();
            if(activeUserMap.containsKey(order.BusinessOfficeRep__c)) targetOwners.add(order.BusinessOfficeRep__c);
            if(targetRecordTypes.contains(order.RecordType.Name) == false && activeUserMap.containsKey(order.DealerRep__c)) targetOwners.add(order.DealerRep__c);

            for(Id ownerId : targetOwners) {
                taskList.add(new Task(
                        OwnerId = ownerId,
                        ActivityDate = OrderCancelAlarm_ba.activityDate,
                        Type__c = 'Guide',
                        WhatId = order.Id,
                        Subject = '[확정 지연으로 인한 주문 취소 사전 경고]',
                        Description = String.join(
                                new List<String>{
                                        String.format('{0}가 {1}인 단계에서 최종 확정되지 못한 상태로 해당 납품요청월 {2} 의 차월 15일이 도래하였으며,', new List<String>{
                                                orderName, preStatus, orderScheduleDate
                                        }),
                                        String.format('금월 {0}일까지 "출하 대기" 단계로 확정되지 못할 시, 본 주문은 자동으로 취소됩니다.', new List<String>{
                                                alertOrderScheduleDate
                                        })
                                }, '\n'),
                        CustomAlert__c = true,
                        Status = 'Open'
                ));
            }

        }

        System.debug('taskList : ' + taskList);

        //============================================================================
        // 일괄처리를 하지 않고 부분 성공 허용
        // allOrNothing 을 false 처리하여 건건히는 수행되 되게끔 처리함.
        // 별도 로깅 처리없이 수행함. 로그 찍어도 볼 수 없음.
        //============================================================================
        List<Database.SaveResult> results = Database.insert(taskList, false);

    }

    public void finish(Database.BatchableContext BC) {

    }

}