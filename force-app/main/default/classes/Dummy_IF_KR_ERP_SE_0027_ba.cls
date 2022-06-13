/****************************************************************************************
  * @filename      : Dummy_IF_KR_ERP_SE_0027_ba
  * @projectname   :
  * @author        : jy.kim
  * @date          : 2020-05-11
  * @group         :
  * @group-content :
  * @description   : [고객파트너정보]
  *                : IF_KR_ERP_SE_0001__c Dummy 에서 SoldTo__c(고객파트너정보) 정보 upsert
  * @tester        :
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2020-05-11      jy.kim          Create
****************************************************************************************/

public class Dummy_IF_KR_ERP_SE_0027_ba extends Dummy_IF_Batch {

    /**
     * Start
     * @param BC : BatchableContext
     *
     * @return Database.QueryLocator
     */
    public override Database.QueryLocator start(Database.BatchableContext BC) {
        //============================================================================
        // 후행 Dummy 데이터 삭제 배치 정보
        //============================================================================
        this.interfaceId = 'IF_KR_ERP_SE_0027';
        this.deleteInfo = new Dummy_IF_Batch.DeleteInfo(
                'IF_KR_ERP_SE_0001__c',
                interfaceId,
                Dummy_IF_Batch.DUMMY_BATCH_PERIOD_TYPE.DAILY,
                this.exeDatetime
        );

        /*
        ErpKUNNR__c	PK	고객번호(판매처)	Text	20
        ErpVKORG__c		영업조직	Text	10
        ErpVTWEG__c		유통채널	Text	10
        ErpSPART__c		제품군 	Text	10
        ErpPARVW__c	PK	파트너기능	Text	10
        ErpPARZA__c		파트너카운트	Text	20
        ErpKUNN2__c	PK	고객번호	Text	20
         */
        return Database.getQueryLocator([
                SELECT
                        Id,
                        ErpKUNNR__c,
                        ErpVKORG__c,
                        ErpVTWEG__c,
                        ErpSPART__c,
                        ErpPARVW__c,
                        ErpPARZA__c,
                        ErpKUNN2__c,
                        isBatchCompleted__c,
                        isBatchError__c,
                        BatchErrorMessage__c
                FROM    IF_KR_ERP_SE_0001__c
                WHERE   InterfaceId__c = 'IF_KR_ERP_SE_0027'
                AND     isBatchCompleted__c = false
                AND     IsBatchError__c = false
        ]);
    }

