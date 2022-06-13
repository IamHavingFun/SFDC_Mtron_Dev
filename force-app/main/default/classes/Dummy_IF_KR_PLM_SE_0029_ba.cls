/****************************************************************************************
  * @filename      : Dummy_IF_KR_PLM_SE_0029_ba
  * @projectname   :
  * @author        : i2max
  * @date          : 2020-06-05
  * @group         :
  * @group-content :
  * @description   : [설계변경내역-헤더]
  *                : IF_KR_PLM_SE_0029 -> ProductChange__c : insert, delete
  * @tester        : Dummy_IF_KR_PLM_SE_0029_ba_ts.cls
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author              description
  * ===============================================================
    0.1     2020-06-05              i2max                  Create
*************a***************************************************************************/
public with sharing class Dummy_IF_KR_PLM_SE_0029_ba extends Dummy_IF_Batch {

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
        this.interfaceId = 'IF_KR_PLM_SE_0029';
        this.deleteInfo = new Dummy_IF_Batch.DeleteInfo(
                'IF_KR_PLM_SE_0029__c',
                interfaceId,
                Dummy_IF_Batch.DUMMY_BATCH_PERIOD_TYPE.DAILY,
                this.exeDatetime
        );

        /*
        PECN_ID__c	        PK	ECN-NO	                Text	20
        PLANT_ID__c	        PK	플랜트 구분	            Text	20
        PECN_NAME__c		    제목	                    Text	150
        PWRITER__c		        작성자	                Text	20
        PECR_ID__c		        ECR ID	                Text	20
        PECN_TYPE__c		    설변유형	                Text	30
        PECN_REASON__c		    변경 목적	            Text	30
        PPRODUCTSGROUP__c		제품 그룹	            Text	40
        PMODEL_ID__c		    시리즈	                Text	30
        PAPPLY_DATE__c		    적용일	                Text	30
        PUNITEFFECTIVITY__c		적용호기	                Text	20
        PDESC__c		        설명	                    Text	4000
        PASISDESC__c		    AsIs 설명	            Text	4000
        PTOBEDESC__c		    ToBe 설명	            Text	4000
        POPTCHGDESC__c		    Option Change 설명	    Text	4000
        PREGISTRATION_DATE__c	등록일(yyyyMMddHHmmss )	Text	20
        DELETE_FLAG__c		    삭제 플래그	            Text	2
        RELEASED_STATUS__c		결재 상태	            Text	20
        RELEASED_DATE__c		ECN 결재완료일자(yyyyMMdd) Text	20
         */
        return Database.getQueryLocator([
                SELECT
                        Id,
                        PECN_ID__c,
                        PLANT_ID__c,
                        PECN_NAME__c,
                        PWRITER__c,
                        PECR_ID__c,
                        PECN_TYPE__c,
                        PECN_REASON__c,
                        PPRODUCTSGROUP__c,
                        PMODEL_ID__c,
                        PAPPLY_DATE__c,
                        PUNITEFFECTIVITY__c,
                        PDESC__c,
                        PASISDESC__c,
                        PTOBEDESC__c,
                        POPTCHGDESC__c,
                        PREGISTRATION_DATE__c,
                        DELETE_FLAG__c,
                        RELEASED_STATUS__c,
                        RELEASED_DATE__c,
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
        final List<IF_KR_PLM_SE_0029__c> scope = (List<IF_KR_PLM_SE_0029__c>)targetScope;

        // OwnerId(소유자) 정의 : UserInfo.getUserId() - admin
        /*
        * 데이터가 수신되면 PK 기준으로 Insert
        * 삭제 플래그 =  체크된 레코드는 삭제
        1)	External key (Apex) : PECN_ID__c + PLANT_ID__c
        2)	Name : PECN_ID__c
        3)	대리점 공개 : 미확정
        4)	PECN_NAME__c : (PMODEL_ID__c) + PECN_NAME__c
            ** 더미 필드와 동일한 ProductChange__c 필드 매핑
        */


        //============================================================================
        // PK 기준 Dummy Set
        //============================================================================
        Set<String> dummyByPK_Set = new set<String>();  // Key 매핑(PK : PECN_ID__c, PLANT_ID__c)
        for(IF_KR_PLM_SE_0029__c dummy : scope) {
            dummyByPK_Set.add(dummy.PECN_ID__c+'|'+dummy.PLANT_ID__c);
        }

        //============================================================================
        // 존재하는 PK 기준 이미 생성된 설계변경(ProductChange__c) Set
        //============================================================================
        Map<String, ProductChange__c> productChangePKMap = new Map<String, ProductChange__c>(); // Key 매핑(FK : PECN_ID__c, PLANT_ID__c)
        for(ProductChange__c productChange : [
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
        List<SObject> targetInsList = new List<SObject>();
        //List<ProductChange__c> targetInsList = new List<ProductChange__c>();
        List<SObject> targetDelList = new List<SObject>();
        // validation 처리시 비정상 Dummy Data List
        List<SObject> targetBadDummyList = new List<SObject>();
        // Dml 수행 에러 Dummy Data List
        List<SObject> targetDmlDummyList = new List<SObject>();

        ProductChange__c tmpProductChange, tmpExistProductChange;
        Boolean isGoodDummy, isGoodDate, isExistRecord;
        Date tmpReleased_date;
        Datetime tmpPregistration_date;

        for(IF_KR_PLM_SE_0029__c dummy : scope) {
            //============================================================================
            // 처음부터 처리여부 true 설정
            //============================================================================
            dummy.isBatchCompleted__c = true;

            //============================================================================
            // 날짜 형식 체크
            //============================================================================
            isGoodDate = true;
            try {
                tmpPregistration_date   = String.isNotBlank(dummy.PREGISTRATION_DATE__c) ? Dummy_IF_BatchUtil.getIFDateTime(dummy.PREGISTRATION_DATE__c) : null;
                tmpReleased_date        = String.isNotBlank(dummy.RELEASED_DATE__c) ? Dummy_IF_BatchUtil.getIFDate(dummy.RELEASED_DATE__c) : null;
            }
            catch(Exception e) {
                isGoodDate = false;
            }

            // 기존 데이터
            tmpExistProductChange = productChangePKMap.get(dummy.PECN_ID__c+'|'+dummy.PLANT_ID__c);

            // 기존 데이터 여부
            isExistRecord = tmpExistProductChange != null ? true : false;

            /*
             * ================================================================
             * 정상 Dummy 데이터 여부
             * 위 데이터는 신규생성의 무결성을 위한 required 데이터 임. [중요]
             * PECN_ID__c, PLANT_ID__c 이 필수 항목
             * PREGISTRATION_DATE__c, RELEASED_DATE__c 날짜 형식 체크
             * ================================================================
             */
            isGoodDummy = (String.isNotBlank(dummy.PECN_ID__c)
                        && String.isNotBlank(dummy.PLANT_ID__c)
                        && isGoodDate);

            if(isGoodDummy == false) {
                targetBadDummyList.add(Dummy_IF_BatchUtil.setDummyBatchResult(
                        dummy,
                        String.format(
                                Dummy_IF_BatchUtil.DUMMY_BATCH_ERROR_VALID,
                                new String[]{'IF.PECN_ID__c is NULL or IF.PLANT_ID__c is NULL or IF.PREGISTRATION_DATE__c, IF.RELEASED_DATE__c Format Error or'}
                        ),
                        this.errorDummyIds
                ));
                continue;
            }

            //============================================================================
            // 삭제 데이터인 경우
            //============================================================================
            // 삭제 대상 레코드가 없을 경우
            if(dummy.DELETE_FLAG__c == 'Y' && isExistRecord == false) {
                targetBadDummyList.add(Dummy_IF_BatchUtil.setDummyBatchResult(
                        dummy,
                        String.format(
                                Dummy_IF_BatchUtil.DUMMY_BATCH_ERROR_VALID,
                                new String[]{'설계변경(ProductChange__c)이 없음 : Externalkey__c = [' + dummy.PECN_ID__c + '|' + dummy.PLANT_ID__c + ']'}
                        ),
                        this.errorDummyIds
                ));
                continue;
            }

            // 삭제 대상 레코드가 있을 경우
            if (dummy.DELETE_FLAG__c == 'Y' && isExistRecord == true) {
                targetDelList.add(tmpExistProductChange);
            }
            //============================================================================
            // 신규 데이터인 경우
            //============================================================================
            else {
                tmpProductChange = new ProductChange__c();
                //============================================================================
                // 데이터 매핑
                //============================================================================
                tmpProductChange.Externalkey__c         = dummy.PECN_ID__c +'|'+dummy.PLANT_ID__c;
                tmpProductChange.Name                   = dummy.PECN_ID__c;
                tmpProductChange.SetDealerPublic__c     = '미확정';
                tmpProductChange.PECN_NAME__c           = '(' + dummy.PMODEL_ID__c + ') ' + dummy.PECN_NAME__c;

                tmpProductChange.PECN_ID__c             = dummy.PECN_ID__c;
                tmpProductChange.PLANT_ID__c            = dummy.PLANT_ID__c;
                tmpProductChange.PWRITER__c             = dummy.PWRITER__c;
                tmpProductChange.PECR_ID__c             = dummy.PECR_ID__c;
                tmpProductChange.PECN_TYPE__c           = dummy.PECN_TYPE__c;
                tmpProductChange.PECN_REASON__c         = dummy.PECN_REASON__c;
                tmpProductChange.PPRODUCTSGROUP__c      = dummy.PPRODUCTSGROUP__c;
                tmpProductChange.PMODEL_ID__c           = dummy.PMODEL_ID__c;
                tmpProductChange.PAPPLY_DATE__c         = dummy.PAPPLY_DATE__c;
                tmpProductChange.PUNITEFFECTIVITY__c    = dummy.PUNITEFFECTIVITY__c;
                tmpProductChange.PDESC__c               = dummy.PDESC__c;
                tmpProductChange.PASISDESC__c           = dummy.PASISDESC__c;
                tmpProductChange.PTOBEDESC__c           = dummy.PTOBEDESC__c;
                tmpProductChange.POPTCHGDESC__c         = dummy.POPTCHGDESC__c;
                tmpProductChange.PREGISTRATION_DATE__c  = tmpPregistration_date;
                //tmpProductChange.DELETE_FLAG__c         = Dummy_IF_BatchUtil.getBooleanFromString(dummy.DELETE_FLAG__c);
                tmpProductChange.RELEASED_STATUS__c     = dummy.RELEASED_STATUS__c;
                tmpProductChange.RELEASED_DATE__c       = tmpReleased_date;

                targetInsList.add(tmpProductChange);
            }
            //============================================================================
            // target or dummy 데이터 리스트 add
            //============================================================================
            targetDmlDummyList.add(dummy);
        }

        /*
         * ================================================================
         * Dummy 상태처리 : validation 체크로 비정상 Dummy Data 리스트를 먼저 update
         * ================================================================
         */
        update targetBadDummyList;
        System.debug('ProductChange__c targetBadDummyList ========================================');
        System.debug(JSON.serialize(targetBadDummyList));
        System.debug('========================================');

        /*
         * ================================================================
         * Dml 수행 및 Dummy 상태처리 : 에러시 Dummy 상태값 세팅
         * ================================================================
         */
        System.Savepoint sp;
        try {
            sp = Database.setSavepoint();
            System.debug('ProductChange__c INSERT ========================================');
            System.debug(JSON.serialize(targetInsList));
            System.debug('========================================');

            System.debug('ProductChange__c DELETE ========================================');
            System.debug(JSON.serialize(targetDelList));
            System.debug('========================================');
            insert targetInsList;
            delete targetDelList;
            //upsert targetInsList Externalkey__c;
        }
        catch(Exception e) {
            Database.rollback(sp);
            System.debug(System.LoggingLevel.ERROR, '::::: ERROR LOG ' + e);
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
        Database.executeBatch(new Dummy_IF_KR_PLM_SE_0030_ba(), 200);
        super.finish(BC);
    }
}