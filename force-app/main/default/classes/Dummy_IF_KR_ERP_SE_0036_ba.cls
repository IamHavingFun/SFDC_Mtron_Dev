/****************************************************************************************
  * @filename      : Dummy_IF_KR_ERP_SE_0036_ba
  * @projectname   :
  * @author        : i2max
  * @date          : 2020-06-22
  * @group         :
  * @group-content :
  * @description   : [주문상태]
  *                : IF_KR_ERP_SE_0036 Dummy -> Order__c : update
  * @tester        : Dummy_IF_KR_ERP_SE_0036_ba_ts.cls
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author              description
  * ===============================================================
    0.1     2020-06-22                i2max                  Create
*************a***************************************************************************/
public class Dummy_IF_KR_ERP_SE_0036_ba extends Dummy_IF_Batch {
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
        this.interfaceId = 'IF_KR_ERP_SE_0036';
        this.deleteInfo = new Dummy_IF_Batch.DeleteInfo(
                'IF_KR_ERP_SE_0036__c',
                interfaceId,
                Dummy_IF_Batch.DUMMY_BATCH_PERIOD_TYPE.DAILY,
                this.exeDatetime
        );

        /*
        OrderID__c	    PK	세일즈포스 채번 주문ID	Text	20
        ErpABGRU__c		    ERP 거부사유	        Text	2
        */

        return Database.getQueryLocator([
                SELECT
                        Id,
                        OrderID__c,
                        ErpABGRU__c,
                        isBatchCompleted__c,
                        isBatchError__c,
                        BatchErrorMessage__c
                FROM IF_KR_ERP_SE_0036__c
                WHERE InterfaceId__c = :this.interfaceId
                AND isBatchCompleted__c = FALSE
                AND isBatchError__c = FALSE
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
        final List<IF_KR_ERP_SE_0036__c> scope = (List<IF_KR_ERP_SE_0036__c>) targetScope;
        Set<String> orderIdSet = new Set<String>();
        Map<String, Order__c> orderMap = new Map<String, Order__c>();

        /*
        [Order__c]
        OrderID__c      : 주문ID
        ErpABGRU__c		: IF.ErpABGRU__c
        if ErpABGRU__c = 01 ~ 11 이면 주문.상태(Status__c) = "종료" 설정, 주문.주문취소(isOrderCancel__c) = True 설정
            [01 ~ 11] 주문 삭제, [95] 수주 손익 미결재, [NN] 기타
        */

        for (IF_KR_ERP_SE_0036__c dummy : scope) {
            orderIdSet.add(dummy.OrderID__c);
        }

        for (Order__c o : [
                SELECT  Id,
                        ErpABGRU__c,
                        Status__c,
                        isOrderCancel__c
                FROM Order__c
                WHERE Id IN :orderIdSet
        ]) {
            if (!orderMap.containsKey(o.Id)) {
                orderMap.put(o.Id, o);
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

        Order__c tmpOrder;
        Boolean isGoodDummy, isExistRecord;

        // ERP 거부사유 코드
        Set<String> erpABGURCodeSet = new Set<String>{
                '01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11'
        };

        /*
         * ================================================================
         * 대상건 : 전체 데이터
         * ================================================================
         */
        for (IF_KR_ERP_SE_0036__c dummy : scope) {
            //============================================================================
            // 처음부터 처리여부 true 설정
            //============================================================================
            dummy.isBatchCompleted__c = true;

            // 기존 데이터
            tmpOrder = orderMap.get(dummy.OrderID__c);
            // 기존 데이터 여부
            isExistRecord = tmpOrder != null ? true : false;

            /*
             * ================================================================
             * 정상 Dummy 데이터 여부
             * 위 데이터는 신규생성의 무결성을 위한 required 데이터 임. [중요]

             * ================================================================
             */
            isGoodDummy = isExistRecord;

            if (isGoodDummy == false) {
                targetBadDummyList.add(Dummy_IF_BatchUtil.setDummyBatchResult(
                        dummy,
                        String.format(
                                Dummy_IF_BatchUtil.DUMMY_BATCH_ERROR_VALID,
                                new String[]{
                                        'OrderID Not Match'
                                }
                        ),
                        this.errorDummyIds
                ));
                continue;
            }
            //============================================================================
            // 정상 Dummy 데이터인 경우
            //============================================================================
            else {
                ////////////////////////////////////// Order List
                tmpOrder.ErpABGRU__c = dummy.ErpABGRU__c;
                if (erpABGURCodeSet.contains(dummy.ErpABGRU__c)) {
                    tmpOrder.Status__c = '종료';
                    tmpOrder.SystemStatus__c = '종료';    // 파트너 커뮤니티 사용자가 임의로 상태 변경하는 것을 방지하는 목적
                    tmpOrder.isOrderCancel__c = true;
                }
                targetList.add(tmpOrder);

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
            update targetList;
        } catch (Exception e) {
            Database.rollback(sp);
            System.debug(System.LoggingLevel.ERROR, '::::: ERROR LOG ' + e);
            targetDmlDummyList = Dummy_IF_BatchUtil.setDummyBatchResult(targetDmlDummyList, this.errorDummyIds, e);
        } finally {
            update targetDmlDummyList;
        }
    }

    /**
     * finish
     * 자신만의 처리사항이 있을 경우 overrid 구현할 것
     * @param BC : BatchableContext
     */
    public override void finish(Database.BatchableContext BC) {
        //============================================================================
        // super의 공통 finish 수행
        //============================================================================
        super.finish(BC);
        //============================================================================
        // 자신만의 finish 수행
        //============================================================================
    }
}