/****************************************************************************************
  * @filename      : Dummy_IF_KR_ERP_SE_0016_ba
  * @projectname   :
  * @author        : i2max
  * @date          : 2020-04-17
  * @group         :
  * @group-content :
  * @description   : [매출실적]
  *                : IF_KR_ERP_SE_0016 -> SalesPerformance__c : insert
  * @tester        : Dummy_IF_KR_ERP_SE_0016_ba_ts.cls
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2020-04-17      i2max          Create
****************************************************************************************/
public class Dummy_IF_KR_ERP_SE_0016_ba extends Dummy_IF_Batch {

    public String query;

    public Dummy_IF_KR_ERP_SE_0016_ba() {
        this(null);
    }

    public Dummy_IF_KR_ERP_SE_0016_ba(final String query) {
        this.query = query;
    }

    //============================================================================
    // SalesGroupName의 picklist api 에 체크를 위한 set 구성
    //============================================================================
    private static Set<String> salesGroupNames = new Set<String>();
    static {
        Schema.DescribeFieldResult fieldResult = SalesPerformance__c.SalesGroupName__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple) {
            salesGroupNames.add(f.getValue());
        }
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
        this.interfaceId = 'IF_KR_ERP_SE_0016';
        this.deleteInfo = new Dummy_IF_Batch.DeleteInfo(
                'IF_KR_ERP_SE_0006__c',
                interfaceId,
                Dummy_IF_Batch.DUMMY_BATCH_PERIOD_TYPE.MONTHLY,
                this.exeDatetime
        );

