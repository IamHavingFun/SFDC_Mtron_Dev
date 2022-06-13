/**
 * Created by MS on 2020-07-31.
 */

public with sharing class Opportunity_tr extends TriggerHandler {

    public override void beforeInsert() {
        //============================================================================
        // 기회 제목 처리.
        //============================================================================
        this.setOpportunityNameUpdate();
        //============================================================================
        // 단계 변경시 실주 단계 처리
        //============================================================================
        this.setOpportunityLossStage((List<Opportunity>)Trigger.new, new Map<Id, Opportunity>());

    }

    public override void beforeUpdate() {
        //============================================================================
        // 기회 제목 처리.
        //============================================================================
        this.setOpportunityNameUpdate();
        //============================================================================
        // 단계 변경시 실주 단계 처리
        //============================================================================
        this.setOpportunityLossStage((List<Opportunity>)Trigger.new, (Map<Id, Opportunity>) Trigger.oldMap);
    }

    /**
     * 기회 제목 업데이트
     *
     * @param scope
     * @param oldMap
     */
    private void setOpportunityLossStage(List<Opportunity> scope, Map<Id, Opportunity> oldMap) {
        String newStageName = '';
        String oldStageName = '';

        for(Opportunity oppty : scope) {
            newStageName = oppty.StageName;
            oldStageName = '';
            if(oldMap.containsKey(oppty.Id)) oldStageName = oldMap.get(oppty.Id).StageName;
            if(newStageName != oldStageName) {
                // 수기 단계 변경을 막기 위해서 프로그램에서만 처리 하는 SystemStatus__c 필드를 활용한다.
                //if(newStageName != oppty.SystemStatus__c) oppty.StageName.addError('수기로 단계 변경 처리는 할 수 없습니다');

                if(newStageName == '상담') {
                    if(oppty.ConsultingDate__c == null) oppty.ConsultingDate__c = Date.today();
                }
                if(newStageName == '견적') {
                    if(String.isEmpty(oldStageName) == true) {
                        // 바로 견적으로 작성 되는 경우가 있어..
                        // 견적시 상담일자도 동일하게 처리 한다.
                        oppty.ConsultingDate__c = Date.today();
                    }
                    if(oppty.QuoteDate__c == null) oppty.QuoteDate__c = Date.today();
                }
                if(newStageName == '계약') if(oppty.ContractDate__c == null) oppty.ContractDate__c = Date.today();
                if(newStageName == '인도') if(oppty.DeliveryDate__c == null) oppty.DeliveryDate__c = Date.today();
                if(newStageName == '실주' && oldStageName != '실주') {
                    oppty.LossStage__c = oldStageName;      // 실주 단계
                    oppty.LossDate__c = Date.today();       // 실주 일자
                }
            }
        }
    }


    /**
     * 기회 제목 업데이트
     *
     * @param scope
     */
    private void setOpportunityNameUpdate() {
        //InterestModel__r.Name
        //Account.Name

        Set<Id> accountIds = new Set<Id>();
        Set<Id> productIds = new Set<Id>();
        for(Opportunity r : (List<Opportunity>) Trigger.new) {
            if(r.AccountId != null) accountIds.add(r.AccountId);
            else r.AccountId.addError('판매기회의 고객은 필수 정보 입니다.');
            if(r.InterestModel__c != null) productIds.add(r.InterestModel__c);
            else r.InterestModel__c.addError('판매기회의 관심 모델은 필수 정보 입니다.');
        }

        Map<Id, Account> accountMap   = new Map<Id, Account>([SELECT Id, Name FROM Account WHERE Id IN : accountIds]);
        Map<Id, Product2> product2Map = new Map<Id, Product2>([SELECT Id, Name FROM Product2 WHERE Id IN : productIds]);
        String accountName = '';
        String productName = '';
        for(Opportunity r : (List<Opportunity>) Trigger.new) {
            accountName = accountMap.containsKey(r.AccountId) == true ? accountMap.get(r.AccountId).Name : '고객';
            productName = product2Map.containsKey(r.InterestModel__c) == true ? product2Map.get(r.InterestModel__c).Name : '제품';
            r.Name = String.join(new List<String>{
                    accountName,
                    productName,
                    ((Datetime)r.CloseDate).format('yyyyMMdd')
            }, '-');
        }
    }
}