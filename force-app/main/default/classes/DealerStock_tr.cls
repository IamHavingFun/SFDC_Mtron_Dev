/****************************************************************************************
  * @filename      : DealerStock_tr
  * @projectname   : 
  * @author        : i2max
  * @date          : 2020-05-06
  * @group         : 
  * @group-content : 
  * @description   : 유통재고 트리거 적용 class
  * @tester        : DealerStock_tr_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2020-05-06         i2max          Create
****************************************************************************************/
public with sharing class DealerStock_tr extends TriggerHandler {

    public override void beforeInsert() {
        this.convertForPlanData(Trigger.new);
    }

    /**
     * 일괄 계획 데이터 로드시 Account 정보 세팅
     * Division__c 이 '계획' 인 데이터건만 target
     *
     * @param newList trigger new List
     */
    private void convertForPlanData(List<DealerStock__c> newList) {
        List<DealerStock__c> tList = new List<DealerStock__c>();
        Set<String> tSetByCustomerCode = new Set<String>();

        //============================================================================
        // 일괄 Plan Data filtering 및 CustomerCode set 구성
        //============================================================================
        String tmpCustomerCode;
        for (DealerStock__c loadData : newList) {
            tmpCustomerCode = loadData.CustomerCode__c;
            if (String.isNotBlank(tmpCustomerCode) && loadData.Division__c == '계획') {
                //============================================================================
                // Target trigger 대상건만 담음
                //============================================================================
                tList.add(loadData);
                //============================================================================
                // CustomerCode 기반의 Set 구성 for Account 조회용
                //============================================================================
                if (!tSetByCustomerCode.contains(tmpCustomerCode)) {
                    tSetByCustomerCode.add(tmpCustomerCode);
                }
            }
        }

        if(!tList.isEmpty()) {
            //============================================================================
            // CustomerCode 에 매핑되는 Account Map을 구성
            //============================================================================
            Map<String, Account> tAccountMapByCustomerCode = new Map<String, Account>();
            String tmpErpCode;
            Set<Id> accountIds = new Set<Id>();

            for (Account account : [
                SELECT  Id, Name, ERPCode__c, BusinessOffice__c, BusinessOffice__r.BusinessOfficeName__c,
                        BusinessOfficeName__c, Area__c, SalesRep__c, CustomerType__c,
                        OwnerId
                FROM    Account
                WHERE   ERPCode__c IN :tSetByCustomerCode
            ]) {
                tmpErpCode = account.ERPCode__c;
                if (!tAccountMapByCustomerCode.containsKey(tmpErpCode) && String.isNotBlank(tmpErpCode)) {
                    tAccountMapByCustomerCode.put(tmpErpCode, account);
                    accountIds.add(account.Id);
                }
            }

            //============================================================================
            // 대리점 Account의 점주를 ownerId롤 지정하기 위한 매핑작업
            //============================================================================
            Map<String, Id> accountOwnerMap = new Map<String, Id>();
            for(User u : [
                SELECT Id, AccountId
                FROM User
                WHERE AccountId IN : accountIds
                AND Contact.DealerRole__c = '대표'
                AND IsActive = TRUE
            ]) {
                accountOwnerMap.put(u.AccountId, u.Id);
            }

            //============================================================================
            // CustomerCode 에 매핑되는 Account의 필드를 세팅함
            //============================================================================
            Account tmpAccount;
            Id tmpId;

            for (DealerStock__c targetData : tList) {

                tmpAccount = (Account) tAccountMapByCustomerCode.get(targetData.CustomerCode__c);

                //============================================================================
                // 파일 업로드로 수행이 되므로 에러가 발생할 경우 필드에러 처리
                //============================================================================
                if(tmpAccount == null) {
                    targetData.CustomerCode__c.addError('CustomerCode__c에 매핑되는 Account가 존재하지 않습니다.');
                }
                else {
                    tmpId = accountOwnerMap.get(tmpAccount.Id);
                    if(tmpId == null) {
                        targetData.CustomerCode__c.addError('CustomerCode__c에 매핑되는 대리점의 대리점주가 존재하지 않습니다.');
                    }

                    targetData.BusinessOffice__c    = tmpAccount.BusinessOffice__c;
                    targetData.SalesRepUser__c      = tmpAccount.OwnerId;
                    targetData.OwnerId              = tmpId;
                    targetData.AccountId__c         = tmpAccount.Id;

                }
            }
        }
    }

}