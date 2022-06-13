/****************************************************************************************
  * @filename      : Dummy_IF_KR_ERP_SE_0006_ba
  * @projectname   :
  * @author        : i2max
  * @date          : 2020-04-17
  * @group         :
  * @group-content :
  * @description   : [대리점 유통재고-실판매]
  *                : IF_KR_ERP_SE_0006 Dummy 에서 DataType__c 구분으로 DealerStock__c or ActualSales__c : Insert
  * @tester        : Dummy_IF_KR_ERP_SE_0006_ba_ts.cls
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2020-04-17      i2max          Create
    1.0     2020-06-11      i2max          modify
            [요구사항 변경]
            (기존) 인터페이스로 제공된 조회기준년월(yyyyMM)을 기준년월로 사용 : BaseYearMonth__c = IF.QueryDate__c
            (변경) 유통재고 [DealerStock__c]  - 인터페이스로 제공된 입고일(yyyyMM)을 기준년월로 사용 : BaseYearMonth__c = IF.StockInDate__c
                  실판매  [ActualSales__c]  - 인터페이스로 제공된 판매일(yyyyMM)을 기준년월로 사용 : BaseYearMonth__c = IF.SalesDate__c
            * 스케쥴 : 매월 2일 새벽 4시 - 2020-07-02일 부터 변경된 내용 적용됨
    1.1     2020-06-15      i2max          modify
            [요구사항 변경]
            (변경) 유통재고 [DealerStock__c]  - 인터페이스로 제공된 조회기준년월(yyyyMM)을 기준년월로 사용 : BaseYearMonth__c = IF.QueryDate__c
****************************************************************************************/

public class Dummy_IF_KR_ERP_SE_0006_ba extends Dummy_IF_Batch {

    public String query;

    public Dummy_IF_KR_ERP_SE_0006_ba() {
        this(null);
    }

    public Dummy_IF_KR_ERP_SE_0006_ba(final String query) {
        this.query = query;
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
        this.interfaceId = 'IF_KR_ERP_SE_0006';
        this.deleteInfo = new Dummy_IF_Batch.DeleteInfo(
                'IF_KR_ERP_SE_0006__c',
                interfaceId,
                Dummy_IF_Batch.DUMMY_BATCH_PERIOD_TYPE.MONTHLY,
                this.exeDatetime
        );

        /* IF_KR_ERP_SE_0006_대리점유통재고-실판매_0416.xlsx
        DataType__c	            PK	유통재고 I , 실판매 C 구분	    Text	10          I or C
        QueryDate__c	        PK	조회기준년월(yyyyMM)	        Text	10          202003
        ErpCode__c	            PK	고객코드	                    Text	20          114377
        ProductCode__c	        PK	제품코드	                    Text	20          10131733
        MachineNo	            PK	기대번호	                    Text	20          2273002055
        //ErpBizOffice__c	    PK	ERP 영업소	                Text	10          71A
        //ErpBizOfficeName__c		ERP 영업소명	                Text	20          경기(영)
        //ErpName__c		        고객명	                    Text	80          엘에스농업기계대리점
        ErpMAKTX__c		            자재내역	                    Text	80          TR-XU6168-DM-CAMTSBMDQTAHLC
        Qty__c		                수량	                        Num	    18,0        1
        StockInDate__c		        입고일(yyyyMMdd)	            Text	10          20190430
        ProductionDate__c		    생산일(yyyyMMdd)	            Text	80          20190430
        CustomerName__c		        실수요자명	                Text	80          이효선
        SalesDate__c		        판매일(yyyyMMdd)	            Text	10          20190426
        SalesDocNo__c		        판매문서번호	                Text	20          5110890239
        SalesDocItem__c		        판매문서품목	                Text	10          10
        OrderDivision__c		    오더구분	                    Text	10          ZORT
        Price__c		            정가	                        Num	    18,0        47667000
        FirstDeliveryDate__c	    최초출하일(yyyyMMdd)	        Text	10          20190225
        ElapsedDayOut__c		    경과일수(최초출하)	            Num	    18,0        60
        ElapsedDayIn__c		        경과일수(입고일)	            Num	    18,0        0
        ActualSalesDayOut__c	    실판매일수(최초출하)	        Num	    18,0        60
        ActualSalesDayIn__c		    실판매일수(입고일)	            Num	    18,0        0
         */

        if(String.isNotBlank(this.query)) {
            return Database.getQueryLocator(this.query);
        } else {
            return Database.getQueryLocator([
                    SELECT
                            Id,
                            CurrencyName__c,
                            DataType__c,
                            QueryDate__c,
                            ErpCode__c,
                            ProductCode__c,
                            MachineNo__c,
                            ErpMAKTX__c,
                            Qty__c,
                            StockInDate__c,
                            ProductionDate__c,
                            SalesDate__c,
                            SalesDocNo__c,
                            SalesDocItem__c,
                            OrderDivision__c,
                            Price__c,
                            FirstDeliveryDate__c,
                            ElapsedDayOut__c,
                            ElapsedDayIn__c,
                            ActualSalesDayOut__c,
                            ActualSalesDayIn__c,
                            isBatchCompleted__c,
                            isBatchError__c,
                            BatchErrorMessage__c
                    FROM    IF_KR_ERP_SE_0006__c
                    WHERE   InterfaceId__c = :this.interfaceId
                    AND     isBatchCompleted__c = FALSE
                    AND     isBatchError__c = FALSE
                    ORDER BY DataType__c DESC       // Cannot have more than 10 chunks in a single operation. Please rearrange the data to reduce chunking. 방지를 위한 Order By
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

        /*
            IF_KR_ERP_SE_0016_대리점유통재고-실판매_0416.xlsx
            * DataType__c이 유통재고(I)이면 DealerStock__c OBJ, 실판매(C)이면 ActualSales__c OBJ Insert

            유통재고 : << DealerStock__c >>
            OwnerId : IF.ErpCode__c = Account.ErpCode__c 레코드 Owner 참조 -> 추가
            3)	BusinessOfficeName__c : IF.ErpCode__c = Account.ErpCode__c 데이터의 영업소명 설정
            4)	Area_c : IF.ErpCode__c = Account.ErpCode__c 데이터의 지역 설정
            5)	SalesRep__c : IF.ErpCode__c = Account.ErpCode__c 데이터의 영업소 영업사원 설정
            6)	Channel__c : IF.ErpCode__c = Account.ErpCode__c 데이터의 고객유형 설정

            1)	Division__c : 실적 설정
            2)	BaseYearMonth__c : QueryDate__c 필드로 설정, 데이터 타입 변경 => (20200611) StockInDate__c로 매핑 필드 변경 => (20200625) QueryDate__c로 매핑 필드 변경
            CurrencyIsoCode : IF.CurrencyName__c필드로 설정 -> 추가
            7)	CustomerCode__c : ErpCode__c 필드로 설정
            8)	CustomerName__c : ErpName__c 필드로 설정 -> Account.ErpCode__c = IF.ErpCode__c => Account.Name 필드로 설정
            9)	ProductCode__c : ProductCode__c 필드로 설정
            10)	ErpMAKTX__c : ErpMAKTX__c 필드로 설정
            11)	MachineNo__c : MachineNo 필드로 설정
            22)	Qty__c :  : Qty__c 필드로 설정
            23)	StockInDate__c : StockInDate__c 필드로 설정, 타입 변경
            24)	ProductionDate__c : ProductionDate__c 필드로 설정, 타입 변경
            25)	SalesDocNo : SalesDocNo__c 필드로 설정
            26)	SalesDocItem : SalesDocItem__c 필드로 설정
            27)	Price__c : Price__c 필드로 설정
            28)	FirstDeliveryDate__c : FirstDeliveryDate__c 필드로 설정
            31)	ActualSalesDayOut__c : ActualSalesDayOut__c 필드로 설정
            32)	ActualSalesDayIn__c : ActualSalesDayIn__c 필드로 설정
            29)	ElapsedDayOut__c : ElapsedDayOut__c 필드로 설정
            30)	ElapsedDayIn__c : ElapsedDayIn__c 필드로 설정

            ProductId__c : IF.ProductCode__c = Product.ProductCode__c 레코드 "ID" 참조 -> 추가
            12)	ModelName__c : IF.ProductCode__c = Product.ProductCode__c 데이터의 제품 이름 참조
            13)	BaseModel__c : 제품.기본모델 참조
            14)	ProductType__c : 제품.기종 참조
            15)	Segment : 제품.Segment 참조
            16)	Series__c : 제품.시리즈 참조
            17)	HorsePowerStandard__c : 제품.마력/규격 참조
            18)	Option1 : 제품.옵션1(캐빈) 참조
            19)	Option2 : 제품.옵션2(T/M) 참조
            20)	Option3 : 제품.옵션3(앞차축) 참조
            21)	Option4 : 제품.옵션4(유압) 참조


            실판매 : << ActualSales__c >>
            OwnerId : IF.ErpCode__c = Account.ErpCode__c 레코드 Owner 참조 -> 추가
            3)	BusinessOfficeName__c : IF.ErpCode__c = Account.ErpCode__c 데이터의 영업소명 설정
            4)	Area_c : IF.ErpCode__c = Account.ErpCode__c 데이터의 지역 설정
            5)	SalesRep__c : IF.ErpCode__c = Account.ErpCode__c 데이터의 영업소 영업사원 설정
            6)	Channel__c : IF.ErpCode__c = Account.ErpCode__c 데이터의 고객유형 설정

            1)	Division__c : 실적 설정
            2)	BaseYearMonth__c : QueryDate__c 필드로 설정, 데이터 타입 변경 => (20200611) SalesDate__c로 매핑 필드 변경
            CurrencyIsoCode : IF.CurrencyName__c필드로 설정 -> 추가
            7)	CustomerCode__c : ErpCode__c 필드로 설정
            8)	CustomerName__c : ErpName__c 필드로 설정 -> Account.ErpCode__c = IF.ErpCode__c => Account.Name 필드로 설정
            9)	ProductCode__c : ProductCode__c 필드로 설정
            10)	ErpMAKTX__c : ErpMAKTX__c 필드로 설정
            11)	MachineNo__c : MachineNo 필드로 설정
            22)	Qty__c :  : Qty__c 필드로 설정 : Qty__c 필드로 설정
            23)	StockInDate__c : StockInDate__c 필드로 설정, 타입 변경
            24)	ProductionDate__c : ProductionDate__c 필드로 설정, 타입 변경 -> 제거
            25)	CustomerName__c : CustomerName__c 필드로 설정 -> 제거(중복)
            26)	SalesDate__c : SalesDate__c 필드로 설정, 타입 변경
            27)	SalesDocNo : SalesDocNo__c 필드로 설정
            28)	SalesDocItem : SalesDocItem__c 필드로 설정
            29)	OrderDivision__c : OrderDivision__c 필드로 설정
            30)	Price__c : Price__c 필드로 설정
            31)	FirstDeliveryDate__c : FirstDeliveryDate__c 필드로 설정
            34)	ActualSalesDayOut__c : ActualSalesDayOut__c 필드로 설정
            35)	ActualSalesDayIn__c : ActualSalesDayIn__c 필드로 설정
            32)	ElapsedDayOut__c : ElapsedDayOut__c 필드로 설정
            33)	ElapsedDayIn__c : ElapsedDayIn__c 필드로 설정

            ProductId__c : IF.ProductCode__c = Product.ProductCode__c 레코드 "ID" 참조 -> 추가
            12)	ModelName__c : IF.ProductCode__c = Product.ProductCode__c 데이터의 제품 이름 참조
            13)	BaseModel__c : 제품.기본모델 참조
            14)	ProductType__c : 제품.기종 참조
            15)	Segment : 제품.Segment 참조
            16)	Series__c : 제품.시리즈 참조
            17)	HorsePowerStandard__c : 제품.마력/규격 참조
            18)	Option1 : 제품.옵션1(캐빈) 참조
            19)	Option2 : 제품.옵션2(T/M) 참조
            20)	Option3 : 제품.옵션3(앞차축) 참조
            21)	Option4 : 제품.옵션4(유압) 참조
         ----------------------------------------------------------------------------------------
        */
        String erpCode;
        String productCode;
        for(IF_KR_ERP_SE_0006__c dummy : scope) {
            // lpad 하여 비교
            erpCode = Dummy_IF_BatchUtil.getErpCodeLpad(dummy.ErpCode__c);
            customerCodeSet.add(erpCode);
        }

        for(Account a : [
                SELECT  Id,
                        Name,
                        ERPCode__c,
                        CustomerType__c,
                        SalesRep__c,
                        Area__c,
                        BusinessOfficeName__c,
                        Dealer__r.OwnerId
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

        DealerStock__c tmpDealerStock;
        ActualSales__c tmpActualSales;
        Boolean isGoodDummy, isGoodDate;
        Product2 tmpProduct;
        Account tmpAccount;
        Date tmpProductDate, tmpStockinDate, tmpSalesDate;

        Boolean isDealerStock = false;
        Boolean isActualSales = false;

        /*
         * ================================================================
         * 대상건 : 전체 데이터
         * ================================================================
         */
        for(IF_KR_ERP_SE_0006__c dummy : scope) {
            //============================================================================
            // 처음부터 처리여부 true 설정
            //============================================================================
            dummy.isBatchCompleted__c = true;
            dummy.isBatchError__c = false;
            dummy.BatchErrorMessage__c = null;
            dummy.BatchErrorComment__c = null;

            // DealerStock 여부
            isDealerStock = (dummy.DataType__c.toUpperCase() == 'I') ? true : false;
            // ActualSales 여부
            isActualSales = (dummy.DataType__c.toUpperCase() == 'C') ? true : false;

            //============================================================================
            // 모든 데이터는 신규 건
            //============================================================================
            // 자신의 ERPCode : lpad 하여 비교
            erpCode = Dummy_IF_BatchUtil.getErpCodeLpad(dummy.ErpCode__c);
            tmpAccount = accountMap.get(erpCode);

            // productCode를 lpad 하여 처리
            productCode = Dummy_IF_BatchUtil.getProductCodeLpad(dummy.ProductCode__c);
            tmpProduct = productsByProductCode.get(productCode);


            //============================================================================
            // 날짜 형식 체크
            //============================================================================
            isGoodDate = true;
            try {
                tmpStockinDate  = String.isNotBlank(dummy.StockinDate__c) ? Dummy_IF_BatchUtil.getIFDate(dummy.StockinDate__c) : null;
                tmpProductDate  = String.isNotBlank(dummy.ProductionDate__c) ? Dummy_IF_BatchUtil.getIFDate(dummy.ProductionDate__c) : null;
                tmpSalesDate    = String.isNotBlank(dummy.SalesDate__c) ? Dummy_IF_BatchUtil.getIFDate(dummy.SalesDate__c) : null;
            }
            catch(Exception e) {
                isGoodDate = false;
            }

            /*
             * ================================================================
             * 정상 Dummy 데이터 여부
             * DataType__c은 'I', 'C' 둘중 하나의 값
             * 위 데이터는 신규생성의 무결성을 위한 required 데이터 임. [중요]
             * QueryDate__c, CustomerCode__c, ProductCode__c 이 필수 항목
             * ================================================================
             */
//            isGoodDummy =  (String.isNotBlank(dummy.QueryDate__c)
//                    && String.isNotBlank(dummy.ErpCode__c)
//                    && String.isNotBlank(dummy.ProductCode__c)
//                    && isGoodDate
//                    && Dummy_IF_BatchUtil.isValidCurrency(String.isNotBlank(dummy.CurrencyName__c) ? dummy.CurrencyName__c : 'KRW'));

            isGoodDummy = true;
            List<String> errorComments = new List<String>();

            if(String.isBlank(dummy.QueryDate__c)
                    || String.isBlank(dummy.ErpCode__c)
                    || !String.isNotBlank(dummy.ProductCode__c)
                    || !isGoodDate
                    || !Dummy_IF_BatchUtil.isValidCurrency(String.isNotBlank(dummy.CurrencyName__c) ? dummy.CurrencyName__c : 'KRW')){

                isGoodDummy = false;

                if(String.isBlank(dummy.QueryDate__c)) errorComments.add('Dummy QueryDate__c 없음');
                if(String.isBlank(dummy.ErpCode__c)) errorComments.add('Dummy ErpCode__c 없음');
                if(String.isBlank(dummy.ProductCode__c)) errorComments.add('Dummy ProductCode__c 없음');
                if(!isGoodDate) errorComments.add('날짜오류 = ' + dummy.StockinDate__c + ', ' + dummy.ProductionDate__c + ', ' + dummy.SalesDate__c);
                if(!Dummy_IF_BatchUtil.isValidCurrency(String.isNotBlank(dummy.CurrencyName__c) ? dummy.CurrencyName__c : 'KRW')) errorComments.add('CurrencyName__c != KRW');

                dummy.BatchErrorComment__c = String.join(errorComments, ', ');
            }
/*
            if(isGoodDummy == false) {
                targetBadDummyList.add(Dummy_IF_BatchUtil.setDummyBatchResult(
                        dummy,
                        String.format(
                            Dummy_IF_BatchUtil.DUMMY_BATCH_ERROR_VALID,
                            new String[]{'IF.QueryDate__c or IF.ErpCode__c or IF.ProductCode__c or isNotGoodDate or CurrencyName__c is not KRW'}
                        ),
                        this.errorDummyIds
                ));
                continue;
            }
            else {
                if(isDealerStock == true) {
                    tmpDealerStock = new DealerStock__c();
                    //============================================================================
                    // 데이터 매핑
                    //============================================================================
                    tmpDealerStock.OwnerId                  = recordOwnerMap.get(erpCode);
                    tmpDealerStock.AccountId__c             = (tmpAccount != null) ? tmpAccount.Id : null;
                    tmpDealerStock.BusinessOfficeName__c    = (tmpAccount != null) ? tmpAccount.BusinessOfficeName__c : null;
                    tmpDealerStock.Area__c                  = (tmpAccount != null) ? tmpAccount.Area__c : null;
                    tmpDealerStock.SalesRep__c              = (tmpAccount != null) ? tmpAccount.SalesRep__c : null;
                    tmpDealerStock.Channel__c               = (tmpAccount != null) ? tmpAccount.CustomerType__c : null;
                    tmpDealerStock.CustomerName__c          = (tmpAccount != null) ? tmpAccount.Name : null;
                    tmpDealerStock.CustomerCode__c          = erpCode;

                    tmpDealerStock.Division__c              = '실적';
                    tmpDealerStock.BaseYearMonth__c         = Dummy_IF_BatchUtil.getIFDate(dummy.QueryDate__c + '01');
                    //tmpDealerStock.BaseYearMonth__c         = Date.valueOf(tmpStockinDate.year()+'-'+tmpStockinDate.month()+'-01');
                    tmpDealerStock.CurrencyIsoCode          = (dummy.CurrencyName__c != null) ? dummy.CurrencyName__c : 'KRW';
                    tmpDealerStock.ProductCode__c           = productCode;
                    tmpDealerStock.ErpMAKTX__c              = dummy.ErpMAKTX__c;
                    tmpDealerStock.MachineNo__c             = dummy.MachineNo__c;
                    tmpDealerStock.Qty__c                   = dummy.Qty__c;
                    tmpDealerStock.StockInDate__c           = tmpStockinDate;
                    tmpDealerStock.ProductionDate__c        = tmpProductDate;
                    tmpDealerStock.SalesDocNo__c            = dummy.SalesDocNo__c;
                    tmpDealerStock.SalesDocItem__c          = dummy.SalesDocItem__c;
                    tmpDealerStock.Price__c                 = dummy.Price__c;
                    tmpDealerStock.FirstDeliveryDate__c     = Dummy_IF_BatchUtil.getIFDate(dummy.FirstDeliveryDate__c);
                    tmpDealerStock.ActualSalesDayOut__c     = dummy.ActualSalesDayOut__c;
                    tmpDealerStock.ActualSalesDayIn__c      = dummy.ActualSalesDayIn__c;
                    tmpDealerStock.ElapsedDayOut__c         = dummy.ElapsedDayOut__c;
                    tmpDealerStock.ElapsedDayIn__c          = dummy.ElapsedDayIn__c;

                    // 제품 /
                    tmpDealerStock.ProductId__c             = (tmpProduct != null) ? tmpProduct.Id : null;
                    tmpDealerStock.ModelName__c             = (tmpProduct != null) ? tmpProduct.Name : null;
                    tmpDealerStock.BaseModel__c             = (tmpProduct != null) ? tmpProduct.BaseModel__c : null;
                    tmpDealerStock.ProductType__c           = (tmpProduct != null) ? tmpProduct.ProductType__c : null;
                    tmpDealerStock.Segment__c               = (tmpProduct != null) ? tmpProduct.Segment__c : null;
                    tmpDealerStock.Series__c                = (tmpProduct != null) ? tmpProduct.Series__c : null;
                    tmpDealerStock.HorsePowerStandard__c    = (tmpProduct != null) ? tmpProduct.HorsePowerStandard__c : null;
                    tmpDealerStock.Option1__c               = (tmpProduct != null) ? tmpProduct.Option1__c : null;
                    tmpDealerStock.Option2__c               = (tmpProduct != null) ? tmpProduct.Option2__c : null;
                    tmpDealerStock.Option3__c               = (tmpProduct != null) ? tmpProduct.Option3__c : null;
                    tmpDealerStock.Option4__c               = (tmpProduct != null) ? tmpProduct.Option4__c : null;

                    targetList.add(tmpDealerStock);
                    targetDmlDummyList.add(dummy);
                }
                else if(isActualSales == true) {
                    tmpActualSales = new ActualSales__c();
                    //============================================================================
                    // 데이터 매핑
                    //============================================================================
                    tmpActualSales.OwnerId                  = recordOwnerMap.get(erpCode);
                    tmpActualSales.AccountId__c             = (tmpAccount != null) ? tmpAccount.Id : null;
                    tmpActualSales.BusinessOfficeName__c    = (tmpAccount != null) ? tmpAccount.BusinessOfficeName__c : null;
                    tmpActualSales.Area__c                  = (tmpAccount != null) ? tmpAccount.Area__c : null;
                    tmpActualSales.SalesRep__c              = (tmpAccount != null) ? tmpAccount.SalesRep__c : null;
                    tmpActualSales.Channel__c               = (tmpAccount != null) ? tmpAccount.CustomerType__c : null;
                    tmpActualSales.CustomerName__c          = (tmpAccount != null) ? tmpAccount.Name : null;
                    tmpActualSales.CustomerCode__c          = erpCode;

                    tmpActualSales.Division__c              = '실적';
                    //tmpActualSales.BaseYearMonth__c         = Dummy_IF_BatchUtil.getIFDate(dummy.QueryDate__c + '01');
                    tmpActualSales.BaseYearMonth__c         = Date.valueOf(tmpSalesDate.year()+'-'+tmpSalesDate.month()+'-01');
                    tmpActualSales.CurrencyIsoCode          = (dummy.CurrencyName__c != null) ? dummy.CurrencyName__c : 'KRW';
                    tmpActualSales.ProductCode__c           = productCode;
                    tmpActualSales.ErpMAKTX__c              = dummy.ErpMAKTX__c;
                    tmpActualSales.MachineNo__c             = dummy.MachineNo__c;
                    tmpActualSales.Qty__c                   = dummy.Qty__c;
                    tmpActualSales.StockInDate__c           = tmpStockinDate;
                    //tmpActualSales.ProductionDate__c        = Dummy_IF_BatchUtil.getIFDate(dummy.ProductionDate__c);          // 제거
                    tmpActualSales.SalesDate__c             = tmpSalesDate;
                    tmpActualSales.SalesDocNo__c            = dummy.SalesDocNo__c;
                    tmpActualSales.SalesDocItem__c          = dummy.SalesDocItem__c;
                    tmpActualSales.OrderDivision__c         = dummy.OrderDivision__c;
                    tmpActualSales.Price__c                 = dummy.Price__c;
                    tmpActualSales.FirstDeliveryDate__c     = Dummy_IF_BatchUtil.getIFDate(dummy.FirstDeliveryDate__c);
                    tmpActualSales.ActualSalesDayOut__c     = dummy.ActualSalesDayOut__c;
                    tmpActualSales.ActualSalesDayIn__c      = dummy.ActualSalesDayIn__c;
                    tmpActualSales.ElapsedDayOut__c         = dummy.ElapsedDayOut__c;
                    tmpActualSales.ElapsedDayIn__c          = dummy.ElapsedDayIn__c;

                    // 제품 /
                    tmpActualSales.ProductId__c             = (tmpProduct != null) ? tmpProduct.Id : null;
                    tmpActualSales.ModelName__c             = (tmpProduct != null) ? tmpProduct.Name : null;
                    tmpActualSales.BaseModel__c             = (tmpProduct != null) ? tmpProduct.BaseModel__c : null;
                    tmpActualSales.ProductType__c           = (tmpProduct != null) ? tmpProduct.ProductType__c : null;
                    tmpActualSales.Segment__c               = (tmpProduct != null) ? tmpProduct.Segment__c : null;
                    tmpActualSales.Series__c                = (tmpProduct != null) ? tmpProduct.Series__c : null;
                    tmpActualSales.HorsePowerStandard__c    = (tmpProduct != null) ? tmpProduct.HorsePowerStandard__c : null;
                    tmpActualSales.Option1__c               = (tmpProduct != null) ? tmpProduct.Option1__c : null;
                    tmpActualSales.Option2__c               = (tmpProduct != null) ? tmpProduct.Option2__c : null;
                    tmpActualSales.Option3__c               = (tmpProduct != null) ? tmpProduct.Option3__c : null;
                    tmpActualSales.Option4__c               = (tmpProduct != null) ? tmpProduct.Option4__c : null;

                    targetList.add(tmpActualSales);
                    targetDmlDummyList.add(dummy);
                }
            }
*/
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

    /**
     * finish
     * 자신만의 처리사항이 있을 경우 overrid 구현할 것
     * @param BC : BatchableContext
     */

/*    public override void finish(Database.BatchableContext BC) {
        //============================================================================
        // super의 공통 finish 수행
        //============================================================================
        super.finish(BC);
        //============================================================================
        // 자신만의 finish 수행
        //============================================================================
    }*/

}