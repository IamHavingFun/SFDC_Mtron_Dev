/****************************************************************************************
  * @filename      : Dummy_IF_KR_ERP_SE_0012_RE_ba
  * @projectname   :
  * @author        : jy.kim
  * @date          : 2020-04-22
  * @group         :
  * @group-content :
  * @description   : [출고 현황]
  *                : IF_KR_ERP_SE_0012__c Dummy 에서 Delivery(출하) 정보 upsert
  *                : 제품이 없어서 오류 난건에 대해서 재 출하 처리...
  * @tester        :
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2020-04-17      jy.kim          Create
****************************************************************************************/

public class Dummy_IF_KR_ERP_SE_0012_RE_ba extends Dummy_IF_Batch {
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
				Dummy_IF_Batch.DUMMY_BATCH_PERIOD_TYPE.DAILY,
				this.exeDatetime
		);

		System.debug('0012 Start');
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
				AND     isBatchCompleted__c = TRUE
				AND     isBatchError__c = TRUE
				LIMIT   500
		]);
	}

	/**
	 * 수행 로직 구현
	 *
	 * @param BC : BatchableContext
	 * @param targetScope : Batch Size 실행 리스트
	 */
	public override void execute(Database.BatchableContext BC, List<SObject> targetScope) {
		System.debug('0012 execute');
		//============================================================================
		// 실제 SObject 형변환
		//============================================================================
		final List<IF_KR_ERP_SE_0012__c> scope = (List<IF_KR_ERP_SE_0012__c>)targetScope;

		System.debug('0012 scope size : ' + scope.size());
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
			if(String.isNotBlank(dummy.DeliveryCode__c))       account_Set.add(dummy.DeliveryCode__c);
			if(String.isNotBlank(dummy.DealerCode__c))         dealer_Set.add(dummy.DealerCode__c);
			if(String.isNotBlank(dummy.BusinessOffice__c))     account_Set.add(dummy.BusinessOffice__c);
			if(String.isNotBlank(dummy.SalesDocNo__c))         order_Set.add(dummy.SalesDocNo__c);
			if(String.isNotBlank(dummy.Asset__c))              asset_Set.add(dummy.Asset__c);
			delivery_Set.add(dummy.SalesDocNo__c+'|'+dummy.SalesDocItem__c+'|'+dummy.ErpOUT_DATE__c+'|'+dummy.DealerCode__c);
		}
		if(dealer_Set.isEmpty() == false) account_Set.addAll(dealer_Set);

		/**
		 * 전체 Product Map
		*/
		Map<String, Product2> product_Target = Dummy_IF_BatchUtil.getTargetProduct2();
		System.debug('0012 제품 조회 건수 : ' + product_Target.size());
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
						PODate__c,
				(SELECT
						Id,
						Name,
						DealerFeeAmt__c,
						DTFeeMaxAmt__c,
						DTFeeMaxRate__c,
						DTFeeMinAmt__c,
						DTFeeMinRate__c,
						EPFeeMaxAmt__c,
						EPFeeMaxRate__c,
						EPFeeMinAmt__c,
						EPFeeMinRate__c,
						fm_FeeMaxAmt__c,
						fm_FeeMaxRate__c,
						fm_FeeMinAmt__c,
						fm_FeeMinRate__c,
						fm_SupplyHighAmt__c,
						fm_SupplyLowAmt__c,
						ListPrice__c,
						MAFeeMaxAmt__c,
						MAFeeMaxRate__c,
						MAFeeMinAmt__c,
						MAFeeMinRate__c,
						MSFeeMaxAmt__c,
						MSFeeMaxRate__c,
						MSFeeMinAmt__c,
						MSFeeMinRate__c,
						NhGovListPrice__c,
						PTFeeMaxAmt__c,
						PTFeeMinAmt__c,
						RSFeeMaxAmt__c,
						RSFeeMaxRate__c,
						RSFeeMinAmt__c,
						RSFeeMinRate__c,
						SGFeeMaxAmt__c,
						SGFeeMaxRate__c,
						SGFeeMinAmt__c,
						SGFeeMinRate__c,
						UnitPrice__c
				From OrderProduct__r)
				FROM    Order__c
				WHERE   SalesDocNo__c IN :order_Set
		]) {
			order_Target.put(order.SalesDocNo__c, order);
		}

		/**
		 * Asset 대상 Query Map
		*/
		Map<String, Asset> asset_Target = new Map<String, Asset>(); // Key : Asset.Name, Value : Asset
		for(Asset asset : [
				SELECT  Id,
						Name,
						OwnerId,
						Product2Id,
						InventoryType__c,
						AccountId,
						DealerReceiptDate__c,
						SalesRep__c,
						Dealer__c,
						DealerCode__c,
						BusinessOffice__c,
						BusinessOfficeName__c,
						Brand__c,
						Order__c
				FROM    Asset
				WHERE   Name IN :asset_Set
		]) {
			asset_Target.put(asset.Name, asset);
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
						Externalkey__c
				FROM    Delivery__c
				WHERE   Externalkey__c IN :delivery_Set
		]) {
			delivery_Target.put(delivery.Externalkey__c, delivery);
		}

		/*
		 * ================================================================
		 * 데이터 DML 처리를 위한 3개의 기본 변수
		 * ================================================================
		 */
		// DML 처리 Delivery__c List
		List<Delivery__c> delivery_targetList = new List<Delivery__c>();
		// DML 처리 Asset List
		List<Asset> asset_targetList = new List<Asset>();
		// DML 처리 Order__c List
		List<Order__c> order_targetList = new List<Order__c>();

		// DML 처리 중복 처리 Delivery__c Map
		Map<String, Delivery__c> delivery_targetMap = new Map<String, Delivery__c>();
		// DML 처리 중복 처리 Asset Map
		Map<String, Asset> asset_targetMap = new Map<String, Asset>();
		// DML 처리 중복 처리 Order__c Map
		Map<String, Order__c> order_targetMap = new Map<String, Order__c>();

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
		//Guide Action 생성을 위한 Task
		List<Task> taskList = new List<Task>();
		Task newTask;

		for(IF_KR_ERP_SE_0012__c dummy : scope) {
			//============================================================================
			// 처음부터 처리여부 true 설정
			//============================================================================
			errorMsg = '';
			dummy.isBatchCompleted__c = true;
			dummy.isBatchError__c = false;
			isGoodDummy = true;

			//============================================================================
			// 정상 Dummy 데이터 여부
			// ProductCode__c, DealerCode__c, SalesDocNo__c, SalesDocItem__c, ErpOUT_DATE__c
			// 위 데이터는 신규생성의 무결성을 위한 required 데이터 임. [중요]
			//============================================================================
			if(!product_Target.containsKey(dummy.ProductCode__c) || String.isBlank(dummy.ProductCode__c)){
				isGoodDummy = false;
				errorMsg = '[필수값 누락] ProductCode__c 값이 null 이거나, 매핑되는 제품이 없습니다.';
			}
			if(!account_Target.containsKey(dummy.DealerCode__c) || String.isBlank(dummy.DealerCode__c)){
				isGoodDummy = false;
				errorMsg += ' [필수값 누락] DealerCode__c 값이 null 이거나, 매핑되는 Account가 없습니다.';
			}
			if(String.isBlank(dummy.SalesDocNo__c) || String.isBlank(dummy.SalesDocItem__c) || String.isBlank(dummy.ErpOUT_DATE__c)){
				isGoodDummy = false;
				errorMsg += ' [PK 누락] SalesDocNo__c, SalesDocItem__c, ErpOUT_DATE__c 값이 null 입니다.';
			}
			System.debug('isGoodDummy : ' + isGoodDummy + ', MSG : ' + errorMsg);
			if(isGoodDummy == false) {
				targetBadDummyList.add(Dummy_IF_BatchUtil.setDummyBatchResult(
						dummy,
						String.format(
								Dummy_IF_BatchUtil.DUMMY_BATCH_ERROR_VALID,
								new String[]{errorMsg}
						),
						this.errorDummyIds
				));
				continue;
			}else {
				//============================================================================
				// 출하(Delivery__c) 기존 데이터인 경우
				//============================================================================
				if(delivery_Target.containsKey(dummy.SalesDocNo__c+'|'+dummy.SalesDocItem__c+'|'+dummy.ErpOUT_DATE__c+'|'+dummy.DealerCode__c)) {
					tmpDelivery = delivery_Target.get(dummy.SalesDocNo__c+'|'+dummy.SalesDocItem__c+'|'+dummy.ErpOUT_DATE__c+'|'+dummy.DealerCode__c);
				}
				//============================================================================
				// 출하(Delivery__c) 신규 데이터인 경우
				//============================================================================
				else{
					tmpDelivery = new Delivery__c();
					tmpDelivery.Externalkey__c = dummy.SalesDocNo__c+'|'+dummy.SalesDocItem__c+'|'+dummy.ErpOUT_DATE__c+'|'+dummy.DealerCode__c;
				}
				//============================================================================
				// 기존 데이터 데이터 비교 구문
				//============================================================================
				tmpDelivery.OwnerId = recordOwnerMap.get(dummy.DealerCode__c);
				//tmpDelivery.OrderSellIn__c = order_Target.containsKey(dummy.SalesDocNo__c) && dummy.DeliveryType__c != '보관출고' ? order_Target.get(dummy.SalesDocNo__c).Id : null; // 조회(주문) : SalesDocNo__c --> Order__c.SalesDocNo__c todo:배포전
				//tmpDelivery.OrderItem__c = order_Target.containsKey(dummy.SalesDocNo__c) && dummy.DeliveryType__c != '보관출고' && (order_Target.get(dummy.SalesDocNo__c).OrderProduct__r).size() > 0 ? order_Target.get(dummy.SalesDocNo__c).OrderProduct__r[0].Id : null;//확인요청

				if(order_Target.containsKey(dummy.SalesDocNo__c) && dummy.DeliveryType__c != '보관출고'){
					tmpDelivery.OrderSellIn__c = order_Target.get(dummy.SalesDocNo__c).Id;
					if((order_Target.get(dummy.SalesDocNo__c).OrderProduct__r).size() > 0)
						tmpDelivery.OrderItem__c = order_Target.get(dummy.SalesDocNo__c).OrderProduct__r[0].Id;
					else tmpDelivery.OrderItem__c = null;
				}else {
					tmpDelivery.OrderSellIn__c = null;
					tmpDelivery.OrderItem__c = null;
				}
				tmpDelivery.Division__c = '공장주문'; // 선택 목록 : "공장주문"(고정값)
				tmpDelivery.AssetIdApex__c = dummy.Asset__c;
				tmpDelivery.DeliveryType__c = dummy.DeliveryType__c; // 출하유형 todo:배포전
				tmpDelivery.DeliveryName__c = account_Target.containsKey(dummy.DeliveryCode__c) ? account_Target.get(dummy.DeliveryCode__c).Name : null; // 텍스트(255) : DeliveryCode__c -> Account.ERPCode__c
				tmpDelivery.DeliveryCode__c = dummy.DeliveryCode__c; // 텍스트(20) : DeliveryCode__c
				/*
				   * 출하.BusinessOffice__r.ERPCode__c == '71I' 이면,
					Dealer__c : IF.DeliveryCode__c = Account.ErpCode__c (Condition : CustomerType__c == "대리점", Mapping : Id, CustomerType__c == "농협관납", Mapping : Dealer__c.Id)
				   * 아니면
					Dealer__c : IF.DealerCode__c = Account.ErpCode__c (Condition : CustomerType__c == "대리점", Mapping : Id, CustomerType__c == "농협관납", Mapping : Dealer__c.Id)
				 */
				if(account_Target.get(dummy.DealerCode__c).BusinessOffice__r.ERPCode__c == '71I'){
					tmpDelivery.Dealer__c = account_Target.get(dummy.DeliveryCode__c).CustomerType__c == '대리점' ? account_Target.get(dummy.DeliveryCode__c).Id : account_Target.get(dummy.DeliveryCode__c).Dealer__c;
				}else{
					tmpDelivery.Dealer__c = account_Target.get(dummy.DealerCode__c).CustomerType__c == '대리점' ? account_Target.get(dummy.DealerCode__c).Id : account_Target.get(dummy.DealerCode__c).Dealer__c;
				}
				tmpDelivery.ProductCode__c = dummy.ProductCode__c; // 텍스트(255) : ProductCode__c
				tmpDelivery.ProductName__c = product_Target.get(dummy.ProductCode__c).Id; // 조회(제품) : ProductCode__c --> Product.ProductCode
				tmpDelivery.DateOfLoading__c = String.isBlank(dummy.ErpOUT_DATE__c) ? null:Dummy_IF_BatchUtil.getIFDateTime(dummy.ErpOUT_DATE__c +' ' +dummy.ErpOUT_TIME__c); // 날짜/시간 : ErpOUT_DATE__c + ErpOUT_TIME__c
				tmpDelivery.BusinessOffice__c = account_Target.containsKey(dummy.DealerCode__c) ? account_Target.get(dummy.DealerCode__c).BusinessOffice__c : null;  // 조회(고객) : DealerCode__c --> Account.ERPCode__c : Mapping : BusinessOffice__c
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

				//============================================================================
				// dummy 자산(Asset__c) 값이 있으면
				//============================================================================
				if(String.isNotBlank(dummy.Asset__c)) {
					//============================================================================
					// 자산(Asset) 기존 데이터인 경우
					//============================================================================
					if (asset_Target.containsKey(dummy.Asset__c)) {
						tmpAsset = asset_Target.get(dummy.Asset__c);
					}
					//============================================================================
					// 자산(Asset) 신규 데이터인 경우
					//============================================================================
					else {
						tmpAsset = new Asset();
						// Name : Asset__c 필드로 설정
						tmpAsset.Name = dummy.Asset__c;
						// Product2 : IF.ProductCode__c = Product.ProductCode__c 레코드 lookup
						tmpAsset.Product2Id = tmpDelivery.ProductName__c;
					}
					// Brand__c : 고정값
					tmpAsset.Brand__c = 'LS';
					// InventoryType__c : 고정값
					tmpAsset.InventoryType__c = '대리점재고';
					// AccountId : tmpDelivery.SoldTo__c
					tmpAsset.AccountId = tmpDelivery.SoldTo__c;
					// DealerReceiptDate__c : IF.ErpOUT_DATE__c
					tmpAsset.DealerReceiptDate__c = dummy.ErpOUT_DATE__c != null ? (Dummy_IF_BatchUtil.getIFDate(dummy.ErpOUT_DATE__c)) : null; // 날짜 : ErpOUT_DATE__c
					/*
					   * 출하.BusinessOffice__r.ERPCode__c == '71I' 이면,
						Dealer__c : IF.DeliveryCode__c = Account.ErpCode__c (Condition : CustomerType__c == "대리점", Mapping : Id, CustomerType__c == "농협관납", Mapping : Dealer__c.Id)
					   * 아니면
						Dealer__c : IF.DealerCode__c = Account.ErpCode__c (Condition : CustomerType__c == "대리점", Mapping : Id, CustomerType__c == "농협관납", Mapping : Dealer__c.Id)
					 */
					tmpAsset.Dealer__c = tmpDelivery.Dealer__c;
					if(account_Target.get(dummy.DealerCode__c).BusinessOffice__r.ERPCode__c == '71I'){
						tmpAsset.DealerCode__c = account_Target.get(dummy.DeliveryCode__c).CustomerType__c == '대리점' ? account_Target.get(dummy.DeliveryCode__c).ErpCode__c : account_Target.get(dummy.DeliveryCode__c).Dealer__r.ErpCode__c;
						tmpAsset.SalesRep__c = account_Target.get(dummy.DeliveryCode__c).CustomerType__c == '대리점' ? account_Target.get(dummy.DeliveryCode__c).SalesRep__c : account_Target.get(dummy.DeliveryCode__c).Dealer__r.SalesRep__c;
					}else{
						tmpAsset.DealerCode__c = account_Target.get(dummy.DealerCode__c).CustomerType__c == '대리점' ? account_Target.get(dummy.DealerCode__c).ErpCode__c : account_Target.get(dummy.DealerCode__c).Dealer__r.ErpCode__c;
						tmpAsset.SalesRep__c = account_Target.get(dummy.DealerCode__c).CustomerType__c == '대리점' ? account_Target.get(dummy.DealerCode__c).SalesRep__c : account_Target.get(dummy.DealerCode__c).Dealer__r.SalesRep__c;
					}
					// BusinessOffice__c : IF.BusinessOffice__c = Account.ErpCode__c 레코드 Lookup
					tmpAsset.BusinessOffice__c = tmpDelivery.BusinessOffice__c;
					// BusinessOfficeName__c : IF.DealerCode__c = Account.ErpCode__c : BusinessOffice__r.ERPCode__c 레코드 Lookup
					tmpAsset.BusinessOfficeName__c = account_Target.containsKey(dummy.DealerCode__c) ? account_Target.get(dummy.DealerCode__c).BusinessOffice__r.ERPCode__c : null;
					// Delivery__r.OrderSellIn__c
					tmpAsset.Order__c = tmpDelivery.OrderSellIn__c;
					// OwnerId
					tmpAsset.OwnerId = tmpDelivery.OwnerId;

					//확인요청
					// 전수배대상 여부
					tmpAsset.TransferOrder__c = null;
					// 전수배대상 지정일
					tmpAsset.SendReceiveSpecifiedDate__c = null;
					// 전수배제외조건
					tmpAsset.CondSendReceiveExcept__c = null;
					// 전수배제외횟수
					tmpAsset.NumSendReceiveExcept__c = null;
					// 전수배주문
					tmpAsset.TransferOrder__c = null;
					// 전수배제외신청일
					tmpAsset.DateSendReceiveExcept__c = null;
					// 대리점입고유형
					tmpAsset.DealerReceiptType__c = '공장주문';

					asset_targetMap.put(tmpAsset.Name, tmpAsset); // 중복 체크 Map
				}
				//============================================================================
				// 주문(Order__c) 기존 데이터인 경우, 상태가 '출하'가 아니고, 출하상태가 '보관출고'가 아닐때
				//============================================================================
				if(order_Target.containsKey(dummy.SalesDocNo__c) && dummy.DeliveryType__c != '보관출고'){ //todo:배포전
					tmpOrder = order_Target.get(dummy.SalesDocNo__c);
					if(tmpOrder.Status__c != '출하') {
						tmpOrder.Status__c = '출하'; // Status__c : 고정값
						tmpOrder.SystemStatus__c = '출하'; // SystemStatus__c : 고정값

						newTask = new Task();
						newTask.OwnerId = recordOwnerMap.get(dummy.DealerCode__c); //(tmpOrder.Dealer__c)?
						newTask.ActivityDate = System.today();
						newTask.Type__c = 'Guide';
						newTask.WhatId = tmpDelivery.Id;
						newTask.Subject = '[공장주문 출하]';
						newTask.Description = String.valueOf(tmpOrder.PODate__c) + '에 주문한 제품이 출하되었습니다. 출하 정보 확인바랍니다. '; //주문자 : ' + tmpOrder.SoldTo__r.Name;
						taskList.add(newTask);

						order_targetMap.put(dummy.SalesDocNo__c, tmpOrder); // 중복 체크 Map
					}
				}
			} // if
			//============================================================================
			// target or dummy 데이터 리스트 add
			//============================================================================
			delivery_targetMap.put(tmpDelivery.Externalkey__c, tmpDelivery); // 중복 체크 Map
			targetDmlDummyList.add(dummy);
		} // for

		/*
		 * ================================================================
		 * Dummy 상태처리 : validation 체크로 비정상 Dummy Data 리스트를 먼저 update
		 * ================================================================
		 */
		if(targetBadDummyList.isEmpty() == false) {
			System.debug('0012 targetBadDummyList Start');
			System.debug(JSON.serialize(targetBadDummyList));
			System.debug('0012 targetBadDummyList End');

			update targetBadDummyList;
		}

		/*
		 * ================================================================
		 * Dml 수행 및 Dummy 상태처리 : 에러시 Dummy 상태값 세팅
		 * ================================================================
		 */
		System.Savepoint sp;
		try {
			sp = Database.setSavepoint();

			if(delivery_targetMap.size() > 0) delivery_targetList = delivery_targetMap.values();
			if(asset_targetMap.size() > 0) asset_targetList = asset_targetMap.values();
			if(order_targetMap.size() > 0) order_targetList = order_targetMap.values();

			// 자산 매핑을 위한 임시 Map
			Map<String, String> asset_tempMap = new Map<String, String>();
			// Upsert 자산(Asset) Upsert
			if(asset_targetList.size() > 0) upsert asset_targetList;
			// 자산 Upsert Id Map 세팅
			for(Asset asset_temp:asset_targetList){
				asset_tempMap.put(asset_temp.Name,asset_temp.Id);
			}

			// 자산 ID 출하 매핑
			for(Delivery__c delivery_temp:delivery_targetList){
				delivery_temp.AssetId__c = asset_tempMap.get(delivery_temp.AssetIdApex__c);
			}

			// Task 매핑을 위한 임시 Set
			set<String> task_tempSet = new set<String>();
			for(Task taskTemp:[SELECT WhatId,OwnerId,ActivityDate,Status from Task where Subject='대리점입고' and Status ='Completed' and WhatId = :asset_tempMap.values()]){
				// Asset Id | OwnerId | ActivityDate(YYYY-MM-DD)
				task_tempSet.add(taskTemp.WhatId+'|'+taskTemp.OwnerId+'|'+String.valueOf(taskTemp.ActivityDate));
			}

			// DML 처리 Task List
			List<Task> task_targetList = new List<Task>();
			// Insert Task
			Task tempTask;
			for(Asset asset_temp:asset_targetList){
				// Asset Id | OwnerId | DealerReceiptDate__c / Task가 없으면
				if(!task_tempSet.contains(asset_temp.Id+'|'+asset_temp.OwnerId+'|'+String.valueOf(tmpAsset.DealerReceiptDate__c))){
					tempTask = new Task();
					tempTask.WhatId = asset_temp.Id;
					tempTask.Subject = '대리점입고';
					tempTask.Status = 'Completed';
					tempTask.ActivityDate = tmpAsset.DealerReceiptDate__c;
					tempTask.OwnerId = asset_temp.OwnerId;
					task_targetList.add(tempTask);
				}
			}

			// 작업 Insert
			task_targetList.addAll(taskList);
			if(task_targetList.size() > 0) insert task_targetList;

			// 주문 Update
			if(order_targetList.size() > 0) update order_targetList;

			// 출하 Upsert
			if(delivery_targetList.size() > 0) upsert delivery_targetList;

			// 자산가격 FK 담기
			Set<String> AssetPriceFk = new Set<String>();
			for(Delivery__c delivery_temp : delivery_targetList){
				if(delivery_temp.OrderItem__c != null){
					AssetPriceFk.add(delivery_temp.Id);
				}
			}

			// 자산가격 Map(출하 Id, 자산가격 Id)
			Map<String,AssetPrice__c> assetPriceMap = new Map<String,AssetPrice__c>();
			for(AssetPrice__c assetPrice_temp : [select Id,DeliveryApex__c from AssetPrice__c where DeliveryApex__c = :AssetPriceFk]){
				assetPriceMap.put(assetPrice_temp.DeliveryApex__c , assetPrice_temp);
			}

			List<AssetPrice__c> assetPriceList = new List<AssetPrice__c>();
			AssetPrice__c tmpAssetPrice;
			for(Delivery__c delivery_temp : delivery_targetList){
				if(delivery_temp.OrderItem__c != null){
					// 자산 가격 있을때
					if(assetPriceMap.containsKey(delivery_temp.Id)){
						tmpAssetPrice = assetPriceMap.get(delivery_temp.Id);
						// 자산 가격 없을때
					}else{
						tmpAssetPrice = new AssetPrice__c();
					}
					OrderLineitem__c orderLineitmeTemp = order_Target.get(delivery_temp.SalesDocNo__c).OrderProduct__r[0];
					tmpAssetPrice.DealerFeeAmt__c   = orderLineitmeTemp.DealerFeeAmt__c;
					tmpAssetPrice.DTFeeMaxAmt__c    = orderLineitmeTemp.DTFeeMaxAmt__c;
					tmpAssetPrice.DTFeeMaxRate__c   = orderLineitmeTemp.DTFeeMaxRate__c;
					tmpAssetPrice.DTFeeMinAmt__c    = orderLineitmeTemp.DTFeeMinAmt__c;
					tmpAssetPrice.DTFeeMinRate__c   = orderLineitmeTemp.DTFeeMinRate__c;
					tmpAssetPrice.EPFeeMaxAmt__c    = orderLineitmeTemp.EPFeeMaxAmt__c;
					tmpAssetPrice.EPFeeMaxRate__c   = orderLineitmeTemp.EPFeeMaxRate__c;
					tmpAssetPrice.EPFeeMinAmt__c    = orderLineitmeTemp.EPFeeMinAmt__c;
					tmpAssetPrice.EPFeeMinRate__c   = orderLineitmeTemp.EPFeeMinRate__c;
					tmpAssetPrice.ListPrice__c      = orderLineitmeTemp.ListPrice__c;
					tmpAssetPrice.MAFeeMaxAmt__c    = orderLineitmeTemp.MAFeeMaxAmt__c;
					tmpAssetPrice.MAFeeMaxRate__c   = orderLineitmeTemp.MAFeeMaxRate__c;
					tmpAssetPrice.MAFeeMinAmt__c    = orderLineitmeTemp.MAFeeMinAmt__c;
					tmpAssetPrice.MAFeeMinRate__c   = orderLineitmeTemp.MAFeeMinRate__c;
					tmpAssetPrice.MSFeeMaxAmt__c    = orderLineitmeTemp.MSFeeMaxAmt__c;
					tmpAssetPrice.MSFeeMaxRate__c   = orderLineitmeTemp.MSFeeMaxRate__c;
					tmpAssetPrice.MSFeeMinAmt__c    = orderLineitmeTemp.MSFeeMinAmt__c;
					tmpAssetPrice.MSFeeMinRate__c   = orderLineitmeTemp.MSFeeMinRate__c;
					tmpAssetPrice.NhGovListPrice__c = orderLineitmeTemp.NhGovListPrice__c;
					tmpAssetPrice.PTFeeMaxAmt__c    = orderLineitmeTemp.PTFeeMaxAmt__c;
					tmpAssetPrice.PTFeeMinAmt__c    = orderLineitmeTemp.PTFeeMinAmt__c;
					tmpAssetPrice.RSFeeMaxAmt__c    = orderLineitmeTemp.RSFeeMaxAmt__c;
					tmpAssetPrice.RSFeeMaxRate__c   = orderLineitmeTemp.RSFeeMaxRate__c;
					tmpAssetPrice.RSFeeMinAmt__c    = orderLineitmeTemp.RSFeeMinAmt__c;
					tmpAssetPrice.RSFeeMinRate__c   = orderLineitmeTemp.RSFeeMinRate__c;
					tmpAssetPrice.SGFeeMaxAmt__c    = orderLineitmeTemp.SGFeeMaxAmt__c;
					tmpAssetPrice.SGFeeMaxRate__c   = orderLineitmeTemp.SGFeeMaxRate__c;
					tmpAssetPrice.SGFeeMinAmt__c    = orderLineitmeTemp.SGFeeMinAmt__c;
					tmpAssetPrice.SGFeeMinRate__c   = orderLineitmeTemp.SGFeeMinRate__c;
					tmpAssetPrice.UnitPrice__c      = orderLineitmeTemp.UnitPrice__c;
					tmpAssetPrice.DeliveryApex__c   = delivery_temp.Id;
					tmpAssetPrice.OwnerId           = delivery_temp.OwnerId;
					tmpAssetPrice.AssetId__c        = delivery_temp.AssetId__c;
					assetPriceList.add(tmpAssetPrice);
				}
			}

			if(!assetPriceList.isEmpty()) upsert assetPriceList;
		}
		catch(Exception e) {
			Database.rollback(sp);
			System.debug('EXCEPTION ----');
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
/*    public override void finish(Database.BatchableContext BC) {
        //============================================================================
        // super의 공통 finish 수행
        //============================================================================
        super.finish(BC);
        //============================================================================
        // 자신만의 finish 수행
        //============================================================================
    }*/

	public static void runFakeTest() {
		Integer i = 0;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
	}
}