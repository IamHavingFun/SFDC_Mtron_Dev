/****************************************************************************************
  * @filename      : MarketingCampaign_tr
  * @projectname   :
  * @author        : i2max
  * @date          : 2020-05-06
  * @group         :
  * @group-content :
  * @description   : 캠페인 Trigger
  *                  캠페인 신청시 판매기회 정보등을 조회 해온다.
  * @tester        : MarketInfo_tr_ts.cls
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2020-05-06         i2max          Create
****************************************************************************************/
public with sharing class MarketingCampaign_tr extends TriggerHandler {

    public override void beforeInsert() {
        this.setInitData(Trigger.new);
    }

    public override void beforeUpdate() {
        this.setInitData(Trigger.new);
        this.setConfirmAmountByApprovalStatus(Trigger.new, (Map<Id, MarketingCampaign__c>) Trigger.oldMap);
    }

    public override void afterUpdate() {
        this.approvedByCreateCampaign(Trigger.new, (Map<Id, MarketingCampaign__c>)Trigger.oldMap);
    }

    /**
     * 일괄 계획 데이터 로드시 Account 정보 세팅
     * Division__c 이 '실적' 인 데이터건만 target
     *
     * @param newList trigger new List
     */
    private void setInitData(List<MarketingCampaign__c> newList) {
        Set<String> tSetByArea = new Set<String>();

        Set<Id> dealerIds = new Set<Id>();
        for(MarketingCampaign__c r : newList) {
            if(r.Status__c == '작성' || r.Status__c == '') dealerIds.add(r.Dealer__c);
        }

        Map<Id, Integer> opptyCountMap = new Map<Id, Integer>();

        /*
            2021-3-11 수정.
            최근 한달 내로 날짜 수정
        */
        Date lastN30Date = Date.today().addDays(-30);

        // 지난달 상담건수
        for(AggregateResult ar : [
                SELECT Dealer__c Dealer, COUNT(Id) Cnt
                FROM Opportunity
                WHERE CreatedDate >= :lastN30Date AND Dealer__c IN :dealerIds
                GROUP BY Dealer__c
        ]) {
            opptyCountMap.put((Id) ar.get('Dealer'), (Integer) ar.get('Cnt'));
        }
        // 지난달 견적건수
        Map<Id, Integer> quoteCountMap = new Map<Id, Integer>();
        for(AggregateResult ar : [
                SELECT Opportunity__r.Dealer__c Dealer, COUNT(Id) Cnt
                FROM Quote__c
                WHERE CreatedDate >= :lastN30Date AND Opportunity__r.Dealer__c IN :dealerIds
                GROUP BY Opportunity__r.Dealer__c
        ]) {
            quoteCountMap.put((Id) ar.get('Dealer'), (Integer) ar.get('Cnt'));
        }
        // 지난달 계약건수
        Map<Id, Integer> contractCountMap = new Map<Id, Integer>();
        for(AggregateResult ar : [
                SELECT Dealer__c Dealer, COUNT(Id) Cnt
                FROM Contract__c
                WHERE CreatedDate >= :lastN30Date AND Dealer__c IN :dealerIds
                GROUP BY Dealer__c
        ]) {
            contractCountMap.put((Id) ar.get('Dealer'), (Integer) ar.get('Cnt'));
        }

        // 지난달 인도건수
        Map<Id, Integer> pdiCountMap = new Map<Id, Integer>();
        for(AggregateResult ar : [
                SELECT Contract__r.Dealer__c Dealer, COUNT(Id) Cnt
                FROM PDI__c
                WHERE CreatedDate >= :lastN30Date AND Contract__r.Dealer__c IN :dealerIds
                GROUP BY Contract__r.Dealer__c
        ]) {
            pdiCountMap.put((Id) ar.get('Dealer'), (Integer) ar.get('Cnt'));
        }
        // 금년 사업계획 : 매출
        Map<Id, Decimal> planYearAmountMap = new Map<Id, Decimal>();
        for(AggregateResult ar : [
                SELECT AccountId__c Dealer, SUM(SalesAmount__c) Amount
                FROM SalesPerformance__c
                WHERE BaseYearMonth__c <= LAST_MONTH
                AND BaseYearMonth__c = THIS_YEAR
                AND AccountId__c IN :dealerIds
                AND Division__c = '계획'
                GROUP BY AccountId__c
        ]) {
            planYearAmountMap.put((Id) ar.get('Dealer'), (Decimal) ar.get('Amount'));
        }
        // 금월 사업계획 : 매출
        Map<Id, Decimal> planMonthAmountMap = new Map<Id, Decimal>();
        for(AggregateResult ar : [
                SELECT AccountId__c Dealer, SUM(SalesAmount__c) Amount
                FROM SalesPerformance__c
                WHERE BaseYearMonth__c = LAST_MONTH
                AND AccountId__c IN :dealerIds
                AND Division__c = '계획'
                GROUP BY AccountId__c
        ]) {
            planMonthAmountMap.put((Id) ar.get('Dealer'), (Decimal) ar.get('Amount'));
        }
        // 금년 판매실적 : 매출
        Map<Id, Decimal> actualYearAmountMap = new Map<Id, Decimal>();
        for(AggregateResult ar : [
                SELECT AccountId__c Dealer, SUM(SalesAmount__c) Amount
                FROM SalesPerformance__c
                WHERE BaseYearMonth__c <= LAST_MONTH
                AND BaseYearMonth__c = THIS_YEAR
                AND AccountId__c IN :dealerIds
                AND Division__c = '실적'
                GROUP BY AccountId__c
        ]) {
            actualYearAmountMap.put((Id) ar.get('Dealer'), (Decimal) ar.get('Amount'));
        }
        // 금월 판매실적 : 매출
        Map<Id, Decimal> actualMonthAmountMap = new Map<Id, Decimal>();
        for(AggregateResult ar : [
                SELECT AccountId__c Dealer, SUM(SalesAmount__c) Amount
                FROM SalesPerformance__c
                WHERE BaseYearMonth__c = LAST_MONTH
                AND AccountId__c IN :dealerIds
                AND Division__c = '실적'
                GROUP BY AccountId__c
        ]) {
            actualMonthAmountMap.put((Id) ar.get('Dealer'), (Decimal) ar.get('Amount'));
        }
        // 대리점 SalesIQ 점수
        Map<Id, Decimal> dealerSalesIQMap = new Map<Id, Decimal>();
        for(Account r : [
                SELECT Id , SalesScoring__c
                FROM Account
                WHERE Id IN :dealerIds
        ]) {
            dealerSalesIQMap.put(r.Id, r.SalesScoring__c);
        }
        for(MarketingCampaign__c r : newList) {
            /**
             * 종료 이후에는 업데이트 하지 않는다.
            */
            if(r.Status__c == '종료')  continue;
            // 상담건수
            r.ConsultingCnt__c = opptyCountMap.containsKey(r.Dealer__c) ? opptyCountMap.get(r.Dealer__c) : 0;
            // 견적건수
            r.QuoteCnt__c = quoteCountMap.containsKey(r.Dealer__c) ? quoteCountMap.get(r.Dealer__c) : 0 ;
            // 계약건수
            r.ContractCnt__c = contractCountMap.containsKey(r.Dealer__c) ? contractCountMap.get(r.Dealer__c) : 0;
            // 인도건수
            r.DeliveryCnt__c = pdiCountMap.containsKey(r.Dealer__c) ? pdiCountMap.get(r.Dealer__c) : 0;
            // 금년사업계획
            r.PlanThisYearAmount__c =  planYearAmountMap.containsKey(r.Dealer__c) ? planYearAmountMap.get(r.Dealer__c) : 0;
            // 금월사업계획
            r.PlanThisMonthAmount__c = planMonthAmountMap.containsKey(r.Dealer__c) ? planMonthAmountMap.get(r.Dealer__c) : 0;
            // 금년판매실적
            r.ActualThisYearAmount__c = actualYearAmountMap.containsKey(r.Dealer__c) ? actualYearAmountMap.get(r.Dealer__c) : 0;
            // 금월판매실적
            r.ActualThisMonthAmount__c = actualMonthAmountMap.containsKey(r.Dealer__c) ? actualMonthAmountMap.get(r.Dealer__c) : 0;
            // SalesIQ
            r.Saels_IQ__c = dealerSalesIQMap.containsKey(r.Dealer__c) ? dealerSalesIQMap.get(r.Dealer__c) : 0;
        }
    }
    /**
     * 승인 처리가 되면 캠페인 레코드를 생성 한다.
     * Status__c = '종료', ApprovalStatus__c = '승인'
     *
     * @param newList trigger new List
     */
    private void approvedByCreateCampaign(List<MarketingCampaign__c> newList, Map<Id, MarketingCampaign__c> oldMap) {

        Id promotionRecordTypeId = I2ComUtil.getRecordType('Campaign', 'Promotion');
        Id testDriveRecordTypeId = I2ComUtil.getRecordType('Campaign', 'TestDrive');
        Set<Id> dealerIds = new Set<Id>();
        List<MarketingCampaign__c> marketingCampaigns = new List<MarketingCampaign__c>();
        MarketingCampaign__c oldData;
        Map<MarketingCampaign__c, Campaign> dataMap = new Map<MarketingCampaign__c, Campaign>();
        Id recordTypeId = null;
        for(MarketingCampaign__c newData : newList) {
            if(oldMap.containsKey(newData.Id)) {
                oldData = oldMap.get(newData.Id);
                recordTypeId = newData.CampaignType__c == '시승' ? testDriveRecordTypeId : promotionRecordTypeId;
                if(newData.Status__c != oldData.Status__c && newData.Status__c == '종료' && newData.ApprovalStatus__c == '승인') {
                    dealerIds.add(newData.Dealer__c);
                    dataMap.put(newData, new Campaign(
                            RecordTypeId = recordTypeId,
                            Name = newData.CampaignName__c,
                            StartDate = newData.StartDate__c,
                            EndDate = newData.EndDate__c,
                            Status = '프로모션 계획',
                            SystemStatus__c = '프로모션 계획',
                            BudgetedCost__c = newData.PlanBudget__c,
                            MarketingCampaign__c = newData.Id
                    ));
                }
            }
        }

        Map<Id, Account> dealerMap = new Map<Id, Account>(
            [SELECT Id, Name, BusinessOffice__r.Name FROM Account WHERE Id IN :dealerIds]
        );

        if(dataMap.isEmpty() == false) {
            Map<Id, Id> dealerGroupIdMap = getDealerGroupIdMap(dealerIds);
            insert dataMap.values();
            List<ShareSetting__c> shareSettingList = new List<ShareSetting__c>();
            List<CampaignShare> campaignShareList = new List<CampaignShare>();
            for(MarketingCampaign__c r : dataMap.keySet()) {
                Campaign camp = dataMap.get(r);
                if(dealerGroupIdMap.containsKey(r.Dealer__c)) {
                    shareSettingList.add(new ShareSetting__c(
                        Account__c = r.Dealer__c,
                        Campaign__c = camp.Id,
                        DealerApex__c = dealerMap.get(r.Dealer__c).Name,
                        BusinessOfficeApex__c = dealerMap.get(r.Dealer__c).BusinessOffice__r.Name
                    ));
                    campaignShareList.add(new CampaignShare(
                        CampaignId = camp.Id,
                        CampaignAccessLevel = 'Read',
                        RowCause = 'Manual',
                        UserOrGroupId = dealerGroupIdMap.get(r.Dealer__c)
                    ));
                }
            }
            if(shareSettingList.isEmpty() == false) insert shareSettingList;
            if(campaignShareList.isEmpty() == false) insert campaignShareList;
        }
    }

    /**
     * 승인상태가 변한 대상건 중에 확정예산이 null 값인 경우, 요청 예산 값으로 setting.
     *
     * @param newList : List<MarketingCampaign__c>
     * @param oldMap : Map<Id, MarketingCampaign__c>
     */
    private void setConfirmAmountByApprovalStatus(List<MarketingCampaign__c> newList, Map<Id, MarketingCampaign__c> oldMap) {
        for(MarketingCampaign__c mc : newList) {
            if((oldMap.get(mc.Id).ApprovalStatus__c != mc.ApprovalStatus__c && mc.ApprovalStatus__c == '승인') && mc.ConfirmAmount__c == null) {
                mc.ConfirmAmount__c = mc.PlanBudget__c;
            }
        }
    }

    public static Map<Id, Id> getDealerGroupIdMap(Set<Id> dealerIds) {
        Map<Id, Id> dealerGroupIdMap = new Map<Id, Id>();
        Map<Id, String> userRoleMap = new Map<Id, String>();
        for(UserRole r : [SELECT PortalAccountId,DeveloperName FROM UserRole WHERE PortalAccountId = :dealerIds]){
            userRoleMap.put(r.PortalAccountId, r.DeveloperName);
        }

        Map<String, Id> groupMap = new Map<String, Id>();
        for(Group r : [SELECT Id, DeveloperName FROM Group WHERE DeveloperName = :userRoleMap.values() and Type = 'RoleAndSubordinates']){
            groupMap.put(r.DeveloperName, r.Id);
        }
        for(String key : userRoleMap.keySet()) {
            String developerName = userRoleMap.get(key);
            if(groupMap.containsKey(developerName)) {
                dealerGroupIdMap.put(key, groupMap.get(developerName));
            }
        }
        return dealerGroupIdMap;
    }
}