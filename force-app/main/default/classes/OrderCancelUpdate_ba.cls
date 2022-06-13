/****************************************************************************************
  * @filename      : OrderCancelUpdate_ba
  * @projectname   : 
  * @author        : i2max
  * @date          : 2021-04-15
  * @group         : 
  * @group-content : 
  * @description   : 처리일자 : 매월 20일
                     대장자 : ​농협/관납 : 영업사원에게, 대리점 주문 : 대리점주 & 영업사원
                     메세지 내용
                    ​제목 : [확정 지연으로 인한 주문 취소]
                     내용 : ​{주문번호}가 {상태}인 단계에서 최종 확정되지 못한 상태로 해당 납품요청월의 차월 20일이 도래하여, 본 주문은 자동으로 취소되었습니다.
​ *
  * @tester        : OrderCancelUpdate_ba_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2021-04-15         i2max          Create
****************************************************************************************/
public with sharing class OrderCancelUpdate_ba implements Database.Batchable<SObject> {

    // 조건이 되는 상태 값들
    private static Set<String> targetStatus = new Set<String> {
        '대리점 주문 신청',
        '영업소 주문 검토',
        '영업소 주문 확정',
        '본사 여신 검토'
    };
    private static Set<String> targetRecordTypes = new Set<String> {
            '관납/농협'
    };

    private static Date activityDate = System.today();
    // 현재월의 20일까지 주문처리를 독려하기 위한 DueDate(월 20일)
    private static String actionDueData = System.today().toStartOfMonth().addDays(19).format();

    public static Set<String> getTargetStatus() {
        return OrderCancelUpdate_ba.targetStatus;
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {

        //============================================================================
        // OrderCancelAlarm_ba와 동일한 추출 조건
        // 조건 변경시 OrderCancelAlarm_ba 쿼리 조건 변경해야 함에 유의
        //============================================================================
        return Database.getQueryLocator([
            SELECT  Id,
                    Name,
                    Status__c,
                    SystemStatus__c,
                    OrderScheduleDate__c,
                    isOrderCancel__c,
                    IsAutoCancel__c,
                    OrderAccount__r.CustomerType__c,
                    DealerRep__c,
                    BusinessOfficeRep__c,
                    RecordType.Name
            FROM    Order__c
            WHERE   (OrderScheduleDate__c <= LAST_MONTH AND OrderScheduleDate__c != NULL)
            AND     Status__c IN :targetStatus
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
            alertOrderScheduleDate = OrderCancelUpdate_ba.actionDueData;

            order.Status__c = '종료';
            order.SystemStatus__c = '종료';
            order.isOrderCancel__c = true;
            order.IsAutoCancel__c = true;

            // 주문 유형이 농협관납이 아니면 대리점주도 포함한다.
            targetOwners = new Set<Id>();
            if(activeUserMap.containsKey(order.BusinessOfficeRep__c)) targetOwners.add(order.BusinessOfficeRep__c);
            if(targetRecordTypes.contains(order.RecordType.Name) == false && activeUserMap.containsKey(order.DealerRep__c)) targetOwners.add(order.DealerRep__c);

            for(Id ownerId : targetOwners) {
                taskList.add(new Task(
                        OwnerId = ownerId,
                        ActivityDate = OrderCancelUpdate_ba.activityDate,
                        Type__c = 'Guide',
                        WhatId = order.Id,
                        Subject = '[확정 지연으로 인한 주문 취소]',
                        Description = String.join(
                                new List<String>{
                                        String.format('{0}가 {1}인 단계에서 최종 확정되지 못한 상태로 ', new List<String>{
                                            orderName, preStatus
                                        }),
                                        String.format('해당 납품요청월 {0} 의 차월 20일이 도래하여, ', new List<String>{
                                            orderScheduleDate
                                        }),
                                        '본 주문은 자동으로 취소되었습니다. '
                                }, '\n'),
                        CustomAlert__c = true,
                        Status = 'Open'
                ));
            }
        }

        update scope;

        //============================================================================
        // 일괄처리를 하지 않고 부분 성공 허용
        // allOrNothing 을 false 처리하여 건건히는 수행되 되게끔 처리함.
        // 별도 로깅 처리없이 수행함. 로그 찍어도 볼 수 없음.
        //============================================================================
        List<Database.SaveResult> results = Database.insert(taskList, false);

    }

    public void finish(Database.BatchableContext BC) {

/*        OrderCancelERPSend_ba ba = new OrderCancelERPSend_ba();
        Database.executeBatch(ba, 1);*/
    }

}