/****************************************************************************************
  * @filename      : lsMSalesConfirmTestDriveQa
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
    0.1     2020-08-10 오후 03:25           Park JW         Create
****************************************************************************************/

public with sharing class lsMSalesConfirmTestDriveQa {

    @AuraEnabled
    public static Lead init(final String recordId) {
        Lead targetLead = [SELECT Id, CampaignId__c, AccountId__c, AccountId__r.BusinessOffice__c, AccountId__r.Dealer__c, OwnerId, ProductId__c, Opportunity__c, isTestDriveConfirmed__c, TestDriveDate__c, Status FROM Lead WHERE Id =: recordId];

        return targetLead;
    }

    /**
     * @param recordId
     * @param requestDate
     */
    @AuraEnabled
    public static Opportunity save(Lead target){
        // 기존 생선된 기회가 없으면 만들고 리드 업데이트
        if (target.Opportunity__c == null) {
            Opportunity oppty = new Opportunity(
                    StageName = '상담',
                    RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('개인/영농법인').getRecordTypeId(),
                    BusinessOffice__c = target.AccountId__r.BusinessOffice__c,
                    Dealer__c = target.AccountId__r.Dealer__c,
                    CloseDate = Date.today().addDays(30),
                    CampaignId = target.CampaignId__c,
                    AccountId = target.AccountId__c,
                    OwnerId = target.OwnerId,
                    InterestModel__c = target.ProductId__c
            );
            insert oppty;

            target.Status = '시승예약완료';
            target.Opportunity__c = oppty.Id;
            target.isTestDriveConfirmed__c = true;
            target.TestDriveDate__c = target.TestDriveDate__c;
            update target;

            return oppty;
        } else {
            // 없으면 에러 띄우기
            throw new AuraHandledException('판매기회가 생성되어진 건입니다.');
        }
    }
}