/****************************************************************************************
  * @filename      : Dummy_IF_KR_PLM_SE_0030_ba
  * @projectname   : 
  * @author        : i2max 
  * @date          : 2020-06-05
  * @group         : 
  * @group-content : 
  * @description   : [설계변경내역-부품목록]
  *                : IF_KR_PLM_SE_0029 -> ProductChangeItem__c : insert
  * @tester        : Dummy_IF_KR_PLM_SE_0030_ba_ts.cls
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author              description
  * ===============================================================
    0.1     2020-06-05               i2max                  Create
*************a***************************************************************************/
public with sharing class Dummy_IF_KR_PLM_SE_0030_ba extends Dummy_IF_Batch {

    /**
     * Start
     *
     * @param BC : BatchableContext
     *
     * @return Database.QueryLocator
     */
    public override Database.QueryLocator start(Database.BatchableContext BC) {
        //============================================================================
        // 후행 Dummy 데이터 삭제 배치 정보
        //============================================================================
        this.interfaceId = 'IF_KR_PLM_SE_0030';
        this.deleteInfo = new Dummy_IF_Batch.DeleteInfo(
                'IF_KR_PLM_SE_0029__c',
                interfaceId,
                Dummy_IF_Batch.DUMMY_BATCH_PERIOD_TYPE.DAILY,
                this.exeDatetime
        );

        /*
        PECN_ID__c	    PK	ECN-NO	        Text	20
        PLANT_ID__c	    PK	플랜트 구분	    Text	20
        PSEQ__c	        PK	순번	            Text	10
        PLEVEL__c		    Level	        Text	10
        PBEFORE_ID__c		변경전 품번	    Text	60
        PBEFORE_NAME__c		변경전 품명	    Text	60
        PBEFORE_QTY__c		변경전 대개QTY	Text	20
        PBEFORE_REV__c		변경전Rev.	    Text	30
        PAFTER_ID__c		변경후 품번	    Text	60
        PAFTER_NAME__c		변경후 품명	    Text	60
        PAFTER_QTY__c		변경후 대개QTY	Text	20
        PAFTER_REV__c		변경후Rev.	    Text	30
        */

        return Database.getQueryLocator([
                SELECT
                        Id,
                        PECN_ID__c,
                        PLANT_ID__c,
                        PSEQ__c,
                        PLEVEL__c,
                        PBEFORE_ID__c,
                        PBEFORE_NAME__c,
                        PBEFORE_QTY__c,
                        PBEFORE_REV__c,
                        PAFTER_ID__c,
                        PAFTER_NAME__c,
                        PAFTER_QTY__c,
                        PAFTER_REV__c,
                        isBatchCompleted__c,
                        isBatchError__c,
                        BatchErrorMessage__c
                FROM    IF_KR_PLM_SE_0029__c
                WHERE   InterfaceId__c = :this.interfaceId
                AND     isBatchCompleted__c = FALSE
                AND     isBatchError__c = FALSE
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
        final List<IF_KR_PLM_SE_0029__c> scope = (List<IF_KR_PLM_SE_0029__c>) targetScope;

        /*
        * 데이터가 수신되면 PK 기준으로 Insert
        1)	External key (Apex) : PECN_ID__c + PLANT_ID__c + PSEQ__c
        2)	Name : PECN_ID__c + "_" + PSEQ__c
          ** 더미 필드와 동일한 ProductChangeItem__c 필드 매핑
        */


        //============================================================================
        // PK 기준 Dummy Set
        //============================================================================
        Set<String> dummyByPK_Set = new set<String>();  // Key 매핑(PK : PECN_ID__c, PLANT_ID__c)
        for (IF_KR_PLM_SE_0029__c dummy : scope) {
            dummyByPK_Set.add(dummy.PECN_ID__c + '|' + dummy.PLANT_ID__c);
        }

        //============================================================================
        // 존재하는 PK 기준 이미 생성된 Master 설계변경(ProductChange__c) Set
        //============================================================================
        Map<String, ProductChange__c> productChangePKMap = new Map<String, ProductChange__c>(); // Key 매핑(FK : PECN_ID__c, PLANT_ID__c)
        for (ProductChange__c productChange : [
                SELECT  Id, Externalkey__c
                FROM    ProductChange__c
                WHERE   Externalkey__c IN :dummyByPK_Set
        ]) {
            if(String.isNotBlank(productChange.Externalkey__c) && !productChangePKMap.containsKey(productChange.Externalkey__c)) {
                productChangePKMap.put(productChange.Externalkey__c, productChange);
            }
        }

        /*
         * ================================================================
         * 데이터 DML 처리를 위한 3개의 기본 변수
         * ================================================================
         */
        // DML 처리 target List
        List<SObject> targetList = new List<SObject>();

        // validation 처리시 비정상 Dummy Data List
        List<SObject> targetBadDummyList = new List<SObject>();
        // Dml 수행 에러 Dummy Data List
        List<SObject> targetDmlDummyList = new List<SObject>();

        ProductChangeItem__c tmpProductChangeItem;
        ProductChange__c tmpExistProductChange;
        Boolean isGoodDummy, isExistRecord;
        String BadDummyMessage;

        for (IF_KR_PLM_SE_0029__c dummy : scope) {
            //============================================================================
            // 처음부터 처리여부 true 설정
            //============================================================================
            dummy.isBatchCompleted__c = true;

            // Master 데이터 확인 (M : 설계변경)
            tmpExistProductChange = productChangePKMap.get(dummy.PECN_ID__c + '|' + dummy.PLANT_ID__c);

            // Master 데이터 여부
            isExistRecord = tmpExistProductChange != null ? true : false;

            /*
             * ================================================================
             * 정상 Dummy 데이터 여부
             * 위 데이터는 신규생성의 무결성을 위한 required 데이터 임. [중요]
             * PECN_ID__c, PLANT_ID__c, PSEQ__c 이 필수 항목
             * Master 데이터 확인 (M : 설계변경)
             * ================================================================
             */
            isGoodDummy = (String.isNotBlank(dummy.PECN_ID__c)
                        && String.isNotBlank(dummy.PLANT_ID__c)
                        && String.isNotBlank(dummy.PSEQ__c)
                        && isExistRecord);

            if (isGoodDummy == false) {
                if (String.isBlank(dummy.PECN_ID__c) || String.isBlank(dummy.PLANT_ID__c) && String.isBlank(dummy.PSEQ__c)) {
                    BadDummyMessage = 'IF.PECN_ID__c is NULL or IF.PLANT_ID__c is NULL or IF.PSEQ__c is NULL';
                } else if (!isExistRecord) {
                    BadDummyMessage = '설계변경(ProductChange__c)이 없음 : Externalkey__c = [' + dummy.PECN_ID__c + '|' + dummy.PLANT_ID__c + ']';
                }

                targetBadDummyList.add(Dummy_IF_BatchUtil.setDummyBatchResult(
                        dummy,
                        String.format(
                                Dummy_IF_BatchUtil.DUMMY_BATCH_ERROR_VALID,
                                new String[]{
                                        BadDummyMessage
                                }
                        ),
                        this.errorDummyIds
                ));
                continue;
            } else {
                tmpProductChangeItem = new ProductChangeItem__c();
                //============================================================================
                // 데이터 매핑
                //============================================================================
                tmpProductChangeItem.Name               = dummy.PECN_ID__c + '_' + dummy.PSEQ__c;
                tmpProductChangeItem.Externalkey__c     = dummy.PECN_ID__c +'|'+dummy.PLANT_ID__c +'|'+dummy.PSEQ__c;
                tmpProductChangeItem.ProductChangeId__c = (tmpExistProductChange != null) ? tmpExistProductChange.Id : null;
                tmpProductChangeItem.PECN_ID__c         = dummy.PECN_ID__c;
                tmpProductChangeItem.PLANT_ID__c        = dummy.PLANT_ID__c;
                tmpProductChangeItem.PSEQ__c            = dummy.PSEQ__c;
                tmpProductChangeItem.PLEVEL__c          = dummy.PLEVEL__c;
                tmpProductChangeItem.PBEFORE_ID__c      = dummy.PBEFORE_ID__c;
                tmpProductChangeItem.PBEFORE_NAME__c    = dummy.PBEFORE_NAME__c;
                tmpProductChangeItem.PBEFORE_QTY__c     = dummy.PBEFORE_QTY__c;
                tmpProductChangeItem.PBEFORE_REV__c     = dummy.PBEFORE_REV__c;
                tmpProductChangeItem.PAFTER_ID__c       = dummy.PAFTER_ID__c;
                tmpProductChangeItem.PAFTER_NAME__c     = dummy.PAFTER_NAME__c;
                tmpProductChangeItem.PAFTER_QTY__c      = dummy.PAFTER_QTY__c;
                tmpProductChangeItem.PAFTER_REV__c      = dummy.PAFTER_REV__c;

                targetList.add(tmpProductChangeItem);
                targetDmlDummyList.add(dummy);
            }
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

            /*System.debug('ProductChangeItem__c INSERT ========================================');
            System.debug(JSON.serialize(targetList));
            System.debug('========================================');*/
            insert targetList;
        } catch (Exception e) {
            Database.rollback(sp);
            System.debug(System.LoggingLevel.ERROR, '::::: ERROR LOG ' + e);
            targetDmlDummyList = Dummy_IF_BatchUtil.setDummyBatchResult(targetDmlDummyList, this.errorDummyIds, e);
        } finally {
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
        Database.executeBatch(new Dummy_IF_KR_PLM_SE_0031_ba(), 200);
        super.finish(BC);
    }
}