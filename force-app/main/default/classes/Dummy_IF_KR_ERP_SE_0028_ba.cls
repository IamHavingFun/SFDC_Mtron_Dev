/****************************************************************************************
  * @filename      : Dummy_IF_KR_ERP_SE_0028_ba
  * @projectname   :
  * @author        : i2max
  * @date          : 2020-05-11
  * @group         :
  * @group-content :
  * @description   : [자재정보]
  *                : IF_KR_ERP_SE_0003 -> Product : Insert, Update
  * @tester        : Dummy_IF_KR_ERP_SE_0028_ba_ts.cls
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2020-05-11      i2max          Create
*************a***************************************************************************/

public with sharing class Dummy_IF_KR_ERP_SE_0028_ba extends Dummy_IF_Batch{

    public String query;
    public Boolean isNextBatch = true;

    public Dummy_IF_KR_ERP_SE_0028_ba() {
        this(null);
    }

    public Dummy_IF_KR_ERP_SE_0028_ba(final String query) {
        this(query, true);
    }

    public Dummy_IF_KR_ERP_SE_0028_ba(final String query, final Boolean isNextBatch) {
        this.query = query;
        this.isNextBatch = isNextBatch;
    }
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
        this.interfaceId = 'IF_KR_ERP_SE_0028';
        this.deleteInfo = new Dummy_IF_Batch.DeleteInfo(
                'IF_KR_ERP_SE_0003__c',
                interfaceId,
                Dummy_IF_Batch.DUMMY_BATCH_PERIOD_TYPE.DAILY,
                this.exeDatetime
        );

        /*
        ErpVKORG__c		    영업조직	    Text	10	3000
        ErpVTWEG__c		    유통채널	    Text	10	10
        ErpWERKS__c		    플랜트	    Text	10	3602
        ProductCode__c	PK	제품코드	    Text	20
        ErpMAKTX__c		    ERP 자재명 	Text	50	하단
        ErpMTART__c		    ERP 자재유형  Text	10
        MATGR__c            ERP 자재 그룹핑.
        */

        if (String.isNotBlank(this.query)) {
            return Database.getQueryLocator(this.query);
        } else {
            return Database.getQueryLocator([
                    SELECT
                            Id,
                            ProductCode__c,
                            ErpMAKTX__c,
                            MATGR__c,
                            isBatchCompleted__c,
                            isBatchError__c,
                            BatchErrorMessage__c
                    FROM IF_KR_ERP_SE_0003__c
                    WHERE InterfaceId__c = :this.interfaceId
                    AND MA_NORMAL_YN__c = NULL
                    AND isBatchCompleted__c = FALSE
                    AND isBatchError__c = FALSE
            ]);
        }
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
        final List<IF_KR_ERP_SE_0003__c> scope = (List<IF_KR_ERP_SE_0003__c>)targetScope;

        /*
        * ProductCode__c 기준으로 Product Insert, Upsert
            1)	IsActive : FALSE		                    신규
            2)	ProductCode : ProductCode__c 필드로 설정		신규	    수정
            3)	Type__c : Null			                    신규
            4)	ErpMAKTX__c : ErpMAKTX__c 필드로 설정			신규	    수정
            5)	Name : ErpMAKTX__c 필드로 설정	            신규	    수정
        PK)	6)	ExternalId__c :	ProductCode__c	            신규  	수정
            7)	ListPrice__c = 0 설정			            신규
                ** SE 담당자는 Type__c = null & isActive = False 인 건은 ERP에서 제품정보 수신만 한 건 입니다. 수기 처리 필요..
        * */


        //============================================================================
        // ProductCode 기준 Dummy 맵
        //============================================================================
        Map<String, IF_KR_ERP_SE_0003__c> DummyByProductCode = new Map<String, IF_KR_ERP_SE_0003__c>();
        String productCode;
        for(IF_KR_ERP_SE_0003__c dummy : scope) {
            // 일단 lpad 하여 비교
            productCode = Dummy_IF_BatchUtil.getProductCodeLpad(dummy.ProductCode__c);
            if(String.isNotBlank(productCode) && !DummyByProductCode.containsKey(productCode)) {
                DummyByProductCode.put(productCode, dummy);
            }
        }

        //============================================================================
        // 존재하는 ProductCode 기준 이미 생성된 Product 맵
        //============================================================================
        Map<String, Product2> ProductByProductCode = new Map<String, Product2>();
        for(Product2 product : [
                SELECT  Id,
                        ProductCode
                FROM    Product2
                WHERE   ProductCode IN :DummyByProductCode.keySet()
        ]) {
            productCode = Dummy_IF_BatchUtil.getProductCodeLpad(product.ProductCode);
            if(String.isNotBlank(productCode) && !ProductByProductCode.containsKey(productCode)) {
                ProductByProductCode.put(product.ProductCode, product);
            }
        }

        /*
         * ================================================================
         * 데이터 DML 처리를 위한 3개의 기본 변수
         * ================================================================
         */
        // DML 처리 target List
        List<SObject> targetInsList = new List<SObject>();
        List<SObject> targetUpdList = new List<SObject>();
        // validation 처리시 비정상 Dummy Data List
        List<SObject> targetBadDummyList = new List<SObject>();
        // Dml 수행 에러 Dummy Data List
        List<SObject> targetDmlDummyList = new List<SObject>();

        Product2 tmpProduct, tmpExistProduct;
        Boolean isGoodDummy, isExistRecord;
        List<String> errorComments = new List<String>();

        for(IF_KR_ERP_SE_0003__c dummy : scope) {
            //============================================================================
            // 처음부터 처리여부 true 설정
            //============================================================================
            dummy.isBatchCompleted__c = true;

            // productCode를 lpad 하여 처리
            productCode = Dummy_IF_BatchUtil.getProductCodeLpad(dummy.ProductCode__c);
            // 기존 데이터
            tmpExistProduct = ProductByProductCode.get(productCode);
            // 기존 데이터 여부
            isExistRecord = tmpExistProduct != null ? true : false;


            /*
             * ================================================================
             * 정상 Dummy 데이터 여부             *
             * 위 데이터는 신규생성의 무결성을 위한 required 데이터 임. [중요]
             * ProductCode__c 이 필수 항목
             * ================================================================
             */
            isGoodDummy = (String.isNotBlank(dummy.ProductCode__c));

            errorComments = new List<String>();
            if (isGoodDummy == false) {
                if(String.isBlank(dummy.ProductCode__c)) errorComments.add('Dummy ProductCode__c 없음');
                dummy.BatchErrorComment__c = String.join(errorComments, ', ');

                targetBadDummyList.add(Dummy_IF_BatchUtil.setDummyBatchResult(
                        dummy,
                        String.format(
                                Dummy_IF_BatchUtil.DUMMY_BATCH_ERROR_VALID,
                                new String[]{'ProductCode__c is Null'}
                        ),
                        this.errorDummyIds
                ));
                continue;
            }

            //============================================================================
            // 신규 데이터인 경우
            //============================================================================
            if (isExistRecord == false) {
                targetInsList.add(tmpProduct = new Product2(
                        IsActive        = false,
                        //---------------------------------------------------------------
                        // ProductCode__c 에 따른 문자 구분으로 본체/작업기/none를 구분하여 세팅
                        // 20210412 허이사님 요청건
                        //---------------------------------------------------------------
                        //Type__c         = null,
                        Type__c         = Dummy_IF_BatchUtil.getTypeFromProductCode(dummy.ProductCode__c),
                        ListPrice__c    = 0,
                        Name            = dummy.MATGR__c       //dummy.ErpMAKTX__c
                ));
            }
            //============================================================================
            // 기존 데이터인 경우
            //============================================================================
            else {
                targetUpdList.add(tmpProduct = tmpExistProduct);
            }

            //============================================================================
            // 신규 or 기존 데이터 모두 데이터 update 처리
            //============================================================================
            tmpProduct.Name             = dummy.MATGR__c == null ? dummy.ErpMAKTX__c : dummy.MATGR__c;
            tmpProduct.ProductCode      = dummy.ProductCode__c;
            tmpProduct.ExternalId__c    = dummy.ProductCode__c;
            tmpProduct.ErpMAKTX__c      = dummy.ErpMAKTX__c;

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

        /*
         * ================================================================
         * Dml 수행 및 Dummy 상태처리 : 에러시 Dummy 상태값 세팅
         * ================================================================
         */
        System.Savepoint sp;
        try {
            sp = Database.setSavepoint();
            insert targetInsList;
            update targetUpdList;
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
        if(this.isNextBatch)    Database.executeBatch(new Dummy_IF_KR_ERP_SE_0028_2_ba(), 200);
        super.finish(BC);
    }
}