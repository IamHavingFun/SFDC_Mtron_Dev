/****************************************************************************************
  * @filename      : MarketInfo_tr
  * @projectname   : 
  * @author        : i2max
  * @date          : 2020-05-06
  * @group         : 
  * @group-content : 
  * @description   : 시장정보 트리거 적용 class
  * @tester        : MarketInfo_tr_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2020-05-06         i2max          Create
****************************************************************************************/
public with sharing class MarketInfo_tr extends TriggerHandler {

    public override void beforeInsert() {
        this.convertForPlanData(Trigger.new);
    }

    /**
     * 일괄 계획 데이터 로드시 Account 정보 세팅
     * Division__c 이 '실적' 인 데이터건만 target
     *
     * @param newList trigger new List
     */
    private void convertForPlanData(List<MarketInfo__c> newList) {
        List<MarketInfo__c> tList = new List<MarketInfo__c>();
        Set<String> tSetByArea = new Set<String>();

        //============================================================================
        // 일괄 Plan Data filtering 및 CustomerCode set 구성
        // BusinessOfficeRegName__c : 영업소(등록용) 필드에 BusinessOfficeName__c label 값이 들어옴
        //============================================================================
        String tmpArea;
        for (MarketInfo__c loadData : newList) {
            tmpArea = loadData.Area__c;
            if (String.isNotBlank(tmpArea) && loadData.Division__c == '실적') {
                //============================================================================
                // Target trigger 대상건만 담음
                //============================================================================
                tList.add(loadData);
                //============================================================================
                // CustomerCode 기반의 Set 구성 for Account 조회용
                //============================================================================
                if (!tSetByArea.contains(tmpArea)) {
                    tSetByArea.add(tmpArea);
                }
            }
        }

        if(!tList.isEmpty()) {
            //============================================================================
            // 지역의 Dealer Account의 정보를 담음
            //============================================================================
            Map<String, Account> tAccountMapByArea = new Map<String, Account>();
            String area;
            Set<Id> accountIds = new Set<Id>();

            for (DealerArea__c dealerArea  : [
                SELECT  Id, Area__c,
                        Dealer__c, Dealer__r.Id, Dealer__r.OwnerId, Dealer__r.ERPCode__c,
                        Dealer__r.BusinessOffice__c, Dealer__r.BusinessOfficeName__c, Dealer__r.BusinessOffice__r.BusinessOfficeName__c
                FROM    DealerArea__c
                WHERE   Area__c IN :tSetByArea
                // 2020.06.16 : 조건 추가
                AND     AreaRepYN__c = 'Y'
            ]) {
                area = dealerArea.Area__c;
                if(!tAccountMapByArea.containsKey(area) && String.isNotBlank(area)) {
                    tAccountMapByArea.put(area, dealerArea.Dealer__r);
                    accountIds.add(dealerArea.Dealer__c);
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
            // BusinessOffice 에 매핑되는 Account의 필드를 세팅함
            //============================================================================
            Account tmpAccount;
            Id tmpId;

            for (MarketInfo__c targetData : tList) {

                area = targetData.Area__c;

                // 지역기준의 Dealer Account의 정보 세팅
                tmpAccount = (Account) tAccountMapByArea.get(area);

                //============================================================================
                // 파일 업로드로 수행이 되므로 에러가 발생할 경우 필드에러 처리
                //============================================================================
                if(tmpAccount == null) {
                    targetData.Area__c.addError('Area__c에 매핑되는 Dealer Account가 존재하지 않습니다.');
                }
                else {
                    tmpId = accountOwnerMap.get(tmpAccount.Id);
                    if(tmpId == null) {
                        targetData.Area__c.addError('Area__c에 매핑되는 Dealer Account의 대리점주가 존재하지 않습니다.');
                    }

                    targetData.BusinessOffice__c        = tmpAccount.BusinessOffice__c;
                    targetData.BusinessOfficeName__c    = String.isEmpty(tmpAccount.BusinessOfficeName__c) ? tmpAccount.BusinessOffice__r.BusinessOfficeName__c : tmpAccount.BusinessOfficeName__c;
                    targetData.OwnerId                  = tmpId;
                    targetData.AccountId__c             = tmpAccount.Id;
                    targetData.ErpCode__c               = tmpAccount.ERPCode__c;
                }

            }
        }

    }

}