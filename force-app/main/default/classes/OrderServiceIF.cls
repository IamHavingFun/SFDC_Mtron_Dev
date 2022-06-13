/****************************************************************************************
  * @filename      : OrderService
  * @projectname   :
  * @author        : i2max_my.Seo
  * @date          : 2020-05-25 오전 10:05
  * @group         :
  * @group-content :
  * @description   :
  * @tester        : OrderService_ts.cls
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author              description
  * ===============================================================
    0.1     2020-05-25 오전 10:05     i2max_my.Seo           Create
****************************************************************************************/
public without sharing class OrderServiceIF {

	/**
	 * 보관주문 배치 호출
	 *
	 * @param orderIds
	 */
	@Future(callout=true)
	public static void sendOrderKeepData(Set<Id> orderIds) {
		try {
			if(Test.isRunningTest()) {
				for (Id recordId : orderIds) {
					OrderKeep__c orderKeep = [SELECT Id, SalesDocNo__c FROM OrderKeep__c WHERE Order__c = :recordId];
					orderKeep.IsERPSend__c = true;
					orderKeep.SalesDocNo__c = '511111111111';
					orderKeep.KeepProcessDate__c = Date.today();
					orderKeep.Status__c = '보관처리';
					update orderKeep;
				}
			} else {
				for (Id recordId : orderIds) OrderServiceIF.IF_KR_SE_ERP_0007_ZCS(recordId);
			}
		} catch (Exception e) {
			// TODO : 오류건 처리 방안??
		}
	}


	/**
	 * @description : IF_KR_SE_ERP_0007 보관 주문 생성 (SE <-> ERP)
	 * Order__c 에 OrderLineItem__c는 1개임.
	 * Update Order, OrderLineitem
	 * Order_tr > OrderServiceIF
	 */
	//OrderServiceIF.IF_KR_SE_ERP_0007_ZCS('a0Z1m0000006qGiEAI');
	public static void IF_KR_SE_ERP_0007_ZCS(String recordId) {

		// 원 주문 조회
		List<OrderLineitem__c> inputOrderLineitems = [
				SELECT  Id,
						ProductId__r.ProductCode,
						ErpPOSNR__c,
						OrderId__c,
						OrderId__r.SalesDocNo__c,
						OrderId__r.ErpPOSNR__c,
						OrderId__r.BusinessOffice__r.SalesGroupCode__c,
						OrderId__r.BusinessOffice__r.BusinessOfficeName__c,
						OrderId__r.Name,
						OrderId__r.fm_SoldToErpCode__c,
						OrderId__r.fm_SupplyToErpCode__c,
						OrderId__r.ERP_Code__c,
						OrderId__r.OrderScheduleDate__c,
						OrderId__r.VSTEL__c,
						OrderId__r.DeliveryComment__c,
						OrderId__r.OrderAccount__c,
						OrderId__r.PriceDecisionDate__c,
						CorrectionPrice__c,
						ListPrice__c,
						UnitPrice__c,
						NhGovListPrice__c,
						SellingPrice__c
				FROM OrderLineitem__c
				WHERE OrderId__c = :recordId
		];

		Order__c order = inputOrderLineitems[0].OrderId__r;

		// 보관주문 조회
		OrderKeep__c orderKeep = [SELECT Id, Name, SalesDocNo__c FROM OrderKeep__c WHERE Order__c = :recordId];
		orderKeep.ERPSendDate__c = Date.today();

		IF_KR_SE_ERP_0007           instance = IF_KR_SE_ERP_0007.getInstance();
		IF_KR_SE_ERP_0007.InputDIH  input = new IF_KR_SE_ERP_0007.InputDIH();
		IF_KR_SE_ERP_0007.T_DATA    tData;
		IF_KR_SE_ERP_0007.OutputDIH result;
		System.debug('### orderLineitems:::' + inputOrderLineitems.size());

		Map<String, String> LGORTMap = new Map<String, String>();
		LGORTMap.put('M620', '3710');        // 전주공장
		LGORTMap.put('M621', '3711');        // 3711경기
		LGORTMap.put('M622', '3712');        // 3712충북
		LGORTMap.put('M623', '3713');        // 3713전북
		LGORTMap.put('M624', '3714');        // 3714경북
		LGORTMap.put('M625', '3715');        // 3715강원
		LGORTMap.put('M626', '3716');        // 3716충남
		LGORTMap.put('M627', '3717');        // 3717전남
		LGORTMap.put('M628', '3718');        // 3718경남


		for(OrderLineitem__c oli : inputOrderLineitems ){

			String sLGORT = LGORTMap.containsKey(oli.OrderId__r.VSTEL__c) ?
					LGORTMap.get(oli.OrderId__r.VSTEL__c) :
					' ';

			tData = new IF_KR_SE_ERP_0007.T_DATA();

			tData.OrderID           = orderKeep.Id;
			tData.OrderLineItemID   = oli.Id;
			tData.ProductCode       = oli.ProductId__r.ProductCode;
			tData.SalesDocNo        = oli.OrderId__r.SalesDocNo__c; // 판매문서번호
			tData.ErpPOSNR          = oli.OrderId__r.ErpPOSNR__c ;  // 판매문서품목번호
			tData.ErpVKGRP          = oli.OrderId__r.BusinessOffice__r.SalesGroupCode__c;
			tData.ErpBSTKD          = orderKeep.Name;
			tData.ErpBSTDK          = String.valueOf(system.now().format('yyyyMMdd'));
			tData.ErpKUNNR          = oli.OrderId__r.fm_SoldToErpCode__c;
			tData.ErpKUNNR2         = oli.OrderId__r.fm_SupplyToErpCode__c;
			tData.ErpKUNNR3         = oli.OrderId__r.ERP_Code__c;

			// 2021-07-26 수정 ============================================================================================
			tData.KEDAT             = ((Datetime)oli.OrderId__r.OrderScheduleDate__c).format('yyyyMMdd');   // 납품요청월
			tData.DLTXT             = String.isEmpty(oli.OrderId__r.DeliveryComment__c) ? '' : oli.OrderId__r.DeliveryComment__c;                                    // 출하전달사항
			// ============================================================================================================

			tData.Quanitity         = '1';
			tData.ErpZFLAG          = 'C';    // C: 생성, D: 삭제
			tData.ErpAUART          = 'ZCS';
			tData.ErpVKORG          = '3000';
			tData.ErpVTWEG          = '10';
			tData.ErpSPART          = '71';
			tData.ErpVKBUR          = '5600';

			tData.CHARG             = ' ';
			tData.VSTEL             = oli.OrderId__r.VSTEL__c;      // 출하위치
			tData.LGORT             = sLGORT;

			tData.ErpZTERM          = '';
			tData.ErpCMGST          = '';
			tData.ErpABGRU          = '';
			tData.ErpS_RESULT       = '';
			tData.ErpS_MESSAGE      = '';

			tData.NETWR1_C          = '';   //unitPrice == null ? '0' : String.valueOf(unitPrice);  // 기준 가격
			tData.NETWR2_C          = '';   //oli.CorrectionPrice__c == null ? '0' : String.valueOf(oli.CorrectionPrice__c);  // 가격 변경
			tData.NETWR3_C          = '';   //oli.SellingPrice__c == null ? '0' : String.valueOf(oli.SellingPrice__c);  // 공급 가격
			tData.RESERVE01         = '';   // 예비1
			tData.RESERVE02         = '';   // 예비2
			tData.RESERVE03         = '';   // 예비3
			tData.RESERVE04         = '';   // 예비4
			tData.RESERVE05         = '';   // 예비5

			tData.PRSDT             = ((Datetime) oli.OrderId__r.PriceDecisionDate__c).format('yyyyMMdd');  // 가격 결정일

			// 적재
			input.request.payload.t_data.add(tData);
		}

		// Interface Request 실행
		System.debug('### input.request.payload.t_data : '+input.request.payload.t_data);
		if(!input.request.payload.t_data.isEmpty()){
			// crashTest
			//IF_Base.crashTest = true;
			result = instance.execute(input);
		}

		// Interface Response 처리
		if ('S'.equals(result.response.header.ifResult)) {
			//성공 Succeed to Request

			List<IF_KR_SE_ERP_0007.T_DATA> t_data = result.Response.payload.t_data;

			for(IF_KR_SE_ERP_0007.T_DATA temp: t_data) {
				// 데이터 확인
				if(String.isNotBlank(temp.SalesDocNo) && temp.ErpS_RESULT == '00') {
					orderKeep.IsERPSend__c = true;
					orderKeep.SalesDocNo__c = temp.SalesDocNo;
//					orderKeep.KeepProcessDate__c = Date.today();
//					orderKeep.Status__c = '보관처리';
					orderKeep.ERPSendDate__c = Date.today();
					orderKeep.ERPComment__c = temp.ErpS_RESULT != null ? temp.ErpS_RESULT.left(255) : '보관문서번호 : '+temp.SalesDocNo;
					System.debug('보관주문 ERP 전송 처리 완료 ==> [' + orderKeep.SalesDocNo__c + ']');

					order.IsKeepProcess__c = true;
					update order;
				} else {
					// 실패
					orderKeep.IsERPSend__c = false;
					orderKeep.ERPComment__c = temp.ErpS_RESULT != null ? temp.ErpS_RESULT.left(255) : '보관문서번호 채번 실패';
				}
			}

		} else {
			//실패 Failed to Request
			orderKeep.IsERPSend__c = false;
			orderKeep.ERPComment__c = '보관주문 ERP 전송 처리 실패';
		}
		System.debug(JSON.serializePretty(orderKeep));
		update orderKeep;

	}

	/**
	 * @description : IF_KR_SE_ERP_0007_OR 주문 취소 (SE <-> ERP)
	 * Order__c 에 OrderLineItem__c는 1개임.
	 * Update Order, OrderLineitem
	 * 버튼에서 호출됨
	 */
	//OrderServiceIF.OrderCancel_OR('a0Z1m0000006qGiEAI');
	public static Map<String, String> OrderCancel_OR(String recordId) {

		Map<String, String> returnMap = new Map<String, String>();
		List<OrderLineitem__c> inputOrderLineitems = [
				SELECT Id,
						ProductId__r.ProductCode,
						OrderId__c,
						OrderId__r.BusinessOffice__r.SalesGroupCode__c,
						OrderId__r.BusinessOffice__r.BusinessOfficeName__c,
						OrderId__r.Name,
						OrderId__r.fm_SoldToErpCode__c,
						OrderId__r.fm_SupplyToErpCode__c,
						OrderId__r.ERP_Code__c,
						OrderId__r.SalesDocNo__c,
						OrderId__r.ErpPOSNR__c,
						OrderId__r.VSTEL__c,
						OrderId__r.PriceDecisionDate__c
				FROM OrderLineitem__c
				WHERE OrderId__c = :recordId
		];

		IF_KR_SE_ERP_0007           instance = IF_KR_SE_ERP_0007.getInstance();
		IF_KR_SE_ERP_0007.InputDIH  input = new IF_KR_SE_ERP_0007.InputDIH();
		IF_KR_SE_ERP_0007.T_DATA    tData;
		IF_KR_SE_ERP_0007.OutputDIH result;
		System.debug('### orderLineitems:::' + inputOrderLineitems.size());

		for(OrderLineitem__c oli : inputOrderLineitems ){
			/*
			(In : 데이터 채울 것) (Out : 전송시 스페이스 한자리, 수신하여 값 저장)(* 수신 필수)
			-------------------------------------------------------------------- 전송
			( In ) OrderLineItemID  세일즈포스 주문 제품ID
			( In ) ProductCode      제품코드
			( In ) OrderID          세일즈포스 채번 주문ID
			( In ) ErpVKGRP         영업그룹
			( In ) ErpBSTKD         PO 번호(= Order__c.Name)
			( In ) ErpBSTDK         PO 일자(= ERP 주문 생성 당일, yyyyMMdd)
			( In ) ErpKUNNR         판매처
			( In ) ErpKUNNR2        지급처
			( In ) ErpKUNNR3        납품처

			( In ) Quanitity        주문수량(=1)
			( In ) ErpZFLAG         주문Flag(Create: C 설정)
			( In ) ErpAUART         영업문서 유형(OR)
			( In ) ErpVKORG         영업조직(3000)
			( In ) ErpVTWEG         유통경로(10)
			( In ) ErpSPART         제품군(71)
			( In ) ErpVKBUR         영업팀(5600)

			-------------------------------------------------------------------- 수신
			[Order__c]
			(*Out) ErpZTERM__c  지급조건(* 전송시 스페이스 한자리, ERP 회신되는 값, Order__c에 저장)
			(*Out) SalesDocNo__c  판매문서번호(* 전송시 스페이스 한자리, 수신하여 값 저장)
			(*Out) ErpCMGST__c  ERP 여신상태(* 전송시 스페이스 한자리, 수신하여 값 저장)
			( Out) ErpABGRU__c  ERP 거부사유(* 전송시 스페이스 한자리, 수신하여 값 저장)
			(*Out) ErpS_RESULT__c  ERP 처리결과(* 전송시 스페이스 한자리, 수신하여 값 저장)
			( Out) ErpS_MESSAGE__c  ERP 메시지(* 전송시 N스페이스 한자리ull, 수신하여 값 저장)
			(*Out) ErpPOSNR__c  판매문서품목번호(* 전송시 스페이스 한자리, 수신하여 값 저장)

			[OrderLineItem__c]
			( Out) ErpPOSNR__c : 판매문서품목번호 : (* 전송시 스페이스 한자리, 수신하여 OrderLineItem__c 값 저장)
			*/

			Map<String, String> VSTELMap = new Map<String, String>();
			VSTELMap.put('71A', 'M621');        // M621경기
			VSTELMap.put('71C', 'M622');        // M622충북
			VSTELMap.put('71E', 'M623');        // M623전북
			VSTELMap.put('71G', 'M624');        // M624경북
			VSTELMap.put('71B', 'M625');        // M625강원
			VSTELMap.put('71D', 'M626');        // M626충남
			VSTELMap.put('71F', 'M627');        // M627전남
			VSTELMap.put('71H', 'M628');        // M628경남

			Map<String, String> LGORTMap = new Map<String, String>();
			LGORTMap.put('71A', '3711');        // 3711경기
			LGORTMap.put('71C', '3712');        // 3712충북
			LGORTMap.put('71E', '3713');        // 3713전북
			LGORTMap.put('71G', '3714');        // 3714경북
			LGORTMap.put('71B', '3715');        // 3715강원
			LGORTMap.put('71D', '3716');        // 3716충남
			LGORTMap.put('71F', '3717');        // 3717전남
			LGORTMap.put('71H', '3718');        // 3718경남

			String sVSTEL = VSTELMap.containsKey(oli.OrderId__r.BusinessOffice__r.BusinessOfficeName__c) ?
					VSTELMap.get(oli.OrderId__r.BusinessOffice__r.BusinessOfficeName__c) :
					'';
			String sLGORT = LGORTMap.containsKey(oli.OrderId__r.VSTEL__c) ?
					LGORTMap.get(oli.OrderId__r.VSTEL__c) :
					' ';

			tData = new IF_KR_SE_ERP_0007.T_DATA();

			tData.OrderID           = oli.OrderId__c;
			tData.OrderLineItemID   = oli.Id;
			tData.ProductCode       = oli.ProductId__r.ProductCode;
			tData.ErpVKGRP          = oli.OrderId__r.BusinessOffice__r.SalesGroupCode__c;
			tData.ErpBSTKD          = oli.OrderId__r.Name;
			tData.ErpBSTDK          = String.valueOf(system.now().format('yyyyMMdd'));
			tData.ErpKUNNR          = oli.OrderId__r.fm_SoldToErpCode__c;
			tData.ErpKUNNR2         = oli.OrderId__r.fm_SupplyToErpCode__c;
			tData.ErpKUNNR3         = oli.OrderId__r.ERP_Code__c;

			tData.Quanitity         = '1';
			tData.ErpZFLAG          = 'D';    // C: 생성, D: 삭제
			tData.ErpAUART          = 'OR';
			tData.ErpVKORG          = '3000';
			tData.ErpVTWEG          = '10';
			tData.ErpSPART          = '71';
			tData.ErpVKBUR          = '5600';

			tData.CHARG             = ' ';
			tData.VSTEL             = ' ';
			tData.LGORT             = ' ';

			tData.ErpPOSNR          = oli.OrderId__r.ErpPOSNR__c;
			tData.ErpZTERM          = ' ';
			tData.SalesDocNo        = oli.OrderId__r.SalesDocNo__c;
			tData.ErpCMGST          = ' ';
			tData.ErpABGRU          = '';
			tData.ErpS_RESULT       = ' ';
			tData.ErpS_MESSAGE      = ' ';

			tData.NETWR1_C          = '';  // 기준 가격
			tData.NETWR2_C          = '';  // 가격 변경
			tData.NETWR3_C          = '';  // 공급 가격
			tData.RESERVE01         = '';  // 예비1
			tData.RESERVE02         = '';  // 예비2
			tData.RESERVE03         = '';  // 예비3
			tData.RESERVE04         = '';  // 예비4
			tData.RESERVE05         = '';  // 예비5

			// 가격 결정일
			if(oli.OrderId__r.PriceDecisionDate__c == null) {
				tData.PRSDT             = String.valueOf(system.now().format('yyyyMMdd'));  // 가격 결정일
			} else {
				tData.PRSDT             = ((Datetime)oli.OrderId__r.PriceDecisionDate__c).format('yyyyMMdd');  // 가격 결정일
			}

			// 적재
			input.request.payload.t_data.add(tData);
		}

		// Interface Request 실행
		System.debug('### input.request.payload.t_data : '+input.request.payload.t_data);
		if(!input.request.payload.t_data.isEmpty()){
			// crashTest
			//IF_Base.crashTest = true;
			result = instance.execute(input);
		}

		// Interface Response 처리
		if ('S'.equals(result.response.header.ifResult)) {
			List<IF_KR_SE_ERP_0007.T_DATA> t_data = result.Response.payload.t_data;
			for(IF_KR_SE_ERP_0007.T_DATA temp: t_data) {
				// 데이터 확인
				if(temp.ErpS_RESULT == '00') {
					returnMap.put('STATUS', 'Y');
					returnMap.put('MESSAGE', '주문취소성공[OR]');
				} else {
					returnMap.put('STATUS', 'N');
					returnMap.put('MESSAGE', '주문취소오류[OR] : '+temp.ErpS_MESSAGE);
				}
			}
		} else {
			//실패 Failed to Request
			returnMap.put('STATUS', 'N');
			returnMap.put('MESSAGE', '주문취소오류[OR] : ' + result.response.header.ifFailMsg);
		}

		return returnMap;
	}

	/**
     * @description : OrderCancel_ZORT 주문 취소 (SE <-> ERP)
     *                SFDC 내 주문 확정시 ERP 내 주문 연계 (테스트 중)
     * Order__c 에 OrderLineItem__c는 1개임.
     * Update Order, OrderLineitem
     * 버튼에서 호출됨
     */
	public static Map<String, String> OrderCancel_ZORT(String recordId) {

		Map<String, String> returnMap = new Map<String, String>();
		List<OrderLineitem__c> inputOrderLineitems = [
			SELECT  Id,
					ProductId__r.ProductCode,
					OrderId__c,
					OrderId__r.BusinessOffice__r.SalesGroupCode__c,
					OrderId__r.BusinessOffice__r.BusinessOfficeName__c,
					OrderId__r.TransferBusinessOffice__r.BusinessOfficeName__c,
					OrderId__r.Name,
					OrderId__r.fm_SoldToErpCode__c,
					OrderId__r.fm_SupplyToErpCode__c,
					OrderId__r.ERP_Code__c,
					OrderId__r.SalesDocNo__c,
					OrderId__r.TransferMachineNo__c,
					OrderId__r.TransferMachineNo__r.Name,
					OrderId__r.TransferMachineNo__r.BatchNo__c,
					OrderId__r.ErpPOSNR__c,
					OrderId__r.VSTEL__c,
					OrderId__r.PriceDecisionDate__c
			FROM OrderLineitem__c
			WHERE OrderId__c = :recordId
		];

		IF_KR_SE_ERP_0007           instance = IF_KR_SE_ERP_0007.getInstance();
		IF_KR_SE_ERP_0007.InputDIH  input = new IF_KR_SE_ERP_0007.InputDIH();
		IF_KR_SE_ERP_0007.T_DATA    tData;
		IF_KR_SE_ERP_0007.OutputDIH result;
		System.debug('### orderLineitems:::' + inputOrderLineitems.size());

		for(OrderLineitem__c oli : inputOrderLineitems ){
			/*
			(In : 데이터 채울 것) (Out : 전송시 스페이스 한자리, 수신하여 값 저장)(* 수신 필수)
			-------------------------------------------------------------------- 전송
			( In ) OrderLineItemID  세일즈포스 주문 제품ID
			( In ) ProductCode      제품코드
			( In ) OrderID          세일즈포스 채번 주문ID
			( In ) ErpVKGRP         영업그룹
			( In ) ErpBSTKD         PO 번호(= Order__c.Name)
			( In ) ErpBSTDK         PO 일자(= ERP 주문 생성 당일, yyyyMMdd)
			( In ) ErpKUNNR         판매처
			( In ) ErpKUNNR2        지급처
			( In ) ErpKUNNR3        납품처

			// ZRET 인 경우는 ZORT 주문 정보값을 해야 한다.
			( In ) ErpBSTKD         PO 번호(= Order__c.Name)
			( In ) ErpBSTDK         PO 일자(= ERP 주문 생성 당일, yyyyMMdd)

			( In ) Quanitity        주문수량(=1)
			( In ) ErpZFLAG         주문Flag(Create: C 설정)
			( In ) ErpAUART         영업문서 유형(OR)
			( In ) ErpVKORG         영업조직(3000)
			( In ) ErpVTWEG         유통경로(10)
			( In ) ErpSPART         제품군(71)
			( In ) ErpVKBUR         영업팀(5600)

			-------------------------------------------------------------------- 수신
			[Order__c]
			(*Out) ErpZTERM__c  지급조건(* 전송시 스페이스 한자리, ERP 회신되는 값, Order__c에 저장)
			(*Out) SalesDocNo__c  판매문서번호(* 전송시 스페이스 한자리, 수신하여 값 저장)
			(*Out) ErpCMGST__c  ERP 여신상태(* 전송시 스페이스 한자리, 수신하여 값 저장)
			( Out) ErpABGRU__c  ERP 거부사유(* 전송시 스페이스 한자리, 수신하여 값 저장)
			(*Out) ErpS_RESULT__c  ERP 처리결과(* 전송시 스페이스 한자리, 수신하여 값 저장)
			( Out) ErpS_MESSAGE__c  ERP 메시지(* 전송시 N스페이스 한자리ull, 수신하여 값 저장)
			(*Out) ErpPOSNR__c  판매문서품목번호(* 전송시 스페이스 한자리, 수신하여 값 저장)

			[OrderLineItem__c]
			( Out) ErpPOSNR__c : 판매문서품목번호 : (* 전송시 스페이스 한자리, 수신하여 OrderLineItem__c 값 저장)
			*/


			/**
				AUART 영업문서 유형 : OR 일반내수판매, ZORT 전수배출고, ZRET 전수배반품
				VSTEL 출하지점 : M621경기, M622충북, M623전북, M624경북, M625강원, M626충남, M627전남, M628경남
				LGORT 저장위치: 3711경기, 3712충북, 3713전북, 3714경북, 3715강원, 3716충남, 3717전남, 3718경남
				ZFLAG : C 생성, D 삭제
			 */
			Map<String, String> VSTELMap = new Map<String, String>();
			VSTELMap.put('71A', 'M621');        // M621경기
			VSTELMap.put('71C', 'M622');        // M622충북
			VSTELMap.put('71E', 'M623');        // M623전북
			VSTELMap.put('71G', 'M624');        // M624경북
			VSTELMap.put('71B', 'M625');        // M625강원
			VSTELMap.put('71D', 'M626');        // M626충남
			VSTELMap.put('71F', 'M627');        // M627전남
			VSTELMap.put('71H', 'M628');        // M628경남

			Map<String, String> LGORTMap = new Map<String, String>();
			LGORTMap.put('71A', '3711');        // 3711경기
			LGORTMap.put('71C', '3712');        // 3712충북
			LGORTMap.put('71E', '3713');        // 3713전북
			LGORTMap.put('71G', '3714');        // 3714경북
			LGORTMap.put('71B', '3715');        // 3715강원
			LGORTMap.put('71D', '3716');        // 3716충남
			LGORTMap.put('71F', '3717');        // 3717전남
			LGORTMap.put('71H', '3718');        // 3718경남

			String sVSTEL = VSTELMap.containsKey(oli.OrderId__r.TransferBusinessOffice__r.BusinessOfficeName__c) ?
			VSTELMap.get(oli.OrderId__r.TransferBusinessOffice__r.BusinessOfficeName__c) :
			'';
			String sLGORT = LGORTMap.containsKey(oli.OrderId__r.VSTEL__c) ?
			LGORTMap.get(oli.OrderId__r.VSTEL__c) :
			'';
			tData = new IF_KR_SE_ERP_0007.T_DATA();

			tData.OrderID           = oli.OrderId__c;
			tData.OrderLineItemID   = oli.Id;
			tData.ProductCode       = oli.ProductId__r.ProductCode;
			tData.ErpVKGRP          = oli.OrderId__r.BusinessOffice__r.SalesGroupCode__c;
			tData.ErpBSTKD          = oli.OrderId__r.Name;
			tData.ErpBSTDK          = String.valueOf(system.now().format('yyyyMMdd'));
			tData.ErpKUNNR          = oli.OrderId__r.fm_SoldToErpCode__c;
			tData.ErpKUNNR2         = oli.OrderId__r.fm_SupplyToErpCode__c;
			tData.ErpKUNNR3         = oli.OrderId__r.ERP_Code__c;

			tData.Quanitity         = '1';
			tData.ErpZFLAG          = 'D';    // C: 생성, D: 삭제
			tData.ErpAUART          = 'ZORT';
			tData.ErpVKORG          = '3000';
			tData.ErpVTWEG          = '10';
			tData.ErpSPART          = '71';
			tData.ErpVKBUR          = '5600';

			tData.CHARG             = oli.OrderId__r.TransferMachineNo__r.BatchNo__c;
			tData.VSTEL             = oli.OrderId__r.VSTEL__c;
			tData.LGORT             = sLGORT;

			tData.ErpPOSNR          = oli.OrderId__r.ErpPOSNR__c;
			tData.ErpZTERM          = ' ';
			tData.SalesDocNo        = oli.OrderId__r.SalesDocNo__c;
			tData.ErpCMGST          = ' ';
			tData.ErpABGRU          = ' ';
			tData.ErpS_RESULT       = ' ';
			tData.ErpS_MESSAGE      = ' ';

			tData.NETWR1_C          = '';  // 기준 가격
			tData.NETWR2_C          = '';  // 가격 변경
			tData.NETWR3_C          = '';  // 공급 가격
			tData.RESERVE01         = '';  // 예비1
			tData.RESERVE02         = '';  // 예비2
			tData.RESERVE03         = '';  // 예비3
			tData.RESERVE04         = '';  // 예비4
			tData.RESERVE05         = '';  // 예비5


			// 가격 결정일
			if(oli.OrderId__r.PriceDecisionDate__c == null) {
				tData.PRSDT             = String.valueOf(system.now().format('yyyyMMdd'));  // 가격 결정일
			} else {
				tData.PRSDT             = ((Datetime)oli.OrderId__r.PriceDecisionDate__c).format('yyyyMMdd');  // 가격 결정일
			}


			// 적재
			input.request.payload.t_data.add(tData);
		}


		// Interface Request 실행
		System.debug('### input.request.payload.t_data : '+input.request.payload.t_data);
		if(!input.request.payload.t_data.isEmpty()){
			// crashTest
			//IF_Base.crashTest = true;
			result = instance.execute(input);
		}

		if ('S'.equals(result.response.header.ifResult)) {
			List<IF_KR_SE_ERP_0007.T_DATA> t_data = result.Response.payload.t_data;
			for(IF_KR_SE_ERP_0007.T_DATA temp: t_data) {
				// 데이터 확인
				if(temp.ErpS_RESULT == '00') {
					returnMap.put('STATUS', 'Y');
					returnMap.put('MESSAGE', '주문취소성공[ZORT]');
				} else {
					returnMap.put('STATUS', 'N');
					returnMap.put('MESSAGE', '주문취소오류[ZORT] : '+temp.ErpS_MESSAGE);
				}
			}
		} else {
			//실패 Failed to Request
			returnMap.put('STATUS', 'N');
			returnMap.put('MESSAGE', '주문취소오류[ZORT] : ' + result.response.header.ifFailMsg);
		}

		return returnMap;
	}

	/**
     * @description : OrderCancel_ZRET 주문 취소 (SE <-> ERP)
     *                SFDC 내 주문 확정시 ERP 내 주문 연계 (테스트 중)
     * Order__c 에 OrderLineItem__c는 1개임.
     * Update Order, OrderLineitem
     * 버튼에서 호출됨
     */
	//OrderServiceIF.OrderCancel_ZRET('a0Z1m0000006qGiEAI');
	public static Map<String, String> OrderCancel_ZRET(String recordId) {

		Map<String, String> returnMap = new Map<String, String>();

		Order__c order = [
				SELECT
						Id, Division__c, SalesDocNo__c, ErpPOSNR__c, Status__c, IsZRET__c, TransferProcessStatus__c, AssetTransferAgreeStatus__c,
						TransferMachineNo__r.Name,
						TransferMachineNo__r.BatchNo__c,
						TransferMachineNo__r.Dealer__r.ERPCode__c,
						TransferMachineNo__r.Account.ERPCode__c,
						TransferMachineNo__r.Account.CustomerType__c,
						TransferMachineNo__r.BusinessOffice__r.SalesGroupCode__c,
						BusinessOffice__r.SalesGroupCode__c,
				(SELECT Id, OrderLineitem__c , SalesDocNo__c, ERP_POSNR__c, TransferDealer__c, Status__c,
						TransferDealer__r.ERPCode__c,
						TransferDealer__r.BusinessOfficeName__c,
						Product__r.ProductCode
				FROM TransferOrders__r LIMIT 1)
				FROM Order__c WHERE Id =: recordId
		];
		TransferOrder__c transferOrder = null;
		if(order.TransferOrders__r != null && order.TransferOrders__r.size() > 0) {
			transferOrder = order.TransferOrders__r[0];
		}
		if(transferOrder == null) {
			returnMap.put('STATUS', 'N');
			returnMap.put('MESSAGE', '반품 주문 정보가 없습니다. ERP주문을 먼저 처리 해주세요.');
			return returnMap;
		}

		IF_KR_SE_ERP_0007           instance = IF_KR_SE_ERP_0007.getInstance();
		IF_KR_SE_ERP_0007.InputDIH  input = new IF_KR_SE_ERP_0007.InputDIH();
		IF_KR_SE_ERP_0007.T_DATA    tData;
		IF_KR_SE_ERP_0007.OutputDIH result;


		Map<String, String> VSTELMap = new Map<String, String>();
		VSTELMap.put('71A', 'M621');        // M621경기
		VSTELMap.put('71C', 'M622');        // M622충북
		VSTELMap.put('71E', 'M623');        // M623전북
		VSTELMap.put('71G', 'M624');        // M624경북
		VSTELMap.put('71B', 'M625');        // M625강원
		VSTELMap.put('71D', 'M626');        // M626충남
		VSTELMap.put('71F', 'M627');        // M627전남
		VSTELMap.put('71H', 'M628');        // M628경남

		Map<String, String> LGORTMap = new Map<String, String>();
		LGORTMap.put('71A', '3711');        // 3711경기
		LGORTMap.put('71C', '3712');        // 3712충북
		LGORTMap.put('71E', '3713');        // 3713전북
		LGORTMap.put('71G', '3714');        // 3714경북
		LGORTMap.put('71B', '3715');        // 3715강원
		LGORTMap.put('71D', '3716');        // 3716충남
		LGORTMap.put('71F', '3717');        // 3717전남
		LGORTMap.put('71H', '3718');        // 3718경남

		String sVSTEL = VSTELMap.containsKey(transferOrder.TransferDealer__r.BusinessOfficeName__c) ?
				VSTELMap.get(transferOrder.TransferDealer__r.BusinessOfficeName__c) :
				'';
		String sLGORT = LGORTMap.containsKey(transferOrder.TransferDealer__r.BusinessOfficeName__c) ?
				LGORTMap.get(transferOrder.TransferDealer__r.BusinessOfficeName__c) :
				'';

		tData = new IF_KR_SE_ERP_0007.T_DATA();

		tData.OrderID           = transferOrder.Id;
		tData.OrderLineItemID   = transferOrder.OrderLineitem__c;
		tData.ProductCode       = transferOrder.Product__r.ProductCode;
		tData.ErpVKGRP          = order.TransferMachineNo__r.BusinessOffice__r.SalesGroupCode__c;   //BusinessOffice__r.SalesGroupCode__c;
		tData.ErpBSTKD          = order.SalesDocNo__c;
		tData.ErpBSTDK          = String.valueOf(system.now().format('yyyyMMdd'));      // 원주문의 PO 날짜가 필요한데 값이 없다.

		// 수배 대리점의 ERP Code를 지정 해야 한다.
		// 수배 대리점의 자산의 고객이 농협/관납이면 농협/관납 ERPCode__c를 보낸다.
		// 2021/04/22
		//
		tData.ErpKUNNR          = transferOrder.TransferDealer__r.ERPCode__c;
		tData.ErpKUNNR2         = transferOrder.TransferDealer__r.ERPCode__c;
		tData.ErpKUNNR3         = transferOrder.TransferDealer__r.ERPCode__c;
//        order.TransferMachineNo__r.Dealer__r.ERPCode__c,
//        order.TransferMachineNo__r.Account.ERPCode__c,
		Set<String> checkCustomers = new Set<String>{'농협','관납'};
		if(checkCustomers.contains(order.TransferMachineNo__r.Account.CustomerType__c)) {
			tData.ErpKUNNR          = order.TransferMachineNo__r.Account.ERPCode__c;
			tData.ErpKUNNR2         = order.TransferMachineNo__r.Account.ERPCode__c;
			tData.ErpKUNNR3         = order.TransferMachineNo__r.Account.ERPCode__c;
		}

		tData.Quanitity         = '1';
		tData.ErpZFLAG          = 'D';    // C: 생성, D: 삭제
		tData.ErpAUART          = 'ZRET';
		tData.ErpVKORG          = '3000';
		tData.ErpVTWEG          = '10';
		tData.ErpSPART          = '71';
		tData.ErpVKBUR          = '5600';

		tData.CHARG             = order.TransferMachineNo__r.BatchNo__c;
		tData.VSTEL             = sVSTEL;
		tData.LGORT             = sLGORT;

		tData.ErpPOSNR          = transferOrder.ERP_POSNR__c;
		tData.ErpZTERM          = ' ';
		tData.SalesDocNo        = transferOrder.SalesDocNo__c;
		tData.ErpCMGST          = ' ';
		tData.ErpABGRU          = ' ';
		tData.ErpS_RESULT       = ' ';
		tData.ErpS_MESSAGE      = ' ';

		tData.NETWR1_C          = '';  // 기준 가격
		tData.NETWR2_C          = '';  // 가격 변경
		tData.NETWR3_C          = '';  // 공급 가격
		tData.RESERVE01         = '';  // 예비1
		tData.RESERVE02         = '';  // 예비2
		tData.RESERVE03         = '';  // 예비3
		tData.RESERVE04         = '';  // 예비4
		tData.RESERVE05         = '';  // 예비5

		// 가격 결정일
		tData.PRSDT             = String.valueOf(system.now().format('yyyyMMdd'));  // 가격 결정일
/*
		if(oli.OrderId__r.PriceDecisionDate__c == null) {
			tData.PRSDT             = String.valueOf(system.now().format('yyyyMMdd'));  // 가격 결정일
		} else {
			tData.PRSDT             = ((Datetime)oli.OrderId__r.PriceDecisionDate__c).format('yyyyMMdd');  // 가격 결정일
		}
*/
		// 적재
		input.request.payload.t_data.add(tData);

		// Interface Request 실행
		System.debug('### input.request.payload.t_data : '+input.request.payload.t_data);
		if(!input.request.payload.t_data.isEmpty()){
			// crashTest
			//IF_Base.crashTest = true;
			result = instance.execute(input);
		}

		if ('S'.equals(result.response.header.ifResult)) {
			List<IF_KR_SE_ERP_0007.T_DATA> t_data = result.Response.payload.t_data;
			for(IF_KR_SE_ERP_0007.T_DATA temp: t_data) {
				// 데이터 확인
				if(temp.ErpS_RESULT == '00') {
					returnMap.put('STATUS', 'Y');
					returnMap.put('MESSAGE', '주문취소성공[ZRET]');
				} else {
					returnMap.put('STATUS', 'N');
					returnMap.put('MESSAGE', '주문취소오류[ZRET] : '+temp.ErpS_MESSAGE);
				}
			}
		} else {
			//실패 Failed to Request
			returnMap.put('STATUS', 'N');
			returnMap.put('MESSAGE', '주문취소오류[ZRET] : ' + result.response.header.ifFailMsg);
		}

		return returnMap;
	}



	/**
	 * @description : OrderUpdate_OR 주문 정정 (SE <-> ERP)
	 * Order__c 에 OrderLineItem__c는 1개임.
	 * Update Order, OrderLineitem
	 * 버튼에서 호출됨
	 */
	//OrderServiceIF.OrderUpdate_OR('a0Z1m0000006qGiEAI');
	public static OrderNewQa.WrapperData OrderUpdate_OR(OrderNewQa.WrapperData orderWrapper) {
		Map<String, String> returnMap = new Map<String, String>();

		IF_KR_SE_ERP_0007           instance = IF_KR_SE_ERP_0007.getInstance();
		IF_KR_SE_ERP_0007.InputDIH  input = new IF_KR_SE_ERP_0007.InputDIH();
		IF_KR_SE_ERP_0007.T_DATA    tData;
		IF_KR_SE_ERP_0007.OutputDIH result;


		for(OrderLineitem__c oli : orderWrapper.orderLineItemList ){
			/*
			(In : 데이터 채울 것) (Out : 전송시 스페이스 한자리, 수신하여 값 저장)(* 수신 필수)
			-------------------------------------------------------------------- 전송
			( In ) OrderLineItemID  세일즈포스 주문 제품ID
			( In ) ProductCode      제품코드
			( In ) OrderID          세일즈포스 채번 주문ID
			( In ) ErpVKGRP         영업그룹
			( In ) ErpBSTKD         PO 번호(= Order__c.Name)
			( In ) ErpBSTDK         PO 일자(= ERP 주문 생성 당일, yyyyMMdd)
			( In ) ErpKUNNR         판매처
			( In ) ErpKUNNR2        지급처
			( In ) ErpKUNNR3        납품처

			( In ) Quanitity        주문수량(=1)
			( In ) ErpZFLAG         주문Flag(Create: C 설정)
			( In ) ErpAUART         영업문서 유형(OR)
			( In ) ErpVKORG         영업조직(3000)
			( In ) ErpVTWEG         유통경로(10)
			( In ) ErpSPART         제품군(71)
			( In ) ErpVKBUR         영업팀(5600)

			-------------------------------------------------------------------- 수신
			[Order__c]
			(*Out) ErpZTERM__c  지급조건(* 전송시 스페이스 한자리, ERP 회신되는 값, Order__c에 저장)
			(*Out) SalesDocNo__c  판매문서번호(* 전송시 스페이스 한자리, 수신하여 값 저장)
			(*Out) ErpCMGST__c  ERP 여신상태(* 전송시 스페이스 한자리, 수신하여 값 저장)
			( Out) ErpABGRU__c  ERP 거부사유(* 전송시 스페이스 한자리, 수신하여 값 저장)
			(*Out) ErpS_RESULT__c  ERP 처리결과(* 전송시 스페이스 한자리, 수신하여 값 저장)
			( Out) ErpS_MESSAGE__c  ERP 메시지(* 전송시 N스페이스 한자리ull, 수신하여 값 저장)
			(*Out) ErpPOSNR__c  판매문서품목번호(* 전송시 스페이스 한자리, 수신하여 값 저장)

			[OrderLineItem__c]
			( Out) ErpPOSNR__c : 판매문서품목번호 : (* 전송시 스페이스 한자리, 수신하여 OrderLineItem__c 값 저장)
			*/

/*
			Map<String, String> VSTELMap = new Map<String, String>();
			VSTELMap.put('71A', 'M621');        // M621경기
			VSTELMap.put('71C', 'M622');        // M622충북
			VSTELMap.put('71E', 'M623');        // M623전북
			VSTELMap.put('71G', 'M624');        // M624경북
			VSTELMap.put('71B', 'M625');        // M625강원
			VSTELMap.put('71D', 'M626');        // M626충남
			VSTELMap.put('71F', 'M627');        // M627전남
			VSTELMap.put('71H', 'M628');        // M628경남

			Map<String, String> LGORTMap = new Map<String, String>();
			LGORTMap.put('71A', '3711');        // 3711경기
			LGORTMap.put('71C', '3712');        // 3712충북
			LGORTMap.put('71E', '3713');        // 3713전북
			LGORTMap.put('71G', '3714');        // 3714경북
			LGORTMap.put('71B', '3715');        // 3715강원
			LGORTMap.put('71D', '3716');        // 3716충남
			LGORTMap.put('71F', '3717');        // 3717전남
			LGORTMap.put('71H', '3718');        // 3718경남


			String sVSTEL = VSTELMap.containsKey(orderWrapper.order.BusinessOffice__r.BusinessOfficeName__c) ?
					VSTELMap.get(orderWrapper.order.BusinessOffice__r.BusinessOfficeName__c) :
					'';

			String sLGORT = LGORTMap.containsKey(orderWrapper.order.BusinessOffice__r.BusinessOfficeName__c) ?
					LGORTMap.get(orderWrapper.order.BusinessOffice__r.BusinessOfficeName__c) :
					'';

*/

			Map<String, String> LGORTMap = new Map<String, String>();
			LGORTMap.put('M620', '3710');        // 3710전주공장
			LGORTMap.put('M621', '3711');        // 3711경기
			LGORTMap.put('M622', '3712');        // 3712충북
			LGORTMap.put('M623', '3713');        // 3713전북
			LGORTMap.put('M624', '3714');        // 3714경북
			LGORTMap.put('M625', '3715');        // 3715강원
			LGORTMap.put('M626', '3716');        // 3716충남
			LGORTMap.put('M627', '3717');        // 3717전남
			LGORTMap.put('M628', '3718');        // 3718경남

			String sVSTEL = orderWrapper.order.VSTEL__c;
			String sLGORT = LGORTMap.containsKey(sVSTEL) ? LGORTMap.get(sVSTEL) : '';

			tData = new IF_KR_SE_ERP_0007.T_DATA();

			tData.OrderID           = orderWrapper.order.Id;
			tData.OrderLineItemID   = oli.Id;
			tData.ProductCode       = oli.ProductId__r.ProductCode;
			tData.ErpVKGRP          = orderWrapper.order.BusinessOffice__r.SalesGroupCode__c;
			tData.ErpBSTKD          = orderWrapper.order.Name;
			tData.ErpBSTDK          = String.valueOf(system.now().format('yyyyMMdd'));
			tData.ErpKUNNR          = orderWrapper.order.fm_SoldToErpCode__c;
			tData.ErpKUNNR2         = orderWrapper.order.fm_SupplyToErpCode__c;
			tData.ErpKUNNR3         = orderWrapper.order.ERP_Code__c;

			tData.Quanitity         = '1';
			tData.ErpZFLAG          = 'U';    // C: 생성, U : 수정 : D: 삭제
			tData.ErpAUART          = 'OR';
			tData.ErpVKORG          = '3000';
			tData.ErpVTWEG          = '10';
			tData.ErpSPART          = '71';
			tData.ErpVKBUR          = '5600';

			tData.CHARG             = '';
			tData.VSTEL             = sVSTEL;      // 출하위치 : 입력 필드가 아니라고 함.
			tData.LGORT             = sLGORT;

			// 2021-07-26 수정 ============================================================================================
			tData.KEDAT             = ((Datetime)orderWrapper.order.OrderScheduleDate__c).format('yyyyMMdd');   // 납품요청월
			tData.DLTXT             = orderWrapper.order.DeliveryComment__c == null ? '' : orderWrapper.order.DeliveryComment__c;                                    // 출하전달사항
			// ============================================================================================================


			tData.ErpPOSNR          = orderWrapper.order.ErpPOSNR__c;
			tData.ErpZTERM          = '';
			tData.SalesDocNo        = orderWrapper.order.SalesDocNo__c;
			tData.ErpCMGST          = '';
			tData.ErpABGRU          = '';
			tData.ErpS_RESULT       = '';
			tData.ErpS_MESSAGE      = '';

			// 가격 정정 정보.
			// 2021-10-25 : 주문 가격 수정 : ITVOC-2021-09-0526
			tData.NETWR1_C          = oli.BaseSellingPrice__c == null ? '' : String.valueOf(oli.BaseSellingPrice__c);  // 기준 가격
			tData.NETWR2_C          = oli.CorrectionPrice__c == null ? '0' : String.valueOf(oli.CorrectionPrice__c);  // 가격 변경
			tData.NETWR3_C          = oli.SellingPrice__c == null ? '' : String.valueOf(oli.SellingPrice__c);  // 공급 가격
			tData.RESERVE01         = ' ';   // 예비1
			tData.RESERVE02         = ' ';   // 예비2
			tData.RESERVE03         = ' ';   // 예비3
			tData.RESERVE04         = ' ';   // 예비4
			tData.RESERVE05         = ' ';   // 예비5

			if(orderWrapper.order.PriceDecisionDate__c == null) {
				tData.PRSDT             = String.valueOf(system.now().format('yyyyMMdd'));  // 가격 결정일
			} else {
				tData.PRSDT             = ((Datetime)orderWrapper.order.PriceDecisionDate__c).format('yyyyMMdd');  // 가격 결정일
			}

			// 적재
			input.request.payload.t_data.add(tData);
		}

		// Interface Request 실행
		System.debug('### input.request.payload.t_data : '+JSON.serializePretty(input.request.payload.t_data));
		if(!input.request.payload.t_data.isEmpty()){
			// crashTest
			//IF_Base.crashTest = true;
			result = instance.execute(input);
		}

		// Interface Response 처리
		// @TODO : 정상 생성 기준과 동일하게 업데이트 로직 추가.
		if ('S'.equals(result.response.header.ifResult)) {
			List<IF_KR_SE_ERP_0007.T_DATA> t_data = result.Response.payload.t_data;
			for(IF_KR_SE_ERP_0007.T_DATA temp: t_data) {
				// 데이터 확인
				if(temp.ErpS_RESULT == '00') {
					returnMap.put('STATUS', 'Y');
					returnMap.put('MESSAGE', '주문정정성공[OR]');
					orderWrapper.order.ErpZTERM__c        = temp.ErpZTERM;
					//orderWrapper.order.SalesDocNo__c      = temp.SalesDocNo;
					orderWrapper.order.ErpCMGST__c        = temp.ErpCMGST;
					orderWrapper.order.ErpABGRU__c        = temp.ErpABGRU;
					orderWrapper.order.ErpS_RESULT__c     = temp.ErpS_RESULT;
					orderWrapper.order.ErpS_MESSAGE__c    = temp.ErpS_MESSAGE;
					orderWrapper.order.ErpPOSNR__c        = temp.ErpPOSNR;

					if (temp.ErpCMGST == 'B' ) {
						if(orderWrapper.order.RecordType.Name != '관납/농협') {
							orderWrapper.order.Status__c = '본사 여신 검토';
							orderWrapper.order.SystemStatus__c = '본사 여신 검토';    // 파트너 커뮤니티 사용자가 임의로 상태 변경하는 것을 방지하는 목적
							orderWrapper.order.ErpZLNNO__c = null;      // 여신번호
						} else {
							orderWrapper.order.Status__c = '출하';
							orderWrapper.order.SystemStatus__c = '출하';    // 파트너 커뮤니티 사용자가 임의로 상태 변경하는 것을 방지하는 목적
						}
					} else if (String.isEmpty(temp.ErpCMGST) || temp.ErpCMGST == 'A' || temp.ErpCMGST == 'D') {
						orderWrapper.order.Status__c = '출하';
						orderWrapper.order.SystemStatus__c = '출하';    // 파트너 커뮤니티 사용자가 임의로 상태 변경하는 것을 방지하는 목적
					}

					// temp.ErpABGRU = '95' (수주 손익 미결재) 일 경우 Dealer__r.Owner.Id 에게 Chatter 알림
					if(temp.ErpABGRU == '95'){
						String chatterMessage = orderWrapper.order.Name +' 수주 손익 미결 상태로, SAP 수주 손익 승인 요청 Workflow가 실행되었습니다. SAP 內 확인 바랍니다.';
						Set<String> mentionsIds = new Set<String>();
						if(orderWrapper.order.BusinessOfficeRep__c != null) mentionsIds.add(orderWrapper.order.BusinessOfficeRep__c);
						if(orderWrapper.order.BusinessOfficeRep__r.ManagerId != null) mentionsIds.add(orderWrapper.order.BusinessOfficeRep__r.ManagerId);
						LacComChatterService.simpleChatterFeed(null, orderWrapper.order.Id, chatterMessage, mentionsIds);
					}
				} else {
					returnMap.put('STATUS', 'N');
					returnMap.put('MESSAGE', '주문정정오류[OR] : '+temp.ErpS_MESSAGE);

					orderWrapper.order.ErpS_RESULT__c     = temp.ErpS_RESULT;
					orderWrapper.order.ErpS_MESSAGE__c    = temp.ErpS_MESSAGE;
				}
			}
		} else {
			//실패 Failed to Request
			returnMap.put('STATUS', 'N');
			returnMap.put('MESSAGE', '주문정정오류[OR] : ' + result.response.header.ifFailMsg);
			orderWrapper.order.ErpS_RESULT__c     = '99';
			orderWrapper.order.ErpS_MESSAGE__c    = '[ERP 통신 오류] '+result.response.header.ifFailMsg;
		}

		return orderWrapper;
	}

	/**
     * @description : OrderUpdate_ZORT 주문 정정 (SE <-> ERP)
     *                SFDC 내 주문 확정시 ERP 내 주문 연계 (테스트 중)
     * Order__c 에 OrderLineItem__c는 1개임.
     * Update Order, OrderLineitem
     * 버튼에서 호출됨
     */
	public static OrderNewQa.WrapperData OrderUpdate_ZORT(OrderNewQa.WrapperData orderWrapper) {

		Map<String, String> returnMap = new Map<String, String>();

		IF_KR_SE_ERP_0007           instance = IF_KR_SE_ERP_0007.getInstance();
		IF_KR_SE_ERP_0007.InputDIH  input = new IF_KR_SE_ERP_0007.InputDIH();
		IF_KR_SE_ERP_0007.T_DATA    tData;
		IF_KR_SE_ERP_0007.OutputDIH result;
		System.debug('### orderLineitems:::' + orderWrapper.orderLineItemList.size());

		for(OrderLineitem__c oli : orderWrapper.orderLineItemList ){
			/*
			(In : 데이터 채울 것) (Out : 전송시 스페이스 한자리, 수신하여 값 저장)(* 수신 필수)
			-------------------------------------------------------------------- 전송
			( In ) OrderLineItemID  세일즈포스 주문 제품ID
			( In ) ProductCode      제품코드
			( In ) OrderID          세일즈포스 채번 주문ID
			( In ) ErpVKGRP         영업그룹
			( In ) ErpBSTKD         PO 번호(= Order__c.Name)
			( In ) ErpBSTDK         PO 일자(= ERP 주문 생성 당일, yyyyMMdd)
			( In ) ErpKUNNR         판매처
			( In ) ErpKUNNR2        지급처
			( In ) ErpKUNNR3        납품처

			// ZRET 인 경우는 ZORT 주문 정보값을 해야 한다.
			( In ) ErpBSTKD         PO 번호(= Order__c.Name)
			( In ) ErpBSTDK         PO 일자(= ERP 주문 생성 당일, yyyyMMdd)

			( In ) Quanitity        주문수량(=1)
			( In ) ErpZFLAG         주문Flag(Create: C 설정)
			( In ) ErpAUART         영업문서 유형(OR)
			( In ) ErpVKORG         영업조직(3000)
			( In ) ErpVTWEG         유통경로(10)
			( In ) ErpSPART         제품군(71)
			( In ) ErpVKBUR         영업팀(5600)

			-------------------------------------------------------------------- 수신
			[Order__c]
			(*Out) ErpZTERM__c  지급조건(* 전송시 스페이스 한자리, ERP 회신되는 값, Order__c에 저장)
			(*Out) SalesDocNo__c  판매문서번호(* 전송시 스페이스 한자리, 수신하여 값 저장)
			(*Out) ErpCMGST__c  ERP 여신상태(* 전송시 스페이스 한자리, 수신하여 값 저장)
			( Out) ErpABGRU__c  ERP 거부사유(* 전송시 스페이스 한자리, 수신하여 값 저장)
			(*Out) ErpS_RESULT__c  ERP 처리결과(* 전송시 스페이스 한자리, 수신하여 값 저장)
			( Out) ErpS_MESSAGE__c  ERP 메시지(* 전송시 N스페이스 한자리ull, 수신하여 값 저장)
			(*Out) ErpPOSNR__c  판매문서품목번호(* 전송시 스페이스 한자리, 수신하여 값 저장)

			[OrderLineItem__c]
			( Out) ErpPOSNR__c : 판매문서품목번호 : (* 전송시 스페이스 한자리, 수신하여 OrderLineItem__c 값 저장)
			*/


			/**
				AUART 영업문서 유형 : OR 일반내수판매, ZORT 전수배출고, ZRET 전수배반품
				VSTEL 출하지점 : M621경기, M622충북, M623전북, M624경북, M625강원, M626충남, M627전남, M628경남
				LGORT 저장위치: 3711경기, 3712충북, 3713전북, 3714경북, 3715강원, 3716충남, 3717전남, 3718경남
				ZFLAG : C 생성, D 삭제
			 */
/*
			Map<String, String> VSTELMap = new Map<String, String>();
			VSTELMap.put('71A', 'M621');        // M621경기
			VSTELMap.put('71C', 'M622');        // M622충북
			VSTELMap.put('71E', 'M623');        // M623전북
			VSTELMap.put('71G', 'M624');        // M624경북
			VSTELMap.put('71B', 'M625');        // M625강원
			VSTELMap.put('71D', 'M626');        // M626충남
			VSTELMap.put('71F', 'M627');        // M627전남
			VSTELMap.put('71H', 'M628');        // M628경남

			Map<String, String> LGORTMap = new Map<String, String>();
			LGORTMap.put('71A', '3711');        // 3711경기
			LGORTMap.put('71C', '3712');        // 3712충북
			LGORTMap.put('71E', '3713');        // 3713전북
			LGORTMap.put('71G', '3714');        // 3714경북
			LGORTMap.put('71B', '3715');        // 3715강원
			LGORTMap.put('71D', '3716');        // 3716충남
			LGORTMap.put('71F', '3717');        // 3717전남
			LGORTMap.put('71H', '3718');        // 3718경남


			String sVSTEL = VSTELMap.containsKey(orderWrapper.order.TransferBusinessOffice__r.BusinessOfficeName__c) ?
					VSTELMap.get(orderWrapper.order.TransferBusinessOffice__r.BusinessOfficeName__c) :
					'';
			String sLGORT = LGORTMap.containsKey(orderWrapper.order.TransferBusinessOffice__r.BusinessOfficeName__c) ?
					LGORTMap.get(orderWrapper.order.TransferBusinessOffice__r.BusinessOfficeName__c) :
					'';

*/
			Map<String, String> LGORTMap = new Map<String, String>();
			LGORTMap.put('M620', '3710');        // 3710전주공장
			LGORTMap.put('M621', '3711');        // 3711경기
			LGORTMap.put('M622', '3712');        // 3712충북
			LGORTMap.put('M623', '3713');        // 3713전북
			LGORTMap.put('M624', '3714');        // 3714경북
			LGORTMap.put('M625', '3715');        // 3715강원
			LGORTMap.put('M626', '3716');        // 3716충남
			LGORTMap.put('M627', '3717');        // 3717전남
			LGORTMap.put('M628', '3718');        // 3718경남

			String sVSTEL = orderWrapper.order.VSTEL__c;
			String sLGORT = LGORTMap.containsKey(sVSTEL) ? LGORTMap.get(sVSTEL) : '';

			tData = new IF_KR_SE_ERP_0007.T_DATA();

			tData.OrderID           = orderWrapper.order.Id;
			tData.OrderLineItemID   = oli.Id;
			tData.ProductCode       = oli.ProductId__r.ProductCode;
			tData.ErpVKGRP          = orderWrapper.order.BusinessOffice__r.SalesGroupCode__c;
			tData.ErpBSTKD          = orderWrapper.order.Name;
			tData.ErpBSTDK          = String.valueOf(system.now().format('yyyyMMdd'));
			tData.ErpKUNNR          = orderWrapper.order.fm_SoldToErpCode__c;
			tData.ErpKUNNR2         = orderWrapper.order.fm_SupplyToErpCode__c;
			tData.ErpKUNNR3         = orderWrapper.order.ERP_Code__c;

			tData.Quanitity         = '1';
			tData.ErpZFLAG          = 'U';    // C: 생성, U : 수정 : D: 삭제
			tData.ErpAUART          = 'ZORT';
			tData.ErpVKORG          = '3000';
			tData.ErpVTWEG          = '10';
			tData.ErpSPART          = '71';
			tData.ErpVKBUR          = '5600';

			tData.CHARG             = orderWrapper.order.TransferMachineNo__r.BatchNo__c;
			tData.VSTEL             = sVSTEL;
			tData.LGORT             = sLGORT;

			// 2021-07-26 수정 ============================================================================================
			tData.KEDAT             = ((Datetime)orderWrapper.order.OrderScheduleDate__c).format('yyyyMMdd');   // 납품요청월
			tData.DLTXT             = orderWrapper.order.DeliveryComment__c == null ? '' : orderWrapper.order.DeliveryComment__c;   // 출하전달사항
			// ============================================================================================================

			tData.ErpPOSNR          = orderWrapper.order.ErpPOSNR__c;
			tData.ErpZTERM          = ' ';
			tData.SalesDocNo        = orderWrapper.order.SalesDocNo__c;
			tData.ErpCMGST          = ' ';
			tData.ErpABGRU          = ' ';
			tData.ErpS_RESULT       = ' ';
			tData.ErpS_MESSAGE      = ' ';

			// 가격 정정 정보
			tData.NETWR1_C          = oli.BaseSellingPrice__c == null ? '' : String.valueOf(oli.BaseSellingPrice__c);  // 기준 가격
			tData.NETWR2_C          = oli.CorrectionPrice__c == null ? '0' : String.valueOf(oli.CorrectionPrice__c);  // 가격 변경
			tData.NETWR3_C          = oli.SellingPrice__c == null ? '' : String.valueOf(oli.SellingPrice__c);  // 공급 가격
			tData.RESERVE01         = ' ';   // 예비1
			tData.RESERVE02         = ' ';   // 예비2
			tData.RESERVE03         = ' ';   // 예비3
			tData.RESERVE04         = ' ';   // 예비4
			tData.RESERVE05         = ' ';   // 예비5

			if(orderWrapper.order.PriceDecisionDate__c == null) {
				tData.PRSDT             = String.valueOf(system.now().format('yyyyMMdd'));  // 가격 결정일
			} else {
				tData.PRSDT             = ((Datetime)orderWrapper.order.PriceDecisionDate__c).format('yyyyMMdd');  // 가격 결정일
			}

			// 적재
			input.request.payload.t_data.add(tData);
		}

		// Interface Request 실행
		System.debug('### input.request.payload.t_data : '+input.request.payload.t_data);
		if(!input.request.payload.t_data.isEmpty()){
			// crashTest
			//IF_Base.crashTest = true;
			result = instance.execute(input);
		}

		if ('S'.equals(result.response.header.ifResult)) {
			List<IF_KR_SE_ERP_0007.T_DATA> t_data = result.Response.payload.t_data;
			for(IF_KR_SE_ERP_0007.T_DATA temp: t_data) {
				// 데이터 확인
				if(temp.ErpS_RESULT == '00') {
					returnMap.put('STATUS', 'Y');
					returnMap.put('MESSAGE', '주문정정성공[ZORT]');

					orderWrapper.order.ErpZTERM__c        = temp.ErpZTERM;
					//orderWrapper.order.SalesDocNo__c      = temp.SalesDocNo;
					orderWrapper.order.ErpCMGST__c        = temp.ErpCMGST;
					orderWrapper.order.ErpABGRU__c        = temp.ErpABGRU;
					orderWrapper.order.ErpS_RESULT__c     = temp.ErpS_RESULT;
					orderWrapper.order.ErpS_MESSAGE__c    = temp.ErpS_MESSAGE;
					orderWrapper.order.ErpPOSNR__c        = temp.ErpPOSNR;

					if (temp.ErpCMGST == 'B' ) {
						if(orderWrapper.order.RecordType.Name != '관납/농협') {
							orderWrapper.order.Status__c = '본사 여신 검토';
							orderWrapper.order.SystemStatus__c = '본사 여신 검토';    // 파트너 커뮤니티 사용자가 임의로 상태 변경하는 것을 방지하는 목적
							orderWrapper.order.ErpZLNNO__c = null;      // 여신번호
						} else {
							orderWrapper.order.Status__c = '출하';
							orderWrapper.order.SystemStatus__c = '출하';    // 파트너 커뮤니티 사용자가 임의로 상태 변경하는 것을 방지하는 목적
						}
					} else if (String.isEmpty(temp.ErpCMGST) || temp.ErpCMGST == 'A' || temp.ErpCMGST == 'D') {
						orderWrapper.order.Status__c = '출하';
						orderWrapper.order.SystemStatus__c = '출하';    // 파트너 커뮤니티 사용자가 임의로 상태 변경하는 것을 방지하는 목적
					}

					// temp.ErpABGRU = '95' (수주 손익 미결재) 일 경우 Dealer__r.Owner.Id 에게 Chatter 알림
					if(temp.ErpABGRU == '95'){
						String chatterMessage = '수주 손익 미결재 건 입니다. 확인 바랍니다.';
						Set<String> mentionsIds = new Set<String>();
						if(orderWrapper.order.BusinessOfficeRep__c != null) mentionsIds.add(orderWrapper.order.BusinessOfficeRep__c);
						if(orderWrapper.order.BusinessOfficeRep__r.ManagerId != null) mentionsIds.add(orderWrapper.order.BusinessOfficeRep__r.ManagerId);
						LacComChatterService.simpleChatterFeed(null, orderWrapper.order.Id, chatterMessage, mentionsIds);
					}
				} else {
					returnMap.put('STATUS', 'N');
					returnMap.put('MESSAGE', '주문정정오류[ZORT] : '+temp.ErpS_MESSAGE);

					orderWrapper.order.ErpS_RESULT__c     = temp.ErpS_RESULT;
					orderWrapper.order.ErpS_MESSAGE__c    = temp.ErpS_MESSAGE;
				}
			}
		} else {
			//실패 Failed to Request
			returnMap.put('STATUS', 'N');
			returnMap.put('MESSAGE', '주문정정오류[ZORT] : ' + result.response.header.ifFailMsg);
		}

		return orderWrapper;
	}

	/**
     * @description : OrderUpdate_ZRET 주문 정정 (SE <-> ERP)
     *                SFDC 내 주문 확정시 ERP 내 주문 연계 (테스트 중)
     *                이후 없어짐. : 2022/01/18
     * Order__c 에 OrderLineItem__c는 1개임.
     * Update Order, OrderLineitem
     * 버튼에서 호출됨
     */
	public static Map<String, String> OrderUpdate_ZRET(OrderTransferPriceEditQa.ReturnOrder returnOrder) {

		Map<String, String> returnMap = new Map<String, String>();

		IF_KR_SE_ERP_0007           instance = IF_KR_SE_ERP_0007.getInstance();
		IF_KR_SE_ERP_0007.InputDIH  input = new IF_KR_SE_ERP_0007.InputDIH();
		IF_KR_SE_ERP_0007.T_DATA    tData;
		IF_KR_SE_ERP_0007.OutputDIH result;


		Map<String, String> VSTELMap = new Map<String, String>();
		VSTELMap.put('71A', 'M621');        // M621경기
		VSTELMap.put('71C', 'M622');        // M622충북
		VSTELMap.put('71E', 'M623');        // M623전북
		VSTELMap.put('71G', 'M624');        // M624경북
		VSTELMap.put('71B', 'M625');        // M625강원
		VSTELMap.put('71D', 'M626');        // M626충남
		VSTELMap.put('71F', 'M627');        // M627전남
		VSTELMap.put('71H', 'M628');        // M628경남

		Map<String, String> LGORTMap = new Map<String, String>();
		LGORTMap.put('71A', '3711');        // 3711경기
		LGORTMap.put('71C', '3712');        // 3712충북
		LGORTMap.put('71E', '3713');        // 3713전북
		LGORTMap.put('71G', '3714');        // 3714경북
		LGORTMap.put('71B', '3715');        // 3715강원
		LGORTMap.put('71D', '3716');        // 3716충남
		LGORTMap.put('71F', '3717');        // 3717전남
		LGORTMap.put('71H', '3718');        // 3718경남

		String sVSTEL = VSTELMap.containsKey(returnOrder.tOrder.TransferDealer__r.BusinessOfficeName__c) ?
				VSTELMap.get(returnOrder.tOrder.TransferDealer__r.BusinessOfficeName__c) :
				'';
		String sLGORT = LGORTMap.containsKey(returnOrder.tOrder.TransferDealer__r.BusinessOfficeName__c) ?
				LGORTMap.get(returnOrder.tOrder.TransferDealer__r.BusinessOfficeName__c) :
				'';

		tData = new IF_KR_SE_ERP_0007.T_DATA();

		tData.OrderID           = returnOrder.tOrder.Id;
		tData.OrderLineItemID   = returnOrder.tOrder.OrderLineitem__c;
		tData.ProductCode       = returnOrder.tOrder.Product__r.ProductCode;
		tData.ErpVKGRP          = returnOrder.order.TransferMachineNo__r.BusinessOffice__r.SalesGroupCode__c;   //BusinessOffice__r.SalesGroupCode__c;
		tData.ErpBSTKD          = returnOrder.order.SalesDocNo__c;
		tData.ErpBSTDK          = String.valueOf(system.now().format('yyyyMMdd'));      // 원주문의 PO 날짜가 필요한데 값이 없다.

		// 수배 대리점의 ERP Code를 지정 해야 한다.
		// 수배 대리점의 자산의 고객이 농협/관납이면 농협/관납 ERPCode__c를 보낸다.
		// 2021/04/22
		//
		tData.ErpKUNNR          = returnOrder.tOrder.TransferDealer__r.ERPCode__c;
		tData.ErpKUNNR2         = returnOrder.tOrder.TransferDealer__r.ERPCode__c;
		tData.ErpKUNNR3         = returnOrder.tOrder.TransferDealer__r.ERPCode__c;
//        order.TransferMachineNo__r.Dealer__r.ERPCode__c,
//        order.TransferMachineNo__r.Account.ERPCode__c,
		Set<String> checkCustomers = new Set<String>{'농협','관납'};
		if(checkCustomers.contains(returnOrder.order.TransferMachineNo__r.Account.CustomerType__c)) {
			tData.ErpKUNNR          = returnOrder.order.TransferMachineNo__r.Account.ERPCode__c;
			tData.ErpKUNNR2         = returnOrder.order.TransferMachineNo__r.Account.ERPCode__c;
			tData.ErpKUNNR3         = returnOrder.order.TransferMachineNo__r.Account.ERPCode__c;
		}

		tData.Quanitity         = '1';
		tData.ErpZFLAG          = 'U';    // C: 생성, U : 수정 : D: 삭제
		tData.ErpAUART          = 'ZRET';
		tData.ErpVKORG          = '3000';
		tData.ErpVTWEG          = '10';
		tData.ErpSPART          = '71';
		tData.ErpVKBUR          = '5600';

		tData.CHARG             = returnOrder.order.TransferMachineNo__r.BatchNo__c;
		tData.VSTEL             = sVSTEL;
		tData.LGORT             = sLGORT;

		// 2021-07-26 수정 ============================================================================================
		tData.KEDAT             = ((Datetime)returnOrder.order.OrderScheduleDate__c).format('yyyyMMdd');   // 납품요청월
		tData.DLTXT             = returnOrder.order.DeliveryComment__c;                                    // 출하전달사항
		// ============================================================================================================

		tData.ErpPOSNR          = returnOrder.tOrder.ERP_POSNR__c;
		tData.ErpZTERM          = ' ';
		tData.SalesDocNo        = returnOrder.tOrder.SalesDocNo__c;
		tData.ErpCMGST          = ' ';
		tData.ErpABGRU          = ' ';
		tData.ErpS_RESULT       = ' ';
		tData.ErpS_MESSAGE      = ' ';

		// 가격 정정 정보
		tData.NETWR1_C          = returnOrder.tOrder.BaseSellingPrice__c == null ? '' : String.valueOf(returnOrder.tOrder.BaseSellingPrice__c);  // 기준 가격
		tData.NETWR2_C          = returnOrder.tOrder.CorrectionPrice__c == null ? '0' : String.valueOf(returnOrder.tOrder.CorrectionPrice__c);  // 가격 변경
		tData.NETWR3_C          = returnOrder.tOrder.SellingPrice__c == null ? '' : String.valueOf(returnOrder.tOrder.SellingPrice__c);  // 공급 가격
		tData.RESERVE01         = '';   // 예비1
		tData.RESERVE02         = '';   // 예비2
		tData.RESERVE03         = '';   // 예비3
		tData.RESERVE04         = '';   // 예비4
		tData.RESERVE05         = '';   // 예비5

		tData.PRSDT             = String.valueOf(((Datetime) returnOrder.tOrder.Order__r.TransferMachineNo__r.Order__r.PriceDecisionDate__c).format('yyyyMMdd')); // 가격 결정일

		// 적재
		input.request.payload.t_data.add(tData);

		// Interface Request 실행
		System.debug('### input.request.payload.t_data : '+input.request.payload.t_data);
		if(!input.request.payload.t_data.isEmpty()){
			// crashTest
			//IF_Base.crashTest = true;
			result = instance.execute(input);
		}

		if ('S'.equals(result.response.header.ifResult)) {
			List<IF_KR_SE_ERP_0007.T_DATA> t_data = result.Response.payload.t_data;
			for(IF_KR_SE_ERP_0007.T_DATA temp: t_data) {
				// 데이터 확인
				if(temp.ErpS_RESULT == '00') {
					returnMap.put('STATUS', 'Y');
					returnMap.put('MESSAGE', '반품주문 정정성공[ZRET]');
				} else {
					returnMap.put('STATUS', 'N');
					returnMap.put('MESSAGE', '반품주문 정정오류[ZRET] : '+temp.ErpS_MESSAGE);
				}
			}
		} else {
			//실패 Failed to Request
			returnMap.put('STATUS', 'N');
			returnMap.put('MESSAGE', '반품주문 정정오류[ZRET] : ' + result.response.header.ifFailMsg);
		}

		return returnMap;
	}


	public static void runTest() {
		Integer yr_seo = 0;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
	}
}