    /**
     * 수행 로직 구현
     *
     * @param BC : BatchableContext
     * @param targetScope : Batch Size 실행 리스트
     */
    public override void execute(Database.BatchableContext BC, List<SObject> targetScope) {
        //============================================================================
        // 실제 SObject 형변환
        //============================================================================
        final List<IF_KR_ERP_SE_0001__c> scope = (List<IF_KR_ERP_SE_0001__c>)targetScope;

        /*
		* 데이터 수신 후 PK 기준으로 SoldTo__c Upsert
        1)	ErpKUNNR__c : ErpKUNNR__c 필드로 설정
        2)	Account__c : ErpKUNNR__c = Account.ErpCode__c 레코드 Lookup 처리
        3)	ErpVKORG__c : ErpVKORG__c 필드로 설정
        4)	ErpVTWEG__c  : ErpVTWEG__c 필드로 설정
        5)	ErpSPART__c : ErpSPART__c 필드로 설정
        6)	ErpPARVW__c : ErpPARVW__c 필드로 설정
        7)	PartnerFunction__c : ErpPARVW__c가 AG: 판매처, RE: 청구처, RG: 지급처, WE: 납품처
        8)	ErpPARZA__c  : ErpPARZA__c 필드로 설정
        9)	ErpKUNN2__c : ErpKUNN2__c 필드로 설정
        판매처	10)	Partner__c : ErpKUNN2__c = Account.ErpCode__c 레코드 Lookup 처리
        */
        /**
        * Account, SoldTo__c 조회 대상 Set
       */
        set<String> account_Set = new set<String>(); // ErpKUNNR__c, ErpKUNN2__c
        set<String> soldTo_Set = new set<String>();  // ErpKUNNR__c, ErpPARVW__c, ErpKUNN2__c

        for(IF_KR_ERP_SE_0001__c dummy : scope) {
            account_Set.add(dummy.ErpKUNNR__c);
            account_Set.add(dummy.ErpKUNN2__c);
            soldTo_Set.add(dummy.ErpKUNNR__c+'|'+dummy.ErpPARVW__c+'|'+dummy.ErpKUNN2__c);
        }

        /**
         * Account 대상 Query Map
        */
        Map<String, Id> account_Target = new Map<String, Id>(); // Key : Account.ErpCode__c, Value : Id
        for(Account account : [
                SELECT Id, ERPCode__c
                FROM Account
                WHERE ERPCode__c IN :account_Set
        ]) {
            if(!account_Target.containsKey(account.ERPCode__c)) {
                account_Target.put(account.ERPCode__c, account.Id);
            }
        }

        /**
         * SoldTo__c 대상 Query Map (기존 데이터 Update 비교용)
        */
        Map<String, SoldTo__c> soldTo_Target = new Map<String, SoldTo__c>(); // Key : SoldTo__c.Externalkey__c, Value : SoldTo__c
        for(SoldTo__c soldTo : [
                SELECT Id, Externalkey__c, ErpKUNNR__c,Account__c,ErpVKORG__c,ErpVTWEG__c,ErpSPART__c,ErpPARVW__c,ErpPARZA__c,ErpKUNN2__c,PartnerFunction__c
                FROM SoldTo__c
                WHERE Externalkey__c IN :soldTo_Set
        ]) {
            if(!soldTo_Target.containsKey(soldTo.Externalkey__c)) {
                soldTo_Target.put(soldTo.Externalkey__c, soldTo);
            }
        }

        // DML 처리 target List
        List<SoldTo__c> targetList = new List<SoldTo__c>();
        // validation 처리시 비정상 Dummy Data List
        List<SObject> targetBadDummyList = new List<SObject>();
        // Dml 수행 에러 Dummy Data List
        List<SObject> targetDmlDummyList = new List<SObject>();

        SoldTo__c tmpSoldTo;
        Boolean isGoodDummy;

        for(IF_KR_ERP_SE_0001__c dummy : scope) {
            //============================================================================
            // 처음부터 처리여부 true 설정
            //============================================================================
            dummy.isBatchCompleted__c = true;
            isGoodDummy = true;

            //============================================================================
            // 정상 Dummy 데이터 여부
            // ErpKUNNR__c, ErpKUNNR2__c, ErpPARVW__c
            // 위 데이터는 신규생성의 무결성을 위한 required 데이터 임. [중요]
            //============================================================================
            if(String.isBlank(dummy.ErpKUNNR__c) || String.isBlank(dummy.ErpKUNN2__c) || String.isBlank(dummy.ErpPARVW__c) || !account_Target.containsKey(dummy.ErpKUNNR__c) || !account_Target.containsKey(dummy.ErpKUNN2__c)){
                isGoodDummy = false;
            }

            if(isGoodDummy == false) {
                targetBadDummyList.add(Dummy_IF_BatchUtil.setDummyBatchResult(
                        dummy,
                        String.format(
                                Dummy_IF_BatchUtil.DUMMY_BATCH_ERROR_VALID,
                                new String[]{'ErpKUNNR__c,ErpKUNN2__c 매핑 되는 Account ERP Code가 없거나, ErpPARVW__c 값이 없습니다.'}
                        ),
                        this.errorDummyIds
                ));
                continue;
            }

            //============================================================================
            // 판매처(SoldTo__c) 기존 데이터인 경우
            //============================================================================
            if(soldTo_Target.containsKey(dummy.ErpKUNNR__c+'|'+dummy.ErpPARVW__c+'|'+dummy.ErpKUNN2__c)) {
                tmpSoldTo = soldTo_Target.get(dummy.ErpKUNNR__c+'|'+dummy.ErpPARVW__c+'|'+dummy.ErpKUNN2__c);
            }
            //============================================================================
            // 판매처(SoldTo__c) 신규 데이터인 경우
            //============================================================================
            else {
                tmpSoldTo = new SoldTo__c();
                tmpSoldTo.Externalkey__c = dummy.ErpKUNNR__c+'|'+dummy.ErpPARVW__c+'|'+dummy.ErpKUNN2__c;
                tmpSoldTo.ErpKUNNR__c = dummy.ErpKUNNR__c; // PK
                tmpSoldTo.ErpKUNN2__c = dummy.ErpKUNN2__c; // PK
                tmpSoldTo.ErpPARVW__c = dummy.ErpPARVW__c; // PK
                tmpSoldTo.PartnerFunction__c = dummy.ErpPARVW__c;
                tmpSoldTo.Account__c = account_Target.get(dummy.ErpKUNNR__c);
                tmpSoldTo.Partner__c = account_Target.get(dummy.ErpKUNN2__c);
            }
            tmpSoldTo.ErpVKORG__c = dummy.ErpVKORG__c;
            tmpSoldTo.ErpVTWEG__c = dummy.ErpVTWEG__c;
            tmpSoldTo.ErpSPART__c = dummy.ErpSPART__c;
            tmpSoldTo.ErpPARZA__c = dummy.ErpPARZA__c;
            targetList.add(tmpSoldTo);
            targetDmlDummyList.add(dummy);
        }

        /*
         * ================================================================
         * Dummy 상태처리 : validation 체크로 비정상 Dummy Data 리스트를 먼저 update
         * ================================================================
         */
        update targetBadDummyList;

        /*
         * ================================================================
         * Dml 수행 및 Dummy 상태처리 : 에러시 Dummy 상태값 세팅
         * ================================================================
         */
        System.Savepoint sp;
        try {
            sp = Database.setSavepoint();
            upsert targetList;
        }
        catch(Exception e) {
            Database.rollback(sp);
            System.debug(System.LoggingLevel.ERROR, e);
            targetDmlDummyList = Dummy_IF_BatchUtil.setDummyBatchResult(targetDmlDummyList, this.errorDummyIds, e);
        }
        finally {
            update targetDmlDummyList;
        }
    }

    /**
     * 개별적 finish 수행
     * 후행배치가 먼저 수행이 되어야 한다.(에러 상관없이 수행되어야 함.)
     *
     * @param BC Database.BatchableContext
     */
    public override void finish(Database.BatchableContext BC) {
        Database.executeBatch(new Dummy_IF_KR_ERP_SE_0002_ba(), 200);
        super.finish(BC);
    }
}