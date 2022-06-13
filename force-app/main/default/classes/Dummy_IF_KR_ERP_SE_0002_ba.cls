/****************************************************************************************
  * @filename      : Dummy_IF_KR_ERP_SE_0002_ba
  * @projectname   : LS
  * @author        : Park HE
  * @date          : 2020-05-11
  * @group         :
  * @group-content :
  * @description   :
  * @tester        :
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                    author          description
  * ===============================================================
    0.1     2020-05-11             Park HE         Create
****************************************************************************************/

public with sharing class Dummy_IF_KR_ERP_SE_0002_ba extends Dummy_IF_Batch{
    public String query;
    public Boolean isNextBatch = true;

    public Dummy_IF_KR_ERP_SE_0002_ba() {
        this(null);
    }

    public Dummy_IF_KR_ERP_SE_0002_ba(final String query) {
        this(query, true);
    }

    public Dummy_IF_KR_ERP_SE_0002_ba(final String query, final Boolean isNextBatch) {
        this.query = query;
        this.isNextBatch = isNextBatch;
    }

    /**
     *
     * start
     * @param BC : BatchableContext
     *
     * @return
     */
    public override Database.QueryLocator start(Database.BatchableContext BC) {
        //============================================================================
        // 후행 Dummy 데이터 삭제 배치 정보
        //============================================================================
        this.interfaceId = 'IF_KR_ERP_SE_0002';
        this.deleteInfo = new Dummy_IF_Batch.DeleteInfo(
                'IF_KR_ERP_SE_0001__c',
                interfaceId,
                Dummy_IF_Batch.DUMMY_BATCH_PERIOD_TYPE.DAILY,
                this.exeDatetime
        );

        if(String.isNotBlank(this.query)) {
            return Database.getQueryLocator(this.query);
        } else {
            return Database.getQueryLocator([
                    SELECT
                            Id,
                            ERPCode__c,
                            CollateralAmount__c,
                            CreditLimit__c,
                            CreditRating__c,
                            LimitUsage__c,
                            NormalBonds__c,
                            OverdueBond__c,
                            OverdueLessOneMonth__c,
                            OverdueOneTwoMonths__c,
                            OverdueOneYear__c,
                            OverdueRatio__c,
                            OverdueSixMonths__c,
                            OverdueTwoThreeMonths__c,
                            TotalBonds__c
                    FROM IF_KR_ERP_SE_0001__c
                    WHERE InterfaceId__c = :this.interfaceId
                    AND isBatchCompleted__c = FALSE
            ]);
        }
    }
    public override void execute(Database.BatchableContext BC, List<SObject> targetScope) {
        //============================================================================
        // 실제 SObject 형변환
        //============================================================================
        final List<IF_KR_ERP_SE_0001__c> scope = (List<IF_KR_ERP_SE_0001__c>)targetScope;
        Set<String> erpCodeSet = new Set<String>();
        Map<String, Account> accountMap = new Map<String, Account>();

        for(IF_KR_ERP_SE_0001__c dummy : scope) {
            erpCodeSet.add(dummy.ErpCode__c);
        }
        for(Account a : [
                SELECT  Id, ERPCode__c,
                        OwnerId, // Task 생성을 위해 OwnerId 추가
                        CollateralAmt__c,
                        CreditLimit__c,
                        CreditRating__c,
                        LimitUsageAmt__c,
                        NormalBonds__c,
                        OverdueBond__c,
                        OverdueLessOneMonth__c,
                        OverdueOneTwoMonths__c,
                        OverdueOneYear__c,
                        OverdueRatio__c,
                        OverdueSixMonths__c,
                        OverdueTwoThreeMonths__c,
                        TotalBonds__c
                FROM Account
                WHERE ERPCode__c IN :erpCodeSet
        ]) {
            if(!accountMap.containsKey(a.ERPCode__c)) {
                accountMap.put(a.ERPCode__c, a);
            }
        }

        // DML 처리 target List
        List<Account> targetList = new List<Account>();
        // validation 처리시 비정상 Dummy Data List
        List<SObject> targetBadDummyList = new List<SObject>();
        // Dml 수행 에러 Dummy Data List
        List<SObject> targetDmlDummyList = new List<SObject>();

        Account tempAccount;
        Boolean isGoodDummy;

        /*
         * ================================================================
         * 대상건 :
         * ================================================================
         */
        for(IF_KR_ERP_SE_0001__c dummy : scope) {
            //============================================================================
            // 처음부터 처리여부 true 설정
            //============================================================================
            dummy.isBatchCompleted__c = true;

            isGoodDummy = true;
            List<String> errorComments = new List<String>();
            if(String.isBlank(dummy.ERPCode__c) || !accountMap.containsKey(dummy.ErpCode__c)){
                isGoodDummy = false;
                if(String.isBlank(dummy.ERPCode__c)) errorComments.add('Dummy ERPCODE 없음');
                if(!accountMap.containsKey(dummy.ERPCode__c)) errorComments.add('Account 없음 = ['+dummy.ERPCode__c+']');
                dummy.BatchErrorComment__c = String.join(errorComments, ', ');
            }

            if(isGoodDummy == false) {
                targetBadDummyList.add(Dummy_IF_BatchUtil.setDummyBatchResult(
                        dummy,
                        String.format(
                                Dummy_IF_BatchUtil.DUMMY_BATCH_ERROR_VALID,
                                new String[]{'ErpCode 없음'}
                        ),
                        this.errorDummyIds
                ));

                continue;
            }

            tempAccount = accountMap.get(dummy.ErpCode__c);

            tempAccount.CollateralAmt__c = dummy.CollateralAmount__c;
            tempAccount.CreditLimit__c = dummy.CreditLimit__c;
            tempAccount.CreditRating__c = dummy.CreditRating__c;
            tempAccount.LimitUsageAmt__c = dummy.LimitUsage__c;
            tempAccount.NormalBonds__c = dummy.NormalBonds__c;
            tempAccount.OverdueBond__c = dummy.OverdueBond__c;
            tempAccount.OverdueLessOneMonth__c = dummy.OverdueLessOneMonth__c;
            tempAccount.OverdueOneTwoMonths__c = dummy.OverdueOneTwoMonths__c;
            tempAccount.OverdueOneYear__c = dummy.OverdueOneYear__c;
            tempAccount.OverdueRatio__c = dummy.OverdueRatio__c;
            tempAccount.OverdueSixMonths__c = dummy.OverdueSixMonths__c;
            tempAccount.OverdueTwoThreeMonths__c = dummy.OverdueTwoThreeMonths__c;
            tempAccount.TotalBonds__c = dummy.TotalBonds__c;

            targetList.add(tempAccount);
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
            Map<Id, Account> distinctMapForTargetUpdList = new Map<Id, Account>();
            if(!targetList.isEmpty()) {
                distinctMapForTargetUpdList.putAll(targetList);
                update distinctMapForTargetUpdList.values();
            }
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
        //============================================================================
        // 후행 삭제
        //============================================================================
        if(this.isNextBatch)    Database.executeBatch(new Dummy_IF_KR_ERP_SE_0028_ba(), 200);
        super.finish(BC);
    }
}