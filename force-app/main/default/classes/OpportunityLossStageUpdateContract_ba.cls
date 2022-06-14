/****************************************************************************************
  * @filename      : OpportunityLossStageUpdateContract_ba
  * @projectname   : 
  * @author        : i2max
  * @date          : 2021-04-19
  * @group         : 
  * @group-content : 
  * @description   : 매일 수행(일배치) : 8시 스케쥴
                        1. 처리일자 : 계약 인도기일 + 30일
                        2. 대상 : 대리점주 & 영업사원
                        3. 메세지 :
                        제목 : [진행 지연으로 인한 계약의 판매실패 처리]
                        내용 : {기회이름}이 추가 진행 없이 {단계}인 상태로 고객 인도기일 {고객 인도기일}로부터 30일이 경과하여 자동 판매실패 처리되었습니다. 해당 판매기회로 이동하여 실패 사유를 입력하세요.
  * @tester        : OpportunityLossStageUpdateContract_ba_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2021-04-19         i2max          Create
****************************************************************************************/
public with sharing class OpportunityLossStageUpdateContract_ba implements Database.Batchable<SObject> {

    //============================================================================
    // 계약인 경우 고객인도기일 + 30일 에 실주 처리
    //============================================================================
    @TestVisible
    private static Integer calDays = -30;
    private static Date targetBaseDate = System.today().addDays(calDays);

    private static Date taskActivitiyDate = System.today();

    public Database.QueryLocator start(Database.BatchableContext BC) {

        return Database.getQueryLocator([
            SELECT  Id,
                    Name,                               // 기회이름
                    StageName,                          // 단계
                    SystemStatus__c,                    // 시스템 상태
                    LossReason__c,                      // 실패사유
                    CloseDate,                          // 희망구매월
                    CustomerExpectedDate__c,            // 고객인도기일
                    Dealer__r.OwnerId,                  // 영업사원
                    Dealer__r.Owner.IsActive,           // 영업사원 유효여부
                    Dealer__r.DealerOwner__c,           // 대리점주
                    Dealer__r.DealerOwner__r.IsActive,  // 대리점주 유효여부
                    OwnerId
            FROM    Opportunity
            WHERE   StageName IN ('계약')
            AND     CustomerExpectedDate__c <= :targetBaseDate
        ]);

    }

    public void execute(Database.BatchableContext BC, List<Opportunity> scope) {

        // 주문의 상태와 연동
        List<Order__c> orderList = [
            SELECT Id, isOrderCancel__c, IsAutoCancel__c, SystemStatus__c, Status__c, Opportunity__c
            FROM Order__c
            WHERE Opportunity__c IN :scope
        ];

        Map<Id, Order__c> orderMapByOpportunity = new Map<Id, Order__c>();

        for(Order__c order : orderList) {
            // ITVOC-2021-09-0513
            if(order.Status__c == '종료' || order.Status__c == '출하') continue;
            orderMapByOpportunity.put(order.Opportunity__c, order);
        }

        // 영업사원
        List<Task> taskListForDealer = new List<Task>();
        // 대리점주
        List<Task> taskListForDealerOwner = new List<Task>();

        Task tempTask, cloneTaskForDealer, cloneTaskForDealerOwner;
        Order__c tempOrder;
        List<Opportunity> updateOpportunityList = new List<Opportunity>();
        List<Order__c> updateOrderList = new List<Order__c>();

        Set<String> lossOpptyIds = new Set<String>();
        for(Opportunity opportunity : scope) {

            // 단계와 시스템상태를 동일하게 세팅함.[중요] - 트리거에서 체크
            opportunity.SystemStatus__c = opportunity.StageName = '실주';
            opportunity.LossReason__c = '기간 경과 자동 판매실패';
            opportunity.IsAutoCancel__c = true;

            updateOpportunityList.add(opportunity);
            lossOpptyIds.add(opportunity.Id);

            // 주문 업데이트
            if(orderMapByOpportunity.containsKey(opportunity.Id)) {
                tempOrder = orderMapByOpportunity.get(opportunity.Id);
                tempOrder.isOrderCancel__c = true;
                tempOrder.IsAutoCancel__c = true;
                tempOrder.Status__c = tempOrder.SystemStatus__c = '종료';
                updateOrderList.add(tempOrder);
            }

            // task 생성(alarm)
            tempTask = new Task(
                OwnerId = null,
                Type__c = 'Guide',
                WhatId = opportunity.Id,
                ActivityDate = taskActivitiyDate,
                Subject = '[진행 지연으로 인한 계약의 판매실패 처리]',
                Description = String.join(
                    new List<String> {
                        String.format(
                            '{0} 이 추가 진행 없이 {1} 인 상태로 고객 인도기일 {2} 로부터 30일이 경과하여 자동 판매실패 처리되었습니다.',
                            new List<String>{opportunity.Name, opportunity.StageName, opportunity.CustomerExpectedDate__c.format()}
                        ),
                        '해당 판매기회로 이동하시어 실패 사유를 입력하세요.'
                    }, '\n'),
                CustomAlert__c = true,
                Status = 'Open'
            );

            if(opportunity.Dealer__r.Owner.IsActive == true) {
                cloneTaskForDealer = tempTask.clone(false, true);
                cloneTaskForDealer.OwnerId = opportunity.Dealer__r.OwnerId;
                taskListForDealer.add(cloneTaskForDealer);
            }

            if(opportunity.Dealer__r.DealerOwner__r.IsActive == true) {
                cloneTaskForDealerOwner = tempTask.clone(false, true);
                cloneTaskForDealerOwner.OwnerId = opportunity.Dealer__r.DealerOwner__c;
                taskListForDealerOwner.add(cloneTaskForDealerOwner);
            }

        }

        // 주문의 상태로 판단한 처리 판매기회 업데이트
        update updateOpportunityList;

        // 주문의 상태로 판단한 처리 주문 업데이트
        update updateOrderList;

/*        // SalesIQ 점수 등록
        try {
            SalesIQService.setOpportunitySalesIQ(lossOpptyIds, 'IQ-0003');
        } catch (Exception e) {
            // none ;
        }*/

        //============================================================================
        // 일괄처리를 하지 않고 부분 성공 허용
        // allOrNothing 을 false 처리하여 건건히는 수행되 되게끔 처리함.
        // 별도 로깅 처리없이 수행함. 로그 찍어도 볼 수 없음.
        //============================================================================
        List<Database.SaveResult> resultsForDealer = Database.insert(taskListForDealer, false);
        List<Database.SaveResult> resultsForDealerOwner = Database.insert(taskListForDealerOwner, false);

    }

    public void finish(Database.BatchableContext BC) {

    }

}