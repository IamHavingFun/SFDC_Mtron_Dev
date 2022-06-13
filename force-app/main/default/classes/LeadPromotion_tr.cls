/****************************************************************************************
  * @filename      : LeadPromotion_tr
  * @projectname   :
  * @author        : jy.kim
  * @date          : 2020-06-26
  * @group         :
  * @group-content :
  * @description   :
  * @tester        : LeadPromotion_tr_ts
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2020-06-26         jy.kim          Create
****************************************************************************************/

public without sharing class LeadPromotion_tr extends TriggerHandler{
    Map<Id, sObject> newSetMaps = new Map<Id, Lead>();    // Trigger.newMap
    Map<Id, sObject> oldSetMaps = new Map<Id, Lead>();    // Trigger.oldMap
    List<Lead> newSetData;                                // Trigger.new
    List<Lead> oldSetData;                                // Trigger.old

    // 생성자
    public LeadPromotion_tr(){
        newSetMaps = Trigger.newMap;    // Trigger.newMap
        oldSetMaps = Trigger.oldMap;    // Trigger.oldMap
        newSetData = Trigger.new;       // Trigger.new
        oldSetData = Trigger.old;       // Trigger.old
//        this.setMaxLoopCount(10);      // MaxLoopCount 설정
    }
    /**  로직 설명
    *    1. 출처 Web 체크(WebApex__c)
    *    2. 고객 유무 판단 후, 없으면, 생성
    *    3. 개인정보활용동의 생성 -> 고객 연결
    *    4. 고객 -> 개인정보활용동의 연결(주석 처리)
    *    5. 캠페인 맴버 유무 체크(없으면, CampaignMemberApex__c = true)
    *    6. 리드 -> 고객 연결, 개인정보활용동의 연결, 캠페인 맴버 여부에 따른 LeadSource 세팅
    *    7. 캠페인 맴버 생성은 Lead.Id 연결 때문에 afterInsert로 이관
    **/
    public override void beforeInsert() {
        Set<String> dealerIdSet = new Set<String>(); // 대리점 정보
        Set<String> customerSet = new Set<String>();  // 고객 정보
        List<Lead> targetLead = new List<Lead>();   // 대상 리드 정보

        for(Lead lead : newSetData) {
            if(lead.WebApex__c){
                dealerIdSet.add(lead.Dealer__c);
                customerSet.add(lead.LastName + '|' + lead.MobilePhone.replaceAll('-','') + '|' + lead.Dealer__c);
                targetLead.add(lead);
            }
        }

        // 대리점주 정보
        Map<String, Id> dealerOwnerMap = Dummy_IF_BatchUtil.getDealerOwner(dealerIdSet);

        // 대리점 정보
        Map<String, Account> accountMap = new Map<String, Account>();
        for(Account a : [
                SELECT
                        Id,
                        Name,
                        BusinessOffice__c,
                        BusinessOffice__r.BusinessOfficeName__c
                from Account where Id =:dealerIdSet
        ]) {
            accountMap.put(a.Id,a);
        }

        // 고객 정보
        Map<String, Account> customerMap = new Map<String, Account>();
        for(Account a : [
                SELECT
                        Id,
                        LastName,
                        Dealer__c,
                        PersonContactId,
                        PersonMobilePhone,
                        CUPIInitialStartDate__pc,
                        PromotionFK__c
                from Account where PromotionFK__c =:customerSet
                and IsPersonAccount = true
        ]) {
            customerMap.put(a.PromotionFK__c,a);
        }

        // 캠페인 맴버 대상 판별
        Set<String> CampaignSet = new Set<String>();
        // 고객 존재 여부 판별 / 없으면 생성
        List<Account> customerSaveList = new List<Account>();
        Account customerSave;
        Id recordTypeIdAcc = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND IsActive = TRUE AND DeveloperName = 'PersonAccount'].Id;
        for(Lead lead : targetLead) {
            if(customerMap.containsKey(lead.LastName + '|' + lead.MobilePhone.replaceAll('-','') + '|' + lead.Dealer__c)){
                customerSave = customerMap.get(lead.LastName + '|' + lead.MobilePhone.replaceAll('-','') + '|' + lead.Dealer__c);
                customerSave.IsCUPI__pc = true; // 개인정보활용동의여부
                if(customerSave.CUPIInitialStartDate__pc == null) customerSave.CUPIInitialStartDate__pc = Date.Today(); // 개인정보최초동의일
                CampaignSet.add(customerSave.PersonContactId +'|'+lead.CampaignId__c); // 캠페인 대상 담기
            }else{
                customerSave = new Account();
                customerSave.OwnerId = dealerOwnerMap.get(lead.Dealer__c);
                customerSave.RecordTypeId = recordTypeIdAcc; // 레코드유형
                customerSave.PersonMobilePhone = lead.MobilePhone; // 휴대폰
                customerSave.LastName = lead.LastName;  // 이름
                customerSave.CustomerType__c = '개인고객'; // 고객유형
                customerSave.CustomerStatus__c = '연락처 확보'; // 고객상태
                customerSave.SystemStatus__c = '연락처 확보';
                customerSave.IsCUPI__pc = true; // 개인정보활용동의여부
                customerSave.Dealer__c = lead.Dealer__c; // 대리점
                customerSave.CUPIInitialStartDate__pc = Date.Today(); // 개인정보최초동의일
                customerSave.BusinessOfficeName__c = accountMap.get(lead.Dealer__c).BusinessOffice__r.BusinessOfficeName__c; // 영업소(R)
                customerSave.BusinessOffice__c = accountMap.get(lead.Dealer__c).BusinessOffice__c; // 영업소
            }
            customerSaveList.add(customerSave);
        }
        if(!customerSaveList.isEmpty()) upsert customerSaveList;

        // 개인정보활용동의(생성)
        List<CUPI__c> cupiList = new List<CUPI__c>();
        CUPI__c cupi;
        for(Account acc:customerSaveList){
            customerMap.put(acc.LastName + '|' + acc.PersonMobilePhone.replaceAll('-','') + '|' + acc.Dealer__c,acc);
            cupi = new CUPI__c();
            cupi.PromotionFK__c = acc.LastName + '|' + acc.PersonMobilePhone.replaceAll('-','') + '|' + acc.Dealer__c;
            cupi.ConsentedAccount__c = acc.Id;
            cupi.ConsentedContact__c = acc.PersonContactId;
            cupi.IsCUPI__c = true;
            cupi.ReceiveSMS__c = true;
            cupi.IsCUPIThirdParty__c = true;
            cupi.ConsentDate__c = Date.Today();
            cupi.NextConsentScheduledDate__c = Date.Today().addYears(2);
            cupi.Dealer__c = acc.Dealer__c;
            cupi.OwnerId = dealerOwnerMap.get(acc.Dealer__c);
            cupiList.add(cupi);
        }
        if(!cupiList.isEmpty()) insert cupiList;

        // 개인정보활용동의(Map 담기)
        Map<String, Id> cupiMap = new Map<String, Id>();
        for(CUPI__c cupi_temp:cupiList){
            cupiMap.put(cupi_temp.PromotionFK__c,cupi_temp.Id);
        }

        // 개인정보활용동의(Account 업데이트)
        /*
        for(Account acc:customerSaveList){
            acc.CUPI__pc = cupiMap.get(acc.LastName + '|' + acc.PersonMobilePhone.replaceAll('-','') + '|' + acc.Dealer__c);
        }
        if(!customerSaveList.isEmpty()) update customerSaveList;
        */

        // 캠페인 맴버 여부 체크
        Map<String, CampaignMember> camMemMap = new Map<String, CampaignMember>();
        for(CampaignMember camMem:[SELECT Id,ContactId,LeadId,Status,PromotionFK__c,CampaignId,CreatedBy.Profile.Name from CampaignMember where PromotionFK__c = :CampaignSet]){
            camMemMap.put(camMem.PromotionFK__c,camMem);
        }

        // 실제 로직
        List<CampaignMember> targetCampaignMembers = new List<CampaignMember>();
        for(Lead lead : targetLead) {
            Account tempAccount = customerMap.get(lead.LastName + '|' + lead.MobilePhone.replaceAll('-','') + '|' + lead.Dealer__c);
            lead.OwnerId = dealerOwnerMap.get(lead.Dealer__c);
            lead.BusinessOffice__c = accountMap.get(lead.Dealer__c).BusinessOffice__c;
            lead.BusinessOfficeName__c = accountMap.get(lead.Dealer__c).BusinessOffice__r.BusinessOfficeName__c;
            lead.SystemStatus__c = '신청';
            lead.IsCupi__c = true;
            lead.ContactApex__c = tempAccount.PersonContactId;
            lead.AccountId__c = tempAccount.Id;
            lead.Cupi__c = cupiMap.get(lead.LastName + '|' + lead.MobilePhone.replaceAll('-','') + '|' + lead.Dealer__c);
            // 기존 캠페인맴버
            if(camMemMap.containsKey(tempAccount.PersonContactId+'|'+lead.CampaignId__c)){
                if(camMemMap.get(tempAccount.PersonContactId+'|'+lead.CampaignId__c).CreatedBy.Profile.Name == 'Korea Partner Community User'){
                    lead.LeadSource = '대리점';
                }else{
                    lead.LeadSource = '본사';
                }
                lead.CampaignMemberApex__c = true;
                CampaignMember cm = camMemMap.get(tempAccount.PersonContactId+'|'+lead.CampaignId__c);
                cm.Status = '응답됨';
                targetCampaignMembers.add(cm);
            }else {
                lead.LeadSource = '웹페이지';
                // 신규 캠페인맴버
            }
        }
        if(targetCampaignMembers.isEmpty() == false) update targetCampaignMembers;
    }

    /**  로직 설명
    *    1. 캠페인 맴버 생성
    * **/
    public override void afterInsert() {
        // 캠페인 맴버 생성
/*
        List<CampaignMember> targetCampaignMembers = new List<CampaignMember>();
        for(Lead lead : newSetData) {
            if(lead.WebApex__c && lead.CampaignMemberApex__c){
                targetCampaignMembers.add(new CampaignMember(CampaignId = lead.CampaignId__c,ContactId = lead.ContactApex__c, LeadId=lead.Id,Status='응답됨'));
            }
        }
        if(targetCampaignMembers.size() > 0) insert targetCampaignMembers;
*/
    }
}