        /* IF_KR_ERP_SE_0016_매출실적_0420.xlsx
        QueryDate__c	        PK	조회기준년월(yyyyMM)	Text	10          202003
        ErpVKORG__c	            PK	영업조직	            Text 	10
        DistributionChannel__c	PK	유통경로	            Text 	10
        ErpSPART__c	            PK	제품군	            Text	10
        SalesTeam__c	        PK	영업팀	            Text	10
        SalesGroupCode__c	    PK	영업그룹코드	        Text	20
        BillingDocNo__c	        PK	대금청구문서번호	    Text	20          8110965431
        BillingDocItem__c		    대금청구문서품목	    Text	10
        BillingType__c		        대금청구유형	        Text	10          RE
        SalesDocNo__c		        판매문서번호	        Text	20          5910057843
        SalesDocItem__c		        판매문서품목	        Text	10          10
        ErpOrderType__c		        오더구분	            Text 	10          ZRET
        BusinessOfficeCode__c		영업소코드	        Text	10          71A
        BusinessOfficeName__c		영업소명	            Text 	20          경기(영)
        CustomerCode__c		        고객코드	            Text 	20          113496
        CustomerName__c		        고객명	            Text	80          (담양)준피드농업기계
        ProductCode__c		        제품코드	            Text 	20          10148207
        ProductName__c		        ERP 제품명	        Text	50          TR-XP7115-DM-CAPSSBEDNAAHLC
        OrderQuantity__c		    주문수량	            Num	    18,0        1
        ErpVRKME__c		            단위	                Text 	10
        Currency__c		            통화	                Text 	10
        SalesAmount__c		        매출금액(= ERP 현지통화금액)	Num	18, 0   560000
        MachineNo__c		        기대번호	            Text 	20          2350000007
        BillingDay__c		        대금청구일(yyyyMMdd)	Text	20          20200302
        ErpSFAKN__c		            취소된 대금청구문서	Text	20
        ErpFKSTO__c		            대금청구문서취소	    Text	10
         */
        if (String.isNotBlank(this.query)) {
            return Database.getQueryLocator(this.query);
        } else {
            return Database.getQueryLocator([
                    SELECT
                            Id,
                            CurrencyName__c,
                            QueryDate__c,
                            BillingDocNo__c,
                            BillingType__c,
                            SalesDocNo__c,
                            SalesDocItem__c,
                            ErpOrderType__c,
                            BusinessOfficeCode__c,
                            BusinessOfficeName__c,
                            CustomerCode__c,
                            CustomerName__c,
                            ProductCode__c,
                            OrderQuantity__c,
                            SalesAmount__c,
                            MachineNo__c,
                            BillingDay__c,
                            SalesGroupName__c,
                            isBatchCompleted__c,
                            isBatchError__c,
                            BatchErrorMessage__c
                    FROM IF_KR_ERP_SE_0006__c
                    WHERE InterfaceId__c = :this.interfaceId
                    AND isBatchCompleted__c = FALSE
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
        final List<IF_KR_ERP_SE_0006__c> scope = (List<IF_KR_ERP_SE_0006__c>)targetScope;
        Set<String> customerCodeSet = new Set<String>();
        Map<String, Account> accountMap = new Map<String, Account>();

        /* IF_KR_ERP_SE_0016_매출실적_0420.xlsx
        * SalesPerformance OBJ Insert
        owner : IF.CustomerCode__c = Account.ErpCode__c 레코드 Owner 참조
        Area__c : IF.CustomerCode__c = Account.ErpCode__c 레코드 지역 참조
        SalesRep__c : IF.CustomerCode__c = Account.ErpCode__c 레코드 "영업소 영업사원" 참조
        Channel__c : IF.CustomerCode__c = Account.ErpCode__c 레코드 "고객유형" 참조

        CurrencyIsoCode : IF.CurrencyName__c필드로 설정 -> 추가
        Division__c : "실적" 설정
        BaseYearMonth__c : IF.QueryDate__c 데이터 타입 변환
        SalesDocumentNo__c : SalesDocNo__c필드로 설정
        SalesDocumentItem__c : SalesDocItem__c필드로 설정
        SalesGroupName__c : SalesGroupName__c필드로 설정
        CustomerCode__c : CustomerCode__c필드로 설정
        CustomerName__c : CustomerName__c필드로 설정
        BusinessOfficeName__c : BusinessOfficeName__c필드로 설정
        ProductCode__c : ProductCode__c필드로 설정
        BillingType__c : BillingType__c필드로 설정
        OrderQuantity__c : OrderQuantity__c필드로 설정
        SalesAmount__c : SalesAmount__c필드로 설정
        MachineNo__c : MachineNo__c필드로 설정
        BillingDay__c : BillingDay__c필드로 설정, 데이터 타입 변환
        AmountMillion__c : IF.SalesAmount__c / 1000000, 소수점 절사
        BillingDocumentNo__c : BillingDocNo__c필드로 설정, 데이터 타입 변환
        ErpOrderType__c : ErpOrderType__c필드로 설정, 데이터 타입 변환

        ProductId__c : IF.ProductCode__c = Product.ProductCode__c 레코드 "ID" 참조 -> 추가
        BaseModel__c : IF.ProductCode__c = Product.ProductCode__c 레코드 "기본모델" 참조
        Model__c : IF.ProductCode__c = Product.ProductCode__c 레코드 "기종" 참조
        Segment__c : IF.ProductCode__c = Product.ProductCode__c 레코드 "Segment" 참조
        Series__c : IF.ProductCode__c = Product.ProductCode__c 레코드 "시리즈" 참조
        HorsePower__c : IF.ProductCode__c = Product.ProductCode__c 레코드 "마력/규격" 참조
        Option1__c  : IF.ProductCode__c = Product.ProductCode__c 레코드 "옵션1" 참조
        Option2__c : IF.ProductCode__c = Product.ProductCode__c 레코드 "옵션2" 참조
        Option3__c : IF.ProductCode__c = Product.ProductCode__c 레코드 "옵션3" 참조
        Option4__c : IF.ProductCode__c = Product.ProductCode__c 레코드 "옵션4" 참조
        ModelName__c : IF.ProductCode__c = Product.ProductCode__c 레코드 "제품 이름" 참조
        Manufacturer__c : IF.ProductCode__c = Product.ProductCode__c 레코드 "OEM 업체" 참조
        ----------------------------------------------------------------------------------------
      */
        String customerCode;
        String productCode;
        for(IF_KR_ERP_SE_0006__c dummy : scope) {
            // lpad 하여 비교
            customerCode = Dummy_IF_BatchUtil.getErpCodeLpad(dummy.CustomerCode__c);
            customerCodeSet.add(customerCode);
        }

        for(Account a : [
                SELECT  Id,
                        ERPCode__c,
                        CustomerType__c,
                        SalesRep__c,
                        Area__c,
                        Dealer__r.OwnerId,
                        BusinessOffice__c,
                        Parent.BusinessOfficeName__c
                FROM Account
                WHERE ERPCode__c IN :customerCodeSet
        ]) {
            if(!accountMap.containsKey(a.ERPCode__c)) {
                accountMap.put(a.ERPCode__c, a);
            }
        }

        // 판매처별 소유주 구하기 공통
        Map<String, Id> recordOwnerMap = Dummy_IF_BatchUtil.getRecordOwnder(this.interfaceId, customerCodeSet);

        // 전체 Product Map
        Map<String, Product2> productsByProductCode = Dummy_IF_BatchUtil.getTargetProduct2(true);

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

        SalesPerformance__c tmpSalesPerformance;
        Boolean isGoodDummy, isGoodDate;
        Product2 tmpProduct;
        Account tmpAccount;
        Date tmpBillingDay;

        /*
         * ================================================================
         * 대상건 : 전체 데이터
         * ================================================================
         */
        for(IF_KR_ERP_SE_0006__c dummy : scope){
            //============================================================================
            // 처음부터 처리여부 true 설정
            //============================================================================
            dummy.isBatchCompleted__c = true;
            dummy.isBatchError__c = false;
            dummy.BatchErrorMessage__c = null;
            dummy.BatchErrorComment__c = null;

            //============================================================================
            // 모든 데이터는 신규 건
            //============================================================================
            // 자신의 CustomerCode : lpad 하여 비교
            customerCode = Dummy_IF_BatchUtil.getErpCodeLpad(dummy.CustomerCode__c);
            tmpAccount = accountMap.get(customerCode);

            // productCode를 lpad 하여 처리
            productCode = Dummy_IF_BatchUtil.getProductCodeLpad(dummy.ProductCode__c);
            tmpProduct = productsByProductCode.get(productCode);

            //============================================================================
            // 날짜 형식 체크
            //============================================================================
            isGoodDate = true;
            try {
                tmpBillingDay  = String.isNotBlank(dummy.BillingDay__c) ? Dummy_IF_BatchUtil.getIFDate(dummy.BillingDay__c) : null;
            }
            catch(Exception e) {
                isGoodDate = false;
            }

            /*
             * ================================================================
             * 정상 Dummy 데이터 여부
             * tmpProductCode, tmpProduct, tmpErpCode, tmpAccount
             * 위 데이터는 신규생성의 무결성을 위한 required 데이터 임. [중요]
             * QueryDate__c, CustomerCode__c, ProductCode__c 이 필수 항목
             * ================================================================
             */
//            isGoodDummy = (String.isNotBlank(dummy.QueryDate__c)
//                    && String.isNotBlank(dummy.CustomerCode__c)
//                    && String.isNotBlank(dummy.ProductCode__c)
//                    && salesGroupNames.contains(dummy.SalesGroupName__c)
//                    && isGoodDate
//                    && tmpAccount != null
//                    && Dummy_IF_BatchUtil.isValidCurrency(String.isNotBlank(dummy.CurrencyName__c) ? dummy.CurrencyName__c : 'KRW'));

            isGoodDummy = true;
            List<String> errorComments = new List<String>();

            if(String.isBlank(dummy.QueryDate__c)
                    || String.isBlank(dummy.CustomerCode__c)
                    || String.isBlank(dummy.ProductCode__c)
                    || !salesGroupNames.contains(dummy.SalesGroupName__c)
                    || !isGoodDate
                    || tmpAccount == null
                    || !Dummy_IF_BatchUtil.isValidCurrency(String.isNotBlank(dummy.CurrencyName__c) ? dummy.CurrencyName__c : 'KRW')){

                isGoodDummy = false;

                if(String.isBlank(dummy.QueryDate__c)) errorComments.add('Dummy QueryDate__c 없음');
                if(String.isBlank(dummy.CustomerCode__c)) errorComments.add('Dummy CustomerCode__c 없음');
                if(String.isBlank(dummy.ProductCode__c)) errorComments.add('Dummy ProductCode__c 없음');
                if(!salesGroupNames.contains(dummy.SalesGroupName__c)) errorComments.add('SalesGroupName Picklist value 없음 = [' + dummy.SalesGroupName__c + ']');
                if(!isGoodDate) errorComments.add('날짜오류 = ' + dummy.BillingDay__c);
                if(tmpAccount == null) errorComments.add('Account 없음 = [' + dummy.CustomerCode__c + ']');
                if(!Dummy_IF_BatchUtil.isValidCurrency(dummy.CurrencyName__c)) errorComments.add('CurrencyName__c != KRW');

                dummy.BatchErrorComment__c = String.join(errorComments, ', ');
            }

            //============================================================================
            // 정상 Dummy 데이터인 경우
            //============================================================================
            if(isGoodDummy == false) {
                targetBadDummyList.add(Dummy_IF_BatchUtil.setDummyBatchResult(
                        dummy,
                        String.format(
                                Dummy_IF_BatchUtil.DUMMY_BATCH_ERROR_VALID,
                                new String[]{'IF.QueryDate__c or IF.CustomerCode__c or IF.ProductCode__c or IF.SalesGroupName__c or isNotGoodDate or CurrencyName__c is not KRW'}
                        ),
                        this.errorDummyIds
                ));
                continue;
            }
            else {
                tmpSalesPerformance = new SalesPerformance__c();
                //============================================================================
                // 데이터 매핑
                //============================================================================
                tmpSalesPerformance.OwnerId                 = recordOwnerMap.get(customerCode);
                tmpSalesPerformance.AccountId__c            = tmpAccount.Id;
                tmpSalesPerformance.BusinessOffice__c       = tmpAccount.BusinessOffice__c;
                tmpSalesPerformance.SalesRep__c             = tmpAccount.SalesRep__c;
                tmpSalesPerformance.Channel__c              = tmpAccount.CustomerType__c;
                tmpSalesPerformance.CustomerName__c         = dummy.CustomerName__c;
                tmpSalesPerformance.CustomerCode__c         = customerCode;
                tmpSalesPerformance.CurrencyIsoCode         = dummy.CurrencyName__c;
                tmpSalesPerformance.Division__c             = '실적';
                tmpSalesPerformance.BaseYearMonth__c        = Dummy_IF_BatchUtil.getIFDate(dummy.QueryDate__c + '01');
                tmpSalesPerformance.SalesDocumentNo__c      = dummy.SalesDocNo__c;
                tmpSalesPerformance.SalesDocumentItem__c    = dummy.SalesDocItem__c;
                tmpSalesPerformance.SalesGroupName__c       = dummy.SalesGroupName__c;
                tmpSalesPerformance.BillingType__c          = dummy.BillingType__c;
                tmpSalesPerformance.OrderQuantity__c        = dummy.OrderQuantity__c;
                tmpSalesPerformance.SalesAmount__c          = dummy.SalesAmount__c;
                tmpSalesPerformance.MachineNo__c            = dummy.MachineNo__c;
                tmpSalesPerformance.BillingDay__c           = tmpBillingDay;
                tmpSalesPerformance.BillingDocumentNo__c    = dummy.BillingDocNo__c;
                tmpSalesPerformance.ErpOrderType__c         = dummy.ErpOrderType__c;

                /* 제품 */
                tmpSalesPerformance.ProductCode__c          = productCode;
                tmpSalesPerformance.ProductId__c            = (tmpProduct != null) ? tmpProduct.Id : null;

                // ITVOC-2021-12-0614 - 삭제 처리
/*
                tmpSalesPerformance.Area__c                 = tmpAccount.Area__c;
                tmpSalesPerformance.BusinessOfficeName__c   = tmpAccount.Parent.BusinessOfficeName__c;
                tmpSalesPerformance.AmountMillion__c        = (dummy.SalesAmount__c / 1000000).setScale(0);
                tmpSalesPerformance.BasicModel__c           = (tmpProduct != null) ? tmpProduct.BaseModel__c : null;
                tmpSalesPerformance.Model__c                = (tmpProduct != null) ? tmpProduct.ProductType__c : null;
                tmpSalesPerformance.Segment__c              = (tmpProduct != null) ? tmpProduct.Segment__c : null;
                tmpSalesPerformance.Series__c               = (tmpProduct != null) ? tmpProduct.Series__c : null;
                tmpSalesPerformance.HorsePower__c           = (tmpProduct != null) ? tmpProduct.HorsePowerStandard__c : null;
                tmpSalesPerformance.Option1__c              = (tmpProduct != null) ? tmpProduct.Option1__c : null;
                tmpSalesPerformance.Option2__c              = (tmpProduct != null) ? tmpProduct.Option2__c : null;
                tmpSalesPerformance.Option3__c              = (tmpProduct != null) ? tmpProduct.Option3__c : null;
                tmpSalesPerformance.Option4__c              = (tmpProduct != null) ? tmpProduct.Option4__c : null;
                tmpSalesPerformance.ModelName__c            = (tmpProduct != null) ? tmpProduct.Name : null;
                tmpSalesPerformance.Manufacturer__c         = (tmpProduct != null) ? tmpProduct.OEMCompany__c : null;
 */

                targetList.add(tmpSalesPerformance);
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
            insert targetList;
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
}