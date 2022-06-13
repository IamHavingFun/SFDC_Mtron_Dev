/****************************************************************************************
  * @filename      : Dummy_IF_KR_ERP_SE_0003_ba
  * @projectname   : 
  * @author        : i2max 
  * @date          : 2020-05-11
  * @group         :
  * @group-content :
  * @description   : [자재-가격정보]
  *                : IF_KR_ERP_SE_0003 -> Product : update
  * @tester        : Dummy_IF_KR_ERP_SE_0003_ba_ts.cls
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2020-05-11      i2max          Create
*************a***************************************************************************/

public with sharing class Dummy_IF_KR_ERP_SE_0003_ba extends Dummy_IF_Batch{

    public String query;
    public Boolean isNextBatch = true;

    public Dummy_IF_KR_ERP_SE_0003_ba() {
        this(null);
    }

    public Dummy_IF_KR_ERP_SE_0003_ba(final String query) {
        this(query, true);
    }

    public Dummy_IF_KR_ERP_SE_0003_ba(final String query, final Boolean isNextBatch) {
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
        this.interfaceId = 'IF_KR_ERP_SE_0003';
        this.deleteInfo = new Dummy_IF_Batch.DeleteInfo(
                'IF_KR_ERP_SE_0003__c',
                interfaceId,
                Dummy_IF_Batch.DUMMY_BATCH_PERIOD_TYPE.DAILY,
                this.exeDatetime
        );

        /*
        ErpVKORG__c		    ERP 영업조직(화면 표시 안함)	    Text	10
        ErpVTWEG__c		    ERP 유통경로(화면 표시 안함)	    Text	10
        ErpSPART__c		    ERP 제품군(화면 표시 안함)	        Text	10
        ProductCode__c	PK	제품 코드(본체/작업기)	            Text	255	    10144301
        ErpPriceType__c	PK	ERP 가격리스트 유형(화면 표시 안함)	Text	10	    FC          대상 : FC, FD, FE
        UnitPrice		    기준가격	                        Num	    18,0	90000
        WAERK__c		    통화	                            Text	10	    KRW
        KMEIN__c		    단위	                            Text	10	    EA
        DATAB__c		    효력시작일(yyyyMMdd)	            Text	20	    20191120
        DATAB__c		    효력시작일(yyyyMMdd)	            Text	20	    20191120
        */
        if(String.isNotBlank(this.query)) {
            return Database.getQueryLocator(this.query);
        } else {
            return Database.getQueryLocator([
                    SELECT
                            Id,
                            ErpVKORG__c,
                            ErpVTWEG__c,
                            ErpSPART__c,
                            ProductCode__c,
                            ErpPriceType__c,
                            UnitPrice__c,
                            WAERK__c,
                            KMEIN__c,
                            DATAB__c,
                            DATBI__c,
                            isBatchCompleted__c,
                            isBatchError__c,
                            BatchErrorMessage__c
                    FROM IF_KR_ERP_SE_0003__c
                    WHERE   InterfaceId__c = 'IF_KR_ERP_SE_0003'
                    AND     isBatchCompleted__c = FALSE
                    AND     isBatchError__c = FALSE
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
        * 수신 데이터의 ProductCode__c 기준으로 Product Update

            2)	ProductCode : ProductCode__c 필드로 설정
            3)	CurrencyIsoCode : KRW 설정
            6)	IF.ErpPriceType__c = FC 대리점가 이면
                DealerListPrice__c : UnitPrice 필드로 설정
            7)	IF.ErpPriceType__c = FD : 농협가 이면
                NhListPrice__c : UnitPrice 필드로 설정
            8)	IF.ErpPriceType__c = FE : 관납가 이면
                GovListPrice__c : UnitPrice 필드로 설정
            9)	ErpVKORG__c : ErpVKORG__c 필드로 설정
            10)	ErpVTWEG__c : ErpVTWEG__c 필드로 설정
            11)	ErpSPART__c : ErpSPART__c 필드로 설정
        PK) 12)	ExternalId__c : ProductCode__c              참조만

            * * 하나의 제품에 최대 3개의 가격(대리점가, 농협가, 관납가)이 있을 수 있음
            * 수수료는 SE담당자가 수기로 등록
            - 작업기 수수료금액
            - 농협 수수료금액
            - 관납 수수료율
            - 제품구분수수료율 : 전략제품/경제형/실속형/계절기종의 경우 제공

            * ErpPriceType__c 값이 FC, FD, FE 가 아닐 경우 SKIP
            * ProductCode__c 제품이 없을 경우 SKIP
        */


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
        List<SObject> targetUpdList = new List<SObject>();
        // validation 처리시 비정상 Dummy Data List
        List<SObject> targetBadDummyList = new List<SObject>();
        // Dml 수행 에러 Dummy Data List
        List<SObject> targetDmlDummyList = new List<SObject>();

        Product2 tmpExistProduct;
        Boolean isGoodDummy, isExistRecord;
        String BadDummyMessage;

        //============================================================================
        // 존재하는 ProductCode 기준 targetUpdList Product 맵
        //============================================================================
        Map<String, Product2> ProductMergeByProductCode = new Map<String, Product2>();
        List<ProductPriceEntry__c> updateProductPriceEntries = new List<ProductPriceEntry__c>();
        ProductPriceEntry__c ppe;
        Date startDate;
        for(IF_KR_ERP_SE_0003__c dummy : scope) {
            //============================================================================
            // 처음부터 처리여부 true 설정
            //============================================================================
            dummy.isBatchCompleted__c = true;

            // productCode를 lpad 하여 처리
            productCode = Dummy_IF_BatchUtil.getProductCodeLpad(dummy.ProductCode__c);
            dummy.ProductCode__c = productCode;
            // 기존 데이터
            tmpExistProduct = ProductByProductCode.get(productCode);
            // 기존 데이터 여부
            isExistRecord = tmpExistProduct != null ? true : false;
            /*
             * ================================================================
             * 정상 Dummy 데이터 여부             *
             * 위 데이터는 신규생성의 무결성을 위한 required 데이터 임. [중요]
             * ProductCode__c 이 필수 항목
             * ProductCode__c 기준 제품이 없을 경우 SKIP
             * ErpPriceType__C 값이 FC, FD, FE가 아니면 SKIP
             * ================================================================
             */
            isGoodDummy = String.isNotBlank(dummy.ProductCode__c)
                        && ((dummy.ErpPriceType__c == 'FC') || (dummy.ErpPriceType__c == 'FD') || (dummy.ErpPriceType__c == 'FE'))
                        && isExistRecord;

            List<String> errorComments = new List<String>();
            if (isGoodDummy == false) {
                if(String.isBlank(dummy.ProductCode__c)) errorComments.add('ProductCode__c is Null');
                if(!((dummy.ErpPriceType__c == 'FC') || (dummy.ErpPriceType__c == 'FD') || (dummy.ErpPriceType__c == 'FE'))){
                    BadDummyMessage = 'ERP가격 리스트 유형(FC, FD, FE)가 아닌 경우 : [' + dummy.ErpPriceType__c + ']';
                    errorComments.add(BadDummyMessage);
                }else if(!isExistRecord){
                    BadDummyMessage = '제품(Product2)이 없음 : [' + dummy.ProductCode__c + ']';
                    errorComments.add(BadDummyMessage);
                }

                dummy.BatchErrorComment__c = String.join(errorComments, ', ');

                targetBadDummyList.add(Dummy_IF_BatchUtil.setDummyBatchResult(
                        dummy,
                        String.format(
                                Dummy_IF_BatchUtil.DUMMY_BATCH_ERROR_VALID,
                                new String[]{BadDummyMessage}
                        ),
                        this.errorDummyIds
                ));
                continue;
            }

            //============================================================================
            // 제품이 있는 데이터만 대상
            //============================================================================
            if (isExistRecord) {
                // 제품 가격 처리.
                ProductMergeByProductCode.put(dummy.ProductCode__c, tmpExistProduct);
                dummy.DATAB__c = dummy.DATAB__c == '99991231' ? '40001231' : dummy.DATAB__c;     // 유효 시작일자
                dummy.DATBI__c = dummy.DATBI__c == '99991231' ? '40001231' : dummy.DATBI__c;     // 유효 종료일자
                startDate = Dummy_IF_BatchUtil.getIFDate(dummy.DATAB__c);
                updateProductPriceEntries.add(
                        new ProductPriceEntry__c(
                                ExternalID__c = tmpExistProduct.ProductCode + '/' + dummy.ErpPriceType__c + '/' + ((Datetime)startDate).format('yyyy-MM-dd'),
                                BasePrice__c  = dummy.UnitPrice__c,
                                PriceType__c  = dummy.ErpPriceType__c,
                                Product__c    = tmpExistProduct.Id,
                                StartDate__c  = startDate,
                                EndDate__c    = Dummy_IF_BatchUtil.getIFDate(dummy.DATBI__c)
                        )
                );

                // 기존 제품 처리.
                // 가격은 유효기간 체크 하기 위해서 0003_2 배치에서 처리.
                // 2022/01/27
                tmpExistProduct.ProductCode = dummy.ProductCode__c;
                tmpExistProduct.CurrencyIsoCode = 'KRW';
                tmpExistProduct.ErpVKORG__c = dummy.ErpVKORG__c;
                tmpExistProduct.ErpVTWEG__c = dummy.ErpVTWEG__c;
                tmpExistProduct.ErpSPART__c = dummy.ErpSPART__c;

                //============================================================================
                // target or dummy 데이터 리스트 add
                //============================================================================
                targetDmlDummyList.add(dummy);
            }
        }

        // Merge 데이터
        for (String str : ProductMergeByProductCode.keySet()){
            targetUpdList.add(ProductMergeByProductCode.get(str));
        }

        //System.debug('SIZE : ' + targetUpdList.size());
        //System.debug('Dummy_IF_KR_ERP_SE_0003_ba : ' + JSON.serializePretty(targetUpdList));
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
            update targetUpdList;

            upsert updateProductPriceEntries ProductPriceEntry__c.ExternalID__c;
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
        if(this.isNextBatch)    Database.executeBatch(new Dummy_IF_KR_ERP_SE_0003_2_ba(), 200);
        super.finish(BC);
    }
}