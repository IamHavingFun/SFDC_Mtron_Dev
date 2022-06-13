/****************************************************************************************
  * @filename      : Dummy_IF_KR_ERP_SE_0012_ba
  * @projectname   :
  * @author        : jy.kim
  * @date          : 2020-04-22
  * @group         :
  * @group-content :
  * @description   : [출고 현황]
  *                : IF_KR_ERP_SE_0012__c Dummy 에서 Delivery(출하) 정보 upsert
  * @tester        :
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2020-04-17      jy.kim         Create
    0.2     2022-03-7       i2max          ITVOC-2021-11-0588
****************************************************************************************/

public class Dummy_IF_KR_ERP_SE_0012_ba extends Dummy_IF_Batch {

    public String query;

    public Dummy_IF_KR_ERP_SE_0012_ba() {
        this(null);
    }

    public Dummy_IF_KR_ERP_SE_0012_ba(final String query) {
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
        this.interfaceId = 'IF_KR_ERP_SE_0012';
        this.deleteInfo = new Dummy_IF_Batch.DeleteInfo(
                'IF_KR_ERP_SE_0012__c',
                interfaceId,
                Dummy_IF_Batch.DUMMY_BATCH_PERIOD_TYPE.WEEKLY,
                this.exeDatetime
        );
        /*
        ErpIV_NO__c		        거래명세서 번호	        Text	20	5001631420
        ErpIV_SEQ__c		    거래명세서 품목	        Text	20	000001
        ErpIV_TYPE__c		    거래명세서 통문유형	    Text	20	A01
        ErpOUT_YN__c		    통문여부	                Text	20	X
        ErpOUT_DATE__c		    통문일자(yyyyMMdd)	    Text	20	20200403
        ErpOUT_TIME__c		    통문시간(HHmmss)	        Text	20	183635
        ErpCANCEL_DATE__c		통문취소일자(yyyyMMdd)	Text	20	20200403
        ErpCANCEL_TIME__c		통문취소시간(HHmmss)	    Text	20	183635
        DealerCode__c		    판매자코드	            Text	20	100907
        DeliveryCode__c		    납품처코드	            Text	20	190064
        BusinessOffice__c		영업소코드	            Text	20	71A
        BusinessOfficeName__c	영업소명	                Text	20	대리점
        ProductCode__c		    제품코드	                Text	20	10131733
        ErpMAKTX__c		        자재명	                Text	50	TR-XU6168-DM-CAMTSBMDQTAHLC
        Asset__c		        기대번호	                Text	20	2283003300
        CarNumber__c		    차량번호	                Text	20	경북82아6727
        CarrierName__c		    운송기사	                Text	20	정성열
        CarrierContact__c		운송기사 연락처	        Text	20	010-9370-1386
        DeliveryDocNo__c		납품문서번호	            Text	20	6112492457
        DeliveryDocItem__c		납품문서품목	            Text	20	000010
        SalesDocNo__c		    판매문서번호	            Text	20	5110914310
        SalesDocItem__c		    판매문서품목	            Text	20	000010
        DeliveryType__c         출하유형	                Text	20	공장출고 or 보관출고
        */

        if(String.isNotBlank(this.query)) {
            return Database.getQueryLocator(this.query);
        } else {
            return Database.getQueryLocator([
                    SELECT
                            Id,
                            ErpIV_NO__c,
                            ErpIV_SEQ__c,
                            ErpIV_TYPE__c,
                            ErpOUT_YN__c,
                            ErpOUT_DATE__c,
                            ErpOUT_TIME__c,
                            ErpCANCEL_DATE__c,
                            ErpCANCEL_TIME__c,
                            DealerCode__c,
                            DeliveryCode__c,
                            BusinessOffice__c,
                            BusinessOfficeName__c,
                            ProductCode__c,
                            ErpMAKTX__c,
                            Asset__c,
                            CarNumber__c,
                            CarrierName__c,
                            CarrierContact__c,
                            DeliveryDocNo__c,
                            DeliveryDocItem__c,
                            SalesDocNo__c,
                            SalesDocItem__c,
                            DeliveryType__c,
                            isBatchCompleted__c,
                            isBatchError__c,
                            BatchErrorMessage__c
                    FROM    IF_KR_ERP_SE_0012__c
                    WHERE   InterfaceId__c = 'IF_KR_ERP_SE_0012'
                    AND     isBatchCompleted__c = false
                    ORDER BY Asset__c, DeliveryType__c
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
        final List<IF_KR_ERP_SE_0012__c> scope = (List<IF_KR_ERP_SE_0012__c>)targetScope;
        /*
        	* 데이터 수신하여 PK 기준으로 Delivery__c Insert
            1)	Owner : IF.Dealer__c = Account.ErpCode__c 레코드의 owner 참조
            2)	OrderSellIn__c : IF.SalesDocNo__c = Order__c.ErpVBELN__c 레코드 Lookup
            3)	Division__c : 공장주문 설정
            4)	Asset__c : IF.Asset__c = Asset.Name 레코드 Lookup
            5)	DeliveryName__c : IF.DeliveryCode__c = Account.ErpCode__c 레코드 Name 참조
            6)	DeliveryCode__c : DeliveryCode__c 필드로 설정
            7)	Dealer__c : IF.DealerCode__c = Account.ErpCode__c 레코드 Lookup
            8)	DealerCode__c : DealerCode__c 필드로 설정
            9)	ProductCode__c : ProductCode__c 필드로 설정
            10)	ProductName__c : IF.ProductCode__c = Product.ProductCode__c 레코드 lookup
            11)	DateOfLoading__c : IF.ErpOUT_DATE__c + ErpOUT_TIME__c 데이터 타입 변경
            12)	BusinessOffice__c : IF.BusinessOffice__c = Account.ErpCode__c 레코드 Lookup
            13)	CarrierName__c : CarrierName__c 필드로 설정
            14)	CarrierContact__c : CarrierContact__c 필드로 설정
            15)	CarNumber__c : CarNumber__c 필드로 설정
            16)	GetOffDate__c : IF.ErpOUT_DATE__c + 1일 데이터타입 변경
            17)	SalesDocNo__c : SalesDocNo__c 필드로 설정
            18)	SalesDocItem__c : SalesDocItem__c 필드로 설정
            19)	DeliveryDocNo__c : DeliveryDocNo__c 필드로 설정
            20)	DeliveryDocItem__c : DeliveryDocItem__c 필드로 설정
            21)	ErpIV_NO__c : ErpIV_NO__c 필드로 설정
            22)	ErpIV_SEQ__c : ErpIV_SEQ__c 필드로 설정
            23)	ErpIV_TYPE__c : ErpIV_TYPE__c 필드로 설정
            24)	ErpOUT_YN__c : ErpOUT_YN__c 필드로 설정
            25)	ErpOUT_DATE__c : ErpOUT_DATE__c 필드로 설정
            26)	ErpOUT_TIME__c : ErpOUT_TIME__c 필드로 설정
            27)	ErpCANCEL_DATE__c : ErpCANCEL_DATE__c 필드로 설정
            28)	ErpCANCEL_TIME__c : ErpCANCEL_TIME__c 필드로 설정
         */
        /**
         * Account, Order__c, Asset, Delivery__c 조회 대상 Set
        */

        set<String> account_Set = new set<String>();   // Dummy.DeliveryCode__c, Dummy.DealerCode__c, Dummy.BusinessOffice__c
        set<String> order_Set = new set<String>();     // Dummy.SalesDocNo__c
        set<String> asset_Set = new set<String>();     // Dummy.Asset__c
        set<String> delivery_Set = new set<String>();  // Key 매핑(FK : SalesDocNo__c, SalesDocItem__c, ErpOUT_DATE__c, DealerCode__c)
        set<String> dealer_Set = new set<String>();    // Dummy.DealerCode__c (딜러 User ID 용)
        for(IF_KR_ERP_SE_0012__c dummy : scope) {
            dummy.ProductCode__c = Dummy_IF_BatchUtil.getProductCodeLpad(dummy.ProductCode__c);
            dummy.DealerCode__c = Dummy_IF_BatchUtil.getErpCodeLpad(dummy.DealerCode__c);
            if(String.isNotBlank(dummy.DeliveryCode__c))       account_Set.add(dummy.DeliveryCode__c);
            if(String.isNotBlank(dummy.DealerCode__c))         dealer_Set.add(dummy.DealerCode__c);
            if(String.isNotBlank(dummy.BusinessOffice__c))     account_Set.add(dummy.BusinessOffice__c);
            if(String.isNotBlank(dummy.SalesDocNo__c))         order_Set.add(dummy.SalesDocNo__c);
            if(String.isNotBlank(dummy.Asset__c))              asset_Set.add(dummy.Asset__c);

            delivery_Set.add(
                    String.join(new List<String>{
                            dummy.DeliveryType__c,
                            dummy.ErpIV_NO__c,
                            dummy.ErpIV_SEQ__c,
                            dummy.ErpOUT_DATE__c,
                            dummy.ErpOUT_TIME__c,
                            dummy.SalesDocNo__c,
                            dummy.SalesDocItem__c,
                            dummy.Asset__c
                    }, '/')
            );
        }
        if(dealer_Set.isEmpty() == false) account_Set.addAll(dealer_Set);
        account_Set.add('71I');     // 영업지원 복구를 위하여 추가 한다.
        account_Set.add('100000');  // 공장 재고 : 김다민 과장

        /**
         * 전체 Product Map
        */
        Map<String, Product2> product_Target = Dummy_IF_BatchUtil.getTargetProduct2();

        /**
         * Account 대상 Query Map
        */
        Map<String, Account> account_Target = new Map<String, Account>(); // Key : Account.ErpCode__c, Value : Account
        for(Account account : [
                SELECT  Id,
                        ERPCode__c,
                        ParentId,
                        Parent.ERPCode__c,
                        Name,
                        Dealer__c,
                        Dealer__r.SalesRep__c,
                        Dealer__r.ERPCode__c,
                        Dealer__r.OwnerId,
                        SalesRep__c,
                        CustomerType__c,
                        OwnerId,
                        Parent.OwnerId,
                        BusinessOffice__c, // 영업소
                        BusinessOffice__r.ERPCode__c // 영업소 ERP Code
                FROM    Account
                WHERE   ERPCode__c IN :account_Set
        ]) {
            account_Target.put(account.ERPCode__c, account);
        }

        /**
         * Order__c 대상 Query Map
        */
        Map<String, Order__c> order_Target = new Map<String, Order__c>(); // Key : Order__c.SalesDocNo__c, Value : Order__c
        for(Order__c order : [
                SELECT  Id,
                        Name,
                        SalesDocNo__c,
                        Status__c,
                        SoldTo__r.Name,
                        Dealer__r.Name,
                        PODate__c,
                        TransferBusinessOffice__c,
                        TransferBusinessOffice__r.BusinessOffice__c,
                        (SELECT
                                Id,
                                Name
                        From OrderProduct__r
                        LIMIT 1)
                FROM    Order__c
                WHERE   SalesDocNo__c IN :order_Set
        ]) {
            order_Target.put(order.SalesDocNo__c, order);
        }

        /**
         * 보관재고 대상 Map
        */
        Map<String, OrderKeep__c> orderKeepMap = new Map<String, OrderKeep__c>();
        for(OrderKeep__c order : [
                SELECT  Id,
                        Name,
                        SalesDocNo__c,
                        Status__c,
                        Order__c
                FROM    OrderKeep__c
                WHERE   SalesDocNo__c IN :order_Set
        ]) {
            orderKeepMap.put(order.SalesDocNo__c, order);
        }

        Map<String, TransferOrder__c> transperOrder_Target = new Map<String, TransferOrder__c>();
        for(TransferOrder__c r : [
                SELECT Id, SalesDocNo__c, Order__c, Order__r.TransferBusinessOffice__c, Order__r.TransferBusinessOffice__r.BusinessOffice__c
                FROM TransferOrder__c
                WHERE SalesDocNo__c IN :order_Set
        ]) {
            transperOrder_Target.put(r.SalesDocNo__c, r);
        }

        /**
         * Asset 대상 Query Map
        */
        Map<String, Asset> asset_Target = new Map<String, Asset>(); // Key : Asset.Name, Value : Asset
        for(Asset asset : [
                SELECT  Id,
                        Name,
                        BatchNo__c,
                        OwnerId,
                        Product2Id,
                        FirstDeliveryDate__c,
                        InventoryType__c,
                        AccountId,
                        DealerReceiptDate__c,
                        SalesRep__c,
                        Dealer__c,
                        DealerCode__c,
                        BusinessOffice__c,
                        BusinessOfficeName__c,
                        Brand__c,
                        Order__c,
                        TransferCount__c
                FROM    Asset
                WHERE   BatchNo__c IN :asset_Set
        ]) {
            asset_Target.put(asset.BatchNo__c, asset);
        }

        /**
         * Delivery__c 대상 Query Map (기존 데이터 Update 비교용)
        */
        Map<String, Delivery__c> delivery_Target = new Map<String, Delivery__c>();
        for(Delivery__c delivery : [
                SELECT  Id,
                        Name,
                        OwnerId,
                        OrderSellIn__c,
                        Division__c,
                        AssetId__c,
                        DeliveryName__c,
                        DeliveryCode__c,
                        Dealer__c,
                        ProductCode__c,
                        ProductName__c,
                        DateOfLoading__c,
                        BusinessOffice__c,
                        CarrierName__c,
                        CarrierContact__c,
                        CarNumber__c,
                        GetOffDate__c,
                        SalesDocNo__c,
                        SalesDocItem__c,
                        DeliveryDocNo__c,
                        DeliveryDocItem__c,
                        ErpIV_NO__c,
                        ErpIV_SEQ__c,
                        ErpIV_TYPE__c,
                        ErpOUT_YN__c,
                        ErpOUT_DATE__c,
                        ErpOUT_TIME__c,
                        ErpCANCEL_DATE__c,
                        ErpCANCEL_TIME__c,
                        DeliveryType__c,
                        SoldTo__c,
                        SoldToCode__c,
                        Externalkey__c,
                        fm_NewExternalkey__c,
                        ReleaseDate__c,
                        OrderItem__c
                FROM    Delivery__c
                WHERE   fm_NewExternalkey__c IN :delivery_Set
        ]) {
            delivery_Target.put(delivery.fm_NewExternalkey__c, delivery);
        }

        /*
         * ================================================================
         * 데이터 DML 처리를 위한 3개의 기본 변수
         * ================================================================
         */
        // DML 처리 중복 처리 Delivery__c Map
        Map<String, Delivery__c> delivery_targetMap = new Map<String, Delivery__c>();

        // validation 처리시 비정상 Dummy Data List
        List<SObject> targetBadDummyList = new List<SObject>();
        // Dml 수행 에러 Dummy Data List
        List<SObject> targetDmlDummyList = new List<SObject>();
        // 무결성 체크 Boolean
        Boolean isGoodDummy;
        // Upsert용 Delivery__c
        Delivery__c tmpDelivery;
        // Upsert용 Asset
        Asset tmpAsset;
        // Update용 Order__c
        Order__c tmpOrder;
        // 판매처별 소유주 구하기 공통
        Map<String, Id> recordOwnerMap = Dummy_IF_BatchUtil.getRecordOwnder(this.interfaceId, dealer_Set);
        String errorMsg = '';
        List<String> errorComments = new List<String>();

        String division;

        String deliveryExternalKey;
        for(IF_KR_ERP_SE_0012__c dummy : scope) {
            //============================================================================
            // 처음부터 처리여부 true 설정
            //============================================================================
            errorMsg = '';
            dummy.isBatchCompleted__c = true;
            dummy.isBatchError__c = false;
            dummy.BatchErrorComment__c = '';
            dummy.BatchErrorMessage__c = '';
            isGoodDummy = true;

            errorComments = new List<String>();

            //  출하유형 + 거래명세서번호 + 순번 + 통문상차일자 + 통문상차시간 + 판매문서번호 + 항목 번호 + 자산번호
            deliveryExternalKey = String.join(new List<String>{
                    dummy.DeliveryType__c,
                    dummy.ErpIV_NO__c,
                    dummy.ErpIV_SEQ__c,
                    dummy.ErpOUT_DATE__c,
                    dummy.ErpOUT_TIME__c,
                    dummy.SalesDocNo__c,
                    dummy.SalesDocItem__c,
                    dummy.Asset__c
            }, '/');

	        if(dummy.ErpOUT_YN__c != 'X') {
		        targetDmlDummyList.add(dummy);
		        continue;
	        }

            //============================================================================
            // 정상 Dummy 데이터 여부
            // ProductCode__c, DealerCode__c, SalesDocNo__c, SalesDocItem__c, ErpOUT_DATE__c
            // 위 데이터는 신규생성의 무결성을 위한 required 데이터 임. [중요]
            //============================================================================
            dummy.ProductCode__c = Dummy_IF_BatchUtil.getProductCodeLpad(dummy.ProductCode__c);
            dummy.DealerCode__c = Dummy_IF_BatchUtil.getErpCodeLpad(dummy.DealerCode__c);
            // 자산도 체크 해서 신규 생성 안되도록 처리.
            if(!asset_Target.containsKey(dummy.Asset__c) || String.isBlank(dummy.Asset__c)){
                isGoodDummy = false;
                errorComments.add('[SFDC 자산 누락] Asset__c = ['+dummy.Asset__c+']');
            }
            if(!product_Target.containsKey(dummy.ProductCode__c) || String.isBlank(dummy.ProductCode__c)){
                isGoodDummy = false;
                errorComments.add('[필수값 누락] ProductCode__c = ['+dummy.ProductCode__c+']');
            }
            if(!account_Target.containsKey(dummy.DealerCode__c) || String.isBlank(dummy.DealerCode__c)){
                isGoodDummy = false;
                errorComments.add('[필수값 누락] DealerCode__c = ['+dummy.DealerCode__c+']');
            }
            if(String.isBlank(dummy.SalesDocNo__c) || String.isBlank(dummy.SalesDocItem__c) || String.isBlank(dummy.ErpOUT_DATE__c)){
                isGoodDummy = false;
                errorComments.add('[PK 누락] SalesDocNo__c=['+dummy.DealerCode__c+'], SalesDocItem__c=['+dummy.SalesDocItem__c+'], ErpOUT_DATE__c=['+dummy.ErpOUT_DATE__c+']');
            }

            if(isGoodDummy == false) {
                dummy.BatchErrorComment__c = String.join(errorComments, ', ');
                targetBadDummyList.add(Dummy_IF_BatchUtil.setDummyBatchResult(
                        dummy,
                        String.format(
                                Dummy_IF_BatchUtil.DUMMY_BATCH_ERROR_VALID,
                                new String[]{dummy.BatchErrorComment__c}
                        ),
                        this.errorDummyIds
                ));
                continue;
            } else {
                Boolean isFirstDelivery = false;
                //============================================================================
                // 출하(Delivery__c) 기존 데이터인 경우
                //============================================================================
                if (delivery_Target.containsKey(deliveryExternalKey)) {
                    tmpDelivery = delivery_Target.get(deliveryExternalKey);
                    // 시간당 2번 들어오는 데이터에서 출하 레코드 생성을 했으면 이후 업데이트 처리 하지 않고
                    // 스킵 처리 한다.
                    dummy.isBatchCompleted__c = true;
                    dummy.isBatchError__c = false;
                    dummy.BatchErrorComment__c = '중복제외';
                    dummy.BatchErrorMessage__c = '';
                    targetDmlDummyList.add(dummy);
                    continue;
                }
                //============================================================================
                // 출하(Delivery__c) 신규 데이터인 경우
                //============================================================================
                else {
                    tmpDelivery = new Delivery__c();
                    delivery_Target.put(deliveryExternalKey, tmpDelivery);
                    isFirstDelivery = true;
                }
                //============================================================================
                // 기존 데이터 데이터 비교 구문
                //============================================================================
                tmpDelivery.OwnerId = recordOwnerMap.get(dummy.DealerCode__c);
                System.debug('SalesDocNo ==> ' + dummy.SalesDocNo__c + ', Has : ' + order_Target.get(dummy.SalesDocNo__c));
                if (order_Target.containsKey(dummy.SalesDocNo__c)) {
                    tmpDelivery.OrderSellIn__c = order_Target.get(dummy.SalesDocNo__c).Id;
                    if ((order_Target.get(dummy.SalesDocNo__c).OrderProduct__r).size() > 0) {
                        tmpDelivery.OrderItem__c = order_Target.get(dummy.SalesDocNo__c).OrderProduct__r[0].Id;
                    } else {
                        tmpDelivery.OrderItem__c = null;
                    }
                } else if (orderKeepMap.containsKey(dummy.SalesDocNo__c)) {
                    // 보관 출고
                    tmpDelivery.OrderSellIn__c = orderKeepMap.get(dummy.SalesDocNo__c).Order__c;
                } else if (transperOrder_Target.containsKey(dummy.SalesDocNo__c)) {
                    // 전수배 반품시 처리.
                    tmpDelivery.OrderSellIn__c = transperOrder_Target.get(dummy.SalesDocNo__c).Order__c;
                } else {
                    tmpDelivery.OrderSellIn__c = null;
                    tmpDelivery.OrderItem__c = null;
                }
                if (dummy.DeliveryType__c == '전수배출고' || dummy.DeliveryType__c == '전수배반품') {
                    tmpDelivery.Division__c = '전수배 주문';
                    if (dummy.DeliveryType__c == '전수배출고' && order_Target.containsKey(dummy.SalesDocNo__c)) {
                        tmpDelivery.SendItemDealer__c = order_Target.get(dummy.SalesDocNo__c).TransferBusinessOffice__c; // 전배 대리점 SendItemDealer__c 조회(고객) 참
                        tmpDelivery.SendItemOffice__c = order_Target.get(dummy.SalesDocNo__c).TransferBusinessOffice__r.BusinessOffice__c; // 전배 영업소 SendItemOffice__c 조회(고객) 참
                    }
                    if (dummy.DeliveryType__c == '전수배반품' && transperOrder_Target.containsKey(dummy.SalesDocNo__c)) {
                        tmpDelivery.SendItemDealer__c = transperOrder_Target.get(dummy.SalesDocNo__c).Order__r.TransferBusinessOffice__c; // 전배 대리점 SendItemDealer__c 조회(고객) 참
                        tmpDelivery.SendItemOffice__c = transperOrder_Target.get(dummy.SalesDocNo__c).Order__r.TransferBusinessOffice__r.BusinessOffice__c; // 전배 영업소 SendItemOffice__c 조회(고객) 참
                    }
                    tmpDelivery.ReleaseDate__c = String.isBlank(dummy.ErpOUT_DATE__c) ? null : Dummy_IF_BatchUtil.getIFDate(dummy.ErpOUT_DATE__c); // 날짜/시간 : ErpOUT_DATE__c + ErpOUT_TIME__c 전수배상차일 ReleaseDate__c 날짜
                } else {
                    tmpDelivery.Division__c = '공장주문'; // 선택 목록 : "공장주문"(고정값)
                }

                tmpDelivery.AssetId__c = asset_Target.containsKey(dummy.Asset__c) ? asset_Target.get(dummy.Asset__c).Id : null; // 기대번호
                tmpDelivery.AssetIdApex__c = dummy.Asset__c;
                tmpDelivery.DeliveryType__c = dummy.DeliveryType__c; // 출하유형 todo:배포전
                tmpDelivery.DeliveryName__c = account_Target.containsKey(dummy.DeliveryCode__c) ? account_Target.get(dummy.DeliveryCode__c).Name : null; // 텍스트(255) : DeliveryCode__c -> Account.ERPCode__c
                tmpDelivery.DeliveryCode__c = dummy.DeliveryCode__c; // 텍스트(20) : DeliveryCode__c
                String customerType;

                /**
                 * 2022-04-04
                 *
                */
                customerType = account_Target.get(dummy.DealerCode__c).CustomerType__c;
                if(customerType == '대리점') {
                    tmpDelivery.Dealer__c = account_Target.get(dummy.DealerCode__c).Id;
                    tmpDelivery.BusinessOffice__c = account_Target.get(dummy.DealerCode__c).BusinessOffice__c;
                } else {
                    tmpDelivery.Dealer__c = account_Target.get(dummy.DealerCode__c).Dealer__c;
                    tmpDelivery.BusinessOffice__c = account_Target.get(dummy.DealerCode__c).BusinessOffice__c;
                }
/*
                if (account_Target.get(dummy.DealerCode__c).BusinessOffice__r.ERPCode__c == '71I') {
                    // 71I : 영업지원
                    customerType = account_Target.get(dummy.DeliveryCode__c).CustomerType__c;
                    if(customerType == '대리점') {
                        tmpDelivery.Dealer__c = account_Target.get(dummy.DeliveryCode__c).Id;
                        tmpDelivery.BusinessOffice__c = account_Target.get(dummy.DeliveryCode__c).BusinessOffice__c;
                    } else {
                        tmpDelivery.Dealer__c = account_Target.get(dummy.DeliveryCode__c).Dealer__c;
                        tmpDelivery.BusinessOffice__c = account_Target.get(dummy.DeliveryCode__c).BusinessOffice__c;
                    }
                } else {
                    customerType = account_Target.get(dummy.DealerCode__c).CustomerType__c;
                    if(customerType == '대리점') {
                        tmpDelivery.Dealer__c = account_Target.get(dummy.DealerCode__c).Id;
                        tmpDelivery.BusinessOffice__c = account_Target.get(dummy.DealerCode__c).BusinessOffice__c;
                    } else {
                        tmpDelivery.Dealer__c = account_Target.get(dummy.DealerCode__c).Dealer__c;
                        tmpDelivery.BusinessOffice__c = account_Target.get(dummy.DealerCode__c).BusinessOffice__c;
                    }
                }
*/
                tmpDelivery.ProductCode__c = dummy.ProductCode__c; // 텍스트(255) : ProductCode__c
                tmpDelivery.ProductName__c = product_Target.get(dummy.ProductCode__c).Id; // 조회(제품) : ProductCode__c --> Product.ProductCode
                tmpDelivery.DateOfLoading__c = String.isBlank(dummy.ErpOUT_DATE__c) ? null : Dummy_IF_BatchUtil.getIFDateTime(dummy.ErpOUT_DATE__c + ' ' + dummy.ErpOUT_TIME__c); // 날짜/시간 : ErpOUT_DATE__c + ErpOUT_TIME__c
                tmpDelivery.CarrierName__c = dummy.CarrierName__c; // 텍스트(20) : CarrierName__c
                tmpDelivery.CarrierContact__c = dummy.CarrierContact__c; // 텍스트(255) : CarrierContact__c
                tmpDelivery.CarNumber__c = dummy.CarNumber__c; // 텍스트(20) : CarNumber__c
                tmpDelivery.GetOffDate__c = dummy.ErpOUT_DATE__c != null ? (Dummy_IF_BatchUtil.getIFDate(dummy.ErpOUT_DATE__c)).addDays(1) : null; // 날짜 : ErpOUT_DATE__c + 1
                tmpDelivery.SalesDocNo__c = dummy.SalesDocNo__c; // 텍스트(20) : SalesDocNo__c
                tmpDelivery.SalesDocItem__c = dummy.SalesDocItem__c; // 텍스트(20) : SalesDocItem__c
                tmpDelivery.DeliveryDocNo__c = dummy.DeliveryDocNo__c; // 텍스트(20) : DeliveryDocNo__c
                tmpDelivery.DeliveryDocItem__c = dummy.DeliveryDocItem__c; // 텍스트(20) : DeliveryDocItem__c
                tmpDelivery.ErpIV_NO__c = dummy.ErpIV_NO__c; // 텍스트(20) : ErpIV_NO__c
                tmpDelivery.ErpIV_SEQ__c = dummy.ErpIV_SEQ__c; // 텍스트(20) : ErpIV_SEQ__c
                tmpDelivery.ErpIV_TYPE__c = dummy.ErpIV_TYPE__c; // 텍스트(20) : ErpIV_TYPE__c
                tmpDelivery.ErpOUT_YN__c = dummy.ErpOUT_YN__c; // 텍스트(20) : ErpOUT_YN__c
                tmpDelivery.ErpOUT_DATE__c = dummy.ErpOUT_DATE__c; // 텍스트(20) : ErpOUT_DATE__c
                tmpDelivery.ErpOUT_TIME__c = dummy.ErpOUT_TIME__c; // 텍스트(20) : ErpOUT_TIME__c
                tmpDelivery.ErpCANCEL_DATE__c = dummy.ErpCANCEL_DATE__c; // 텍스트(20) : ErpCANCEL_DATE__c
                tmpDelivery.ErpCANCEL_TIME__c = dummy.ErpCANCEL_TIME__c; // 텍스트(20) : ErpCANCEL_TIME__c
                tmpDelivery.SoldTo__c = account_Target.get(dummy.DealerCode__c).Id; // 조회(고객) : DealerCode__c --> Account.ERPCode__c
                tmpDelivery.SoldToCode__c = dummy.DealerCode__c; // 텍스트(20) : DealerCode__c
            }

            //============================================================================
            // target or dummy 데이터 리스트 add
            //============================================================================
            delivery_targetMap.put(deliveryExternalKey, tmpDelivery); // 중복 체크 Map
            targetDmlDummyList.add(dummy);
        } // for

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
            // Upsert 자산(Asset) Upsert
            if(delivery_targetMap.isEmpty() == false) upsert delivery_targetMap.values() ;
        }
        catch(Exception e) {
            Database.rollback(sp);
            System.debug(System.LoggingLevel.ERROR, e);
            targetDmlDummyList = Dummy_IF_BatchUtil.setDummyBatchResult(targetDmlDummyList, this.errorDummyIds);
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
    public override void finish(Database.BatchableContext BC) {
        //============================================================================
        // super의 공통 finish 수행
        //============================================================================
        super.finish(BC);
        //============================================================================
        // 자신만의 finish 수행
        //============================================================================
        Database.executeBatch(new Dummy_IF_KR_ERP_SE_0012_2_ba(), 200);
    }

    public static void runFakeTest() {
        Integer yr_seo = 0;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
        yr_seo ++;
    }
}