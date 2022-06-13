/****************************************************************************************
  * @filename      : lsMSalesCreateNewOpptyQa
  * @projectname   : LS
  * @author        : Park JW
  * @date          : 2020-08-06 오전 10:20
  * @group         :
  * @group-content :
  * @description   :
  * @tester        :
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                      author          description
  * ===============================================================
    0.1     2020-08-06 오전 10:20           Park JW         Create
****************************************************************************************/

public with sharing class lsMSalesCreateNewOpptyQa {
    /**
     * @param recordId
     */
    @AuraEnabled
    public static Opportunity init(final String recordId){
        Lead targetLead = [SELECT Id, CampaignId__c, AccountId__c, AccountId__r.BusinessOffice__c, AccountId__r.Dealer__c, OwnerId, ProductId__c, Opportunity__c, Status FROM Lead WHERE Id =: recordId];

        // 기존 생선된 기회가 없으면 만들고 리드 업데이트
        if (targetLead.Opportunity__c == null) {
            Opportunity oppty = new Opportunity(
                    StageName = '상담',
					SystemStatus__c = '상담',
                    RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('개인/영농법인').getRecordTypeId(),
                    BusinessOffice__c = targetLead.AccountId__r.BusinessOffice__c,
                    Dealer__c = targetLead.AccountId__r.Dealer__c,
                    CloseDate = Date.today().addDays(30),
                    CampaignId = targetLead.CampaignId__c,
                    AccountId = targetLead.AccountId__c,
                    OwnerId = targetLead.OwnerId,
                    InterestModel__c = targetLead.ProductId__c
            );
            insert oppty;

            targetLead.Status = '기회생성';
            targetLead.Opportunity__c = oppty.Id;
            update targetLead;

            return oppty;
        } else {
            // 없으면 에러 띄우기
            throw new AuraHandledException('판매기회가 생성되어진 건입니다.');
        }
    }
}