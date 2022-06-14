/****************************************************************************************
  * @filename      : OpportunityLossStageUpdate_ba
  * @projectname   : 
  * @author        : i2max
  * @date          : 2021-04-19
  * @group         : 
  * @group-content : 
  * @description   : 상담, 견적 단계에서 실주 update
  *                : 매월 20일 수행(월배채)
                        1. 처리일자 : 매월 20일
                        2. 대상 : 대리점주 & 영업사원
                        3. 메세지 :
                        제목 : [진행 지연으로 인한 상담 및 견적의 판매실패 처리]
                        내용 : {기회이름}이 추가 진행 없이 {단계}인 상태로 희망구매월 {희망구매월}의 차월 20일이 도래하여 자동 판매실패 처리되었습니다. 해당 판매기회로 이동하시어 실패 사유를 입력하세요.
  * @tester        : OpportunityLossStageUpdate_ba_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2021-04-19         i2max          Create
****************************************************************************************/
public with sharing class OpportunityLossStageUpdate_ba implements Database.Batchable<SObject> {

    private static Date taskActivitiyDate = System.today();

    public Database.QueryLocator start(Database.BatchableContext BC) {

        //============================================================================
        // 상담, 견적은 희망구매월이 전월 이전에 해당되는 모든 건에 대해 실주처리
        //============================================================================
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
            WHERE   StageName IN ('상담', '견적')
            AND     (CloseDate <= LAST_MONTH AND CloseDate != NULL)
        ]);

    }

    public void execute(Database.BatchableContext BC, List<Opportunity> scope) {

        // 영업사원
        List<Task> taskListForDealer = new List<Task>();
        // 대리점주
        List<Task> taskListForDealerOwner = new List<Task>();

        Task tempTask, cloneTaskForDealer, cloneTaskForDealerOwner;

        for(Opportunity opportunity : scope) {
            // 단계와 시스템상태를 동일하게 세팅함.[중요] - 트리거에서 체크
            opportunity.SystemStatus__c = opportunity.StageName = '실주';
            opportunity.LossReason__c = '기간 경과 자동 판매실패';
            opportunity.IsAutoCancel__c = true;

            // Task 생성
            tempTask = new Task(
                OwnerId = null,
                Type__c = 'Guide',
                WhatId = opportunity.Id,
                ActivityDate = taskActivitiyDate,
                Subject = '[진행 지연으로 인한 상담 및 견적의 판매실패 처리]',
                Description = String.join(
                    new List<String> {
                        String.format(
                            '{0} 이 추가 진행 없이 {1} 인 상태로 희망구매월 {2} 의 차월 20일이 도래하여 자동 판매실패 처리되었습니다.',
                            new List<String>{opportunity.Name, opportunity.StageName, opportunity.CloseDate.format()}
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

        update scope;

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