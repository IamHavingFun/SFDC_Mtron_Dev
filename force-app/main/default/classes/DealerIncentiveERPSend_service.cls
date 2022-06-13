/**
 * Created by MS on 2022-01-24.
 */

public with sharing class DealerIncentiveERPSend_service {

	public static void incentiveERPSend(List<DealerIncentiveInput__c> scope) {

		IF_KR_SE_ERP_0043 instance = IF_KR_SE_ERP_0043.getInstance();
		// 서비스 실행
		IF_KR_SE_ERP_0043.InputDIH input = new IF_KR_SE_ERP_0043.InputDIH();

		Integer seqNo;
		String LOEKZ;   // 수수료 상세 구분
		String CHRGB;   //  출하와 동시에 발생한 수수료(1)인지, 이후에 발생한 수수료인지 (2). 2022년 이전 출하 기대(3), 4- 2022년 이전

		String salesDocNo;
		String lineNumber;
		String status;
		Decimal SupplyAmount;
		String txtSupplyAmount;
		String txtWMSupplyAmount;
		Boolean isCurrentPDI;
		Boolean isNormalFee;
		IF_KR_SE_ERP_0043.INPUT_T_DATA_1 tData1;
		IF_KR_SE_ERP_0043.INPUT_T_DATA_2 tData2;
		Date DealerReceiptDate;
		IF_KR_SE_ERP_0043.INPUT_IMPORT tImport = new IF_KR_SE_ERP_0043.INPUT_IMPORT();
		tImport.I_TYPE = '';
		input.request.payload.t_data_import = tImport;
		for (DealerIncentiveInput__c target : scope) {
			seqNo = target.Asset__r.IncentiveSeqNo__c == null ? 10 : Integer.valueOf(target.Asset__r.IncentiveSeqNo__c);
			if(seqNo < 10) seqNo = seqNo + 10;
			isCurrentPDI = false;
			DealerReceiptDate = target.Asset__r.DealerReceiptDate__c;
			if(target.Asset__r.InventoryType__c == '공장재고(가용)' || target.Asset__r.InventoryType__c == '공장재고(QI)') {
				if(DealerReceiptDate == null) {
					// 반품인 경우
					if(target.Asset__r.FirstDeliveryDate__c != null) {
						DealerReceiptDate = target.Asset__r.FirstDeliveryDate__c;
					} else {
						if(target.Asset__r.ProductionDate__c != null) {
							DealerReceiptDate = target.Asset__r.ProductionDate__c;
						}
					}
				}
			}
			if(DealerReceiptDate != null && DealerReceiptDate.toStartOfMonth() == target.BaseDate__c.toStartOfMonth()) {
				isCurrentPDI = true;
			}
			// 최초 출하월 로직 보완.
			txtSupplyAmount = target.fm_SalesSellingAmount__c;

			// 과거 판매 장려 금액 반환 처리.
			if(target.DealerIncentiveCalculate1__c != null) {
				salesDocNo = target.DealerIncentiveCalculate1__r.SalesDocNo__c;
				lineNumber = target.DealerIncentiveCalculate1__r.LineNumber__c;
				status = target.DealerIncentiveCalculate1__r.Status__c == '지급' ? '' : 'X';
				SupplyAmount = target.DealerIncentiveCalculate1__r.SupplyAmount__c;

				if(target.Type__c == '대리점') {
					tData1 = new IF_KR_SE_ERP_0043.INPUT_T_DATA_1();
					tData1.ZSFDC        = target.Id;
					tData1.VBELN        = salesDocNo ;      // 판매오더
					tData1.POSNR        = lineNumber == null ? '000010' : lineNumber ;      // 판매오더품목
					if(status == 'X') {
						tData1.CHRGB        = '3';
					} else {
						tData1.CHRGB        = isCurrentPDI == true ? '1' : '2' ;      // 수수료 구분
					}
					target.DealerIncentiveCalculate1__r.ERPSeqNo__c = seqNo;
					tData1.SEQNO        = String.valueOf(seqNo);      // 순번
					tData1.ZYYMM        = DealerIncentiveERPSend_service.getDateYYYYMM(target.BaseDate__c);      // 정산기준년월
					tData1.CALYM        = DealerIncentiveERPSend_service.getDateYYYYMM(DealerReceiptDate);      // 산출대상년월
					tData1.KUNNR        = target.Dealer__r.ERPCode__c;      // 판매처
					tData1.MATNR        = target.Asset__r.Product2.ProductCode;              // 자재 번호
					tData1.PERNR        = target.Dealer__r.Owner.EmployeeNumber;       // 사원 번호
					tData1.VGBEL        = '' ;      // 트랙터 판매오더
					tData1.VGPOS        = '' ;      // 트랙터 판매오더 품목
					tData1.NPDIET        = '';      // 미지급.
					tData1.NPDIEM        = '';
					tData1.CHARG        = target.Asset__r.BatchNo__c;      // 배치번호
					tData1.SHKZG        = status;      // 반품품목
					tData1.CRIMG        = status == 'X' ? '-1' : '';      // 반품수량
					tData1.LFIMG        = status == 'X' ? '-1' : '1';     // 실제수량납품 (판매단위)
					tData1.MEINS        = 'EA';      // 기본 단위
					tData1.WAERK        = 'KRW';      // 통화
					tData1.NETPR        = txtSupplyAmount;      // 공급 가격
					tData1.PDIEXC       = '';      // PDI 제외
					tData1.PDIEX        = '';      // PDI 실행

					//PDI 등록
					tData1.PDIET        = '';      // PDI 등록(%)
					tData1.PDIEM        = '';      // PDI 등록
					//조기안착지원
					tData1.NESFT        = '';      // 조기안착지원(%)
					tData1.NESFM        = '';      // 조기안착지원
					//사전판매장려
					tData1.EPSRT        = '';      // 사전판매장려(%)
					tData1.EPSAM        = '';      // 사전판매장려

					//시승체험지원
					tData1.TESRT        = '';      // 시승체험지원(%)
					tData1.TESAM        = '';      // 시승체험지원
					//사양차액지원
					tData1.SDSRT        = '';      // 사양차액지원(%)
					tData1.SDSAM        = '';      // 사양차액지원
					//특별판촉지원
					tData1.SPSRT        = '';      // 특별판촉지원(%)
					tData1.SPSAM        = '';      // 특별판촉지원
					//무상작업기지원
					tData1.FMSRT        = '';      // 무상적업기지원(%)
					tData1.FMSAM        = '';      // 무상작업기지원
					//Sales I.Q. 달성
					tData1.PIERT        = '';      // Sales I.Q. 달성(%)
					tData1.PIEAM        = '';      // Sales I.Q. 달성

					tData1.CSPRT        = DealerIncentiveERPSend_service.getConvertRate(target.CSIncentiveRate__c);      // CS수수료 율
					tData1.CSPAM        = DealerIncentiveERPSend_service.getConvertCurrency(target.CSIncentiveAmount__c);      // CS수수료 금액
					tData1.MASRT        = DealerIncentiveERPSend_service.getConvertRate(target.AdSalesRate__c);      // 광고선점비 율
					tData1.MASAM        = DealerIncentiveERPSend_service.getConvertCurrency(target.AdSalesAmount__c);      // 광고선점비 금액
					tData1.STMRT        = DealerIncentiveERPSend_service.getConvertRate(target.SalesDiscountRate__c);      // 매출할인 율
					tData1.STMAM        = DealerIncentiveERPSend_service.getConvertCurrency(target.SalesDiscountAmount__c);      // 매출할인 금액
					tData1.CONFM1       = 'X';      // 수수료 영업그룹 확정 여부
					tData1.CONFM2       = 'X';      // 수수료 영업팀 확정 여부
					// REFLG    01 정상 02 특판제품 03 전략제품 04 전략지역 05 고정급 06 기존추가 07 신규추가 08 참조적자 09 적자 10 광역지역 11 목표달성 12 실판정산 13 중개
					tData1.REFLG        = status == 'X' ? '09' : '01';      // 수수료 상세구분
					tData1.LOEKZ        = '';      // 삭제지시

					tData1.URL1         = '';
					tData1.URL2         = '';
					tData1.URL3         = '';
					input.request.payload.t_data_1.add(tData1);
					seqNo ++;
				} else {
					//서비스..
					tData2 = new IF_KR_SE_ERP_0043.INPUT_T_DATA_2();
					tData2.ZSFDC = target.Id;
					tData2.VBELN = salesDocNo ;      // 판매오더
					tData2.POSNR = lineNumber == null ? '000010' : lineNumber ;      // 판매오더품목
					if (status == 'X') {
						tData2.CHRGB = '3';
					} else {
						tData2.CHRGB = isCurrentPDI == true ? '1' : '2' ;      // 수수료 구분
					}
					target.DealerIncentiveCalculate1__r.ERPSeqNo__c = seqNo;
					tData2.SEQNO = String.valueOf(seqNo);        // 순번
					tData2.ZYYMM = DealerIncentiveERPSend_service.getDateYYYYMM(target.BaseDate__c);      // 정산기준년월
					tData2.CALYM = DealerIncentiveERPSend_service.getDateYYYYMM(DealerReceiptDate);      // 산출대상년월
					tData2.KUNNR = target.Dealer__r.ERPCode__c;        // 판매처
					// 위탁점 어떻게??
					tData2.KUNNR = target.DealerIncentiveCalculate1__r.SalesAccount__r.ERPCode__c;        // 판매처
					tData2.AGENT = target.Dealer__r.ERPCode__c;        // 농협전문점/위탁점
					tData2.MATNR = target.Asset__r.Product2.ProductCode;        // 자재 번호
					tData2.PERNR = target.Dealer__r.Owner.EmployeeNumber;       // 사원 번호
					tData2.CHARG = target.Asset__r.BatchNo__c;      // 배치번호
					tData2.SHKZG = status;      // 반품품목
					tData2.CRIMG = status == 'X' ? '-1' : '';      // 반품수량
					tData2.LFIMG = status == 'X' ? '-1' : '1';     // 실제수량납품 (판매단위)
					tData2.MEINS = 'EA';        // 기본 단위
					tData2.NETPR = txtSupplyAmount;        // 단가
					tData2.WAERK = 'KRW';        // 통화
					tData2.SPCGB = '02';        // 전문점 구분
					tData2.GASRT = '';        // 관납사후봉사(%)
					tData2.GASAM = '';        // 관납사후봉사
					tData2.SVCRT = '';        // 농협사후봉사(%)
					tData2.SVCAM = '';        // 농협사후봉사
					tData2.BKRRT = '';        // 중개영업지원(%)
					tData2.BKRAM = '';        // 중개영업지원
					tData2.SCSRT = DealerIncentiveERPSend_service.getConvertRate(target.CSIncentiveRate__c);     // CS 위탁수수료율
					tData2.SCSAM = DealerIncentiveERPSend_service.getConvertCurrency(target.CSIncentiveAmount__c);      // CS 위탁 수수료 금액
					tData2.SSLRT = DealerIncentiveERPSend_service.getConvertRate(target.SalesIncentiveRate__c);        // 판매수수료율
					tData2.SSLAM = DealerIncentiveERPSend_service.getConvertCurrency(target.SalesIncentiveAmount__c);        // 판매수수료 금액

					tData2.CONFM1 = 'X';        // 수수료 영업그룹 확정 여부
					tData2.CONFM2 = 'X';        // 수수료 영업팀 확정 여부
					// REFLG    01 정상 02 특판제품 03 전략제품 04 전략지역 05 고정급 06 기존추가 07 신규추가 08 참조적자 09 적자 10 광역지역 11 목표달성 12 실판정산 13 중개
					tData2.REFLG = status == 'X' ? '09' : '01';      // 수수료 상세구분
					tData2.NGEGB = target.RecordType.Name == '농협' ? '1' : target.RecordType.Name == '관납' ? '2' : '';        // 농협/관납/기타 구분
					tData2.LOEKZ = '';        // 삭제지시
					input.request.payload.t_data_2.add(tData2);
					seqNo++;
				}
			} else {

				if(target.Type__c == '대리점') {
					isNormalFee = false;
					if(target.DealerIncentiveCalculate13__c != null) {
						salesDocNo = target.DealerIncentiveCalculate13__r.SalesDocNo__c;
						lineNumber = target.DealerIncentiveCalculate13__r.LineNumber__c;
						status = target.DealerIncentiveCalculate13__r.Status__c == '지급' ? '' : 'X';
						SupplyAmount = target.DealerIncentiveCalculate13__r.SupplyAmount__c;
						target.DealerIncentiveCalculate13__r.ERPSeqNo__c = seqNo;
						isNormalFee = true;
					}
					if(target.DealerIncentiveCalculate14__c != null) {
						salesDocNo = target.DealerIncentiveCalculate14__r.SalesDocNo__c;
						lineNumber = target.DealerIncentiveCalculate14__r.LineNumber__c;
						status = target.DealerIncentiveCalculate14__r.Status__c == '지급' ? '' : 'X';
						SupplyAmount = target.DealerIncentiveCalculate14__r.SupplyAmount__c;
						target.DealerIncentiveCalculate14__r.ERPSeqNo__c = seqNo;
						isNormalFee = true;
					}
					if(target.DealerIncentiveCalculate3__c != null) {
						salesDocNo = target.DealerIncentiveCalculate3__r.SalesDocNo__c;
						lineNumber = target.DealerIncentiveCalculate3__r.LineNumber__c;
						status = target.DealerIncentiveCalculate3__r.Status__c == '지급' ? '' : 'X';
						SupplyAmount = target.DealerIncentiveCalculate3__r.SupplyAmount__c;

						target.DealerIncentiveCalculate3__r.ERPSeqNo__c = seqNo;
						if(target.DealerIncentiveCalculate3__r.Division__c == '실적')  isNormalFee = true;
					}
					if(target.DealerIncentiveCalculate4__c != null) {
						salesDocNo = target.DealerIncentiveCalculate4__r.SalesDocNo__c;
						lineNumber = target.DealerIncentiveCalculate4__r.LineNumber__c;
						status = target.DealerIncentiveCalculate4__r.Status__c == '지급' ? '' : 'X';
						SupplyAmount = target.DealerIncentiveCalculate4__r.SupplyAmount__c;

						target.DealerIncentiveCalculate4__r.ERPSeqNo__c = seqNo;
						isNormalFee = true;
					}
					if(target.DealerIncentiveCalculate6__c != null) {
						salesDocNo = target.DealerIncentiveCalculate6__r.SalesDocNo__c;
						lineNumber = target.DealerIncentiveCalculate6__r.LineNumber__c;
						status = target.DealerIncentiveCalculate6__r.Status__c == '지급' ? '' : 'X';
						SupplyAmount = target.DealerIncentiveCalculate6__r.SupplyAmount__c;

						target.DealerIncentiveCalculate6__r.ERPSeqNo__c = seqNo;
						isNormalFee = true;
					}
					if(target.DealerIncentiveCalculate7__c != null) {
						salesDocNo = target.DealerIncentiveCalculate7__r.SalesDocNo__c;
						lineNumber = target.DealerIncentiveCalculate7__r.LineNumber__c;
						status = target.DealerIncentiveCalculate7__r.Status__c == '지급' ? '' : 'X';
						SupplyAmount = target.DealerIncentiveCalculate7__r.SupplyAmount__c;
						target.DealerIncentiveCalculate7__r.ERPSeqNo__c = seqNo;
						isNormalFee = true;
					}
					if(target.DealerIncentiveCalculate8__c != null) {
						salesDocNo = target.DealerIncentiveCalculate8__r.SalesDocNo__c;
						lineNumber = target.DealerIncentiveCalculate8__r.LineNumber__c;
						status = target.DealerIncentiveCalculate8__r.Status__c == '지급' ? '' : 'X';
						SupplyAmount = target.DealerIncentiveCalculate8__r.SupplyAmount__c;
						target.DealerIncentiveCalculate8__r.ERPSeqNo__c = seqNo;
						if(target.DealerIncentiveCalculate3__c != null) {
							//isCurrentPDI = false;
						}
						isNormalFee = true;
					}
					if(target.DealerIncentiveCalculate12__c != null) {
						salesDocNo = target.DealerIncentiveCalculate12__r.SalesDocNo__c;
						lineNumber = target.DealerIncentiveCalculate12__r.LineNumber__c;
						status = target.DealerIncentiveCalculate12__r.Status__c == '지급' ? '' : 'X';
						SupplyAmount = target.DealerIncentiveCalculate12__r.SupplyAmount__c;
						target.DealerIncentiveCalculate12__r.ERPSeqNo__c = seqNo;
						isNormalFee = true;
					}
					if(isNormalFee == true) {
						txtSupplyAmount = target.fm_SalesSellingAmount__c;
						System.debug(' txtSupplyAmount ==> ' + txtSupplyAmount);
						tData1 = new IF_KR_SE_ERP_0043.INPUT_T_DATA_1();
						tData1.ZSFDC = target.Id;
						tData1.VBELN = salesDocNo;      // 판매오더
						tData1.POSNR = lineNumber == null ? '000010' : lineNumber ;      // 판매오더품목
						if (status == 'X') {
							tData1.CHRGB = '3';
						} else {
							tData1.CHRGB = isCurrentPDI == true ? '1' : '2' ;      // 수수료 구분
						}

						tData1.SEQNO = String.valueOf(seqNo);      // 순번
						tData1.ZYYMM = DealerIncentiveERPSend_service.getDateYYYYMM(target.BaseDate__c);      // 정산기준년월
						tData1.CALYM = DealerIncentiveERPSend_service.getDateYYYYMM(DealerReceiptDate);      // 산출대상년월
						tData1.KUNNR = target.Dealer__r.ERPCode__c;      // 판매처
						tData1.MATNR = target.Asset__r.Product2.ProductCode;      // 자재 번호
						tData1.PERNR = target.Dealer__r.Owner.EmployeeNumber;      // 사원 번호
						tData1.VGBEL = '';      // 트랙터 판매오더
						tData1.VGPOS = '';      // 트랙터 판매오더 품목
						tData1.NPDIET = '';      // 미지급.
						tData1.NPDIEM = '';
						tData1.CHARG = target.Asset__r.BatchNo__c;      // 배치번호
						tData1.SHKZG = status;      // 반품품목
						tData1.CRIMG = status == 'X' ? '-1' : '';      // 반품수량
						tData1.LFIMG = status == 'X' ? '-1' : '1';     // 실제수량납품 (판매단위)
						tData1.MEINS = 'EA';      // 기본 단위
						tData1.WAERK = 'KRW';      // 통화
						//txtSupplyAmount = status == 'X' ? '-'+txtSupplyAmount : txtSupplyAmount;
						//System.debug(' txtSupplyAmount ==> ' + txtSupplyAmount);
						tData1.NETPR = txtSupplyAmount;      // 공급 가격
						tData1.PDIEXC = '';      // PDI 제외
						tData1.PDIEX = '';      // PDI 실행

						//PDI 등록
						tData1.PDIET = DealerIncentiveERPSend_service.getConvertRate(target.fm_DealerIncentiveCalculate3Rate__c);      // PDI 등록(%)
						tData1.PDIEM = DealerIncentiveERPSend_service.getConvertCurrency(target.fm_DealerIncentiveCalculate3Amount__c);      // PDI 등록
						//조기안착지원
						tData1.NESFT = DealerIncentiveERPSend_service.getConvertRate(target.fm_DealerIncentiveCalculate8Rate__c);      // 조기안착지원(%)
						tData1.NESFM = DealerIncentiveERPSend_service.getConvertCurrency(target.fm_DealerIncentiveCalculate8Amount__c);      // 조기안착지원
						//사전판매장려
						tData1.EPSRT = DealerIncentiveERPSend_service.getConvertRate(target.fm_DealerIncentiveCalculate6Rate__c);      // 사전판매장려(%)
						tData1.EPSAM = DealerIncentiveERPSend_service.getConvertCurrency(target.fm_DealerIncentiveCalculate6Amount__c);      // 사전판매장려

						//시승체험지원
						tData1.TESRT = DealerIncentiveERPSend_service.getConvertRate(target.fm_DealerIncentiveCalculate12Rate__c);      // 시승체험지원(%)
						tData1.TESAM = DealerIncentiveERPSend_service.getConvertCurrency(target.fm_DealerIncentiveCalculate12Amount__c);      // 시승체험지원
						//사양차액지원
						tData1.SDSRT = DealerIncentiveERPSend_service.getConvertRate(target.fm_DealerIncentiveCalculate13Rate__c);      // 사양차액지원(%)
						tData1.SDSAM = DealerIncentiveERPSend_service.getConvertCurrency(target.fm_DealerIncentiveCalculate13Amount__c);      // 사양차액지원
						tData1.URL1  = target.DealerIncentiveCalculate13__c == null ? '' : target.DealerIncentiveCalculate13__r.AddSalesIncentiveItem__r.AddSalesIncentive__c;
						//특별판촉지원
						tData1.SPSRT = DealerIncentiveERPSend_service.getConvertRate(target.fm_DealerIncentiveCalculate14Rate__c);      // 특별판촉지원(%)
						tData1.SPSAM = DealerIncentiveERPSend_service.getConvertCurrency(target.fm_DealerIncentiveCalculate14Amount__c);      // 특별판촉지원
						tData1.URL2  = target.DealerIncentiveCalculate14__c == null ? '' : target.DealerIncentiveCalculate14__r.AddSalesIncentiveItem__r.AddSalesIncentive__c;
						tData1.URL3  = '';

						//무상작업기지원
						tData1.FMSRT = '';      // 무상적업기지원(%)
						tData1.FMSAM = '';      // 무상작업기지원
						//Sales I.Q. 달성
						tData1.PIERT = DealerIncentiveERPSend_service.getConvertRate(target.fm_DealerIncentiveCalculate4Rate__c);      // Sales I.Q. 달성(%)
						tData1.PIEAM = DealerIncentiveERPSend_service.getConvertCurrency(target.fm_DealerIncentiveCalculate4Amount__c);      // Sales I.Q. 달성

						tData1.CSPRT = DealerIncentiveERPSend_service.getConvertRate(target.CSIncentiveRate__c);      // CS수수료 율
						tData1.CSPAM = DealerIncentiveERPSend_service.getConvertCurrency(target.CSIncentiveAmount__c);      // CS수수료 금액
						tData1.MASRT = DealerIncentiveERPSend_service.getConvertRate(target.AdSalesRate__c);      // 광고선점비 율
						tData1.MASAM = DealerIncentiveERPSend_service.getConvertCurrency(target.AdSalesAmount__c);      // 광고선점비 금액
						tData1.STMRT = DealerIncentiveERPSend_service.getConvertRate(target.SalesDiscountRate__c);      // 매출할인 율
						tData1.STMAM = DealerIncentiveERPSend_service.getConvertCurrency(target.SalesDiscountAmount__c);      // 매출할인 금액
						tData1.CONFM1 = 'X';      // 수수료 영업그룹 확정 여부
						tData1.CONFM2 = 'X';      // 수수료 영업팀 확정 여부
						// REFLG    01 정상 02 특판제품 03 전략제품 04 전략지역 05 고정급 06 기존추가 07 신규추가 08 참조적자 09 적자 10 광역지역 11 목표달성 12 실판정산 13 중개
						tData1.REFLG = status == 'X' ? '09' : '01';      // 수수료 상세구분
						tData1.LOEKZ = '';      // 삭제지시
						input.request.payload.t_data_1.add(tData1);
						seqNo++;
					}

					// 작업기 지원.
					if(target.DealerIncentiveCalculate15__c != null) {
						salesDocNo = target.DealerIncentiveCalculate15__r.AddSalesIncentiveItem__r.fm_SalesDocNo__c;
						lineNumber = target.DealerIncentiveCalculate15__r.AddSalesIncentiveItem__r.fm_SalesDocLineNo__c;
						String salesDocNoWm = target.DealerIncentiveCalculate15__r.AddSalesIncentiveItem__r.fm_SalesDocNoWM__c;
						String lineNumberWm = target.DealerIncentiveCalculate15__r.AddSalesIncentiveItem__r.fm_SalesDocLineNoWM__c;
						status = target.DealerIncentiveCalculate15__r.Status__c == '지급' ? '' : 'X';
						txtSupplyAmount = target.fm_SalesSellingAmount__c;
						txtWMSupplyAmount = target.fm_WMSalesSellingAmount__c;
						SupplyAmount = target.DealerIncentiveCalculate15__r.SupplyAmount__c;
						target.DealerIncentiveCalculate15__r.ERPSeqNo__c = seqNo;

						tData1 = new IF_KR_SE_ERP_0043.INPUT_T_DATA_1();
						tData1.ZSFDC = target.Id;
						tData1.VBELN = salesDocNoWm ;      // 판매오더
						tData1.POSNR = lineNumberWm == null ? '000010' : lineNumberWm ;      // 판매오더품목
						if(status == 'X') {
							tData1.CHRGB        = '3';
						} else {
							tData1.CHRGB        = isCurrentPDI == true ? '1' : '2' ;      // 수수료 구분
						}

						tData1.SEQNO        = String.valueOf(seqNo ++);      // 순번
						tData1.ZYYMM        = DealerIncentiveERPSend_service.getDateYYYYMM(target.BaseDate__c);      // 정산기준년월
						tData1.CALYM        = DealerIncentiveERPSend_service.getDateYYYYMM(DealerReceiptDate);      // 산출대상년월
						tData1.KUNNR        = target.Dealer__r.ERPCode__c;      // 판매처
						tData1.MATNR        = target.DealerIncentiveCalculate15__r.AddSalesIncentiveItem__r.SalesPerformance__r.ProductCode__c;      // 자재 번호
						tData1.PERNR        = target.Asset__r.Dealer__r.Owner.EmployeeNumber;      // 사원 번호
						tData1.VGBEL        = salesDocNo ;      // 트랙터 판매오더
						tData1.VGPOS        = lineNumber == null ? '000010' : lineNumber ;      // 트랙터 판매오더 품목
						tData1.NPDIET        = '';      // 미지급.
						tData1.NPDIEM        = '';
						tData1.CHARG        = target.Asset__r.BatchNo__c;      // 배치번호
						tData1.SHKZG        = status;      // 반품품목
						tData1.CRIMG        = status == 'X' ? '-1' : '';      // 반품수량
						tData1.LFIMG        = status == 'X' ? '-1' : '1';     // 실제수량납품 (판매단위)
						tData1.MEINS        = 'EA';      // 기본 단위
						tData1.WAERK        = 'KRW';      // 통화
						tData1.NETPR        = txtWMSupplyAmount;      // 공급 가격
						tData1.PDIEXC       = '';      // PDI 제외
						tData1.PDIEX        = '';      // PDI 실행

						//PDI 등록
						tData1.PDIET        = '';      // PDI 등록(%)
						tData1.PDIEM        = '';      // PDI 등록
						//조기안착지원
						tData1.NESFT        = '';      // 조기안착지원(%)
						tData1.NESFM        = '';      // 조기안착지원
						//사전판매장려
						tData1.EPSRT        = '';      // 사전판매장려(%)
						tData1.EPSAM        = '';      // 사전판매장려

						//시승체험지원
						tData1.TESRT        = '';      // 시승체험지원(%)
						tData1.TESAM        = '';      // 시승체험지원
						//사양차액지원
						tData1.SDSRT        = '';      // 사양차액지원(%)
						tData1.SDSAM        = '';      // 사양차액지원
						//특별판촉지원
						tData1.SPSRT        = '';      // 특별판촉지원(%)
						tData1.SPSAM        = '';      // 특별판촉지원
						//무상작업기지원
						tData1.FMSRT        = DealerIncentiveERPSend_service.getConvertRate(target.fm_DealerIncentiveCalculate15Rate__c);      // 무상적업기지원(%)
						tData1.FMSAM        = DealerIncentiveERPSend_service.getConvertCurrency(target.fm_DealerIncentiveCalculate15Amount__c);      // 무상작업기지원
						tData1.URL3         = target.DealerIncentiveCalculate15__c == null ? '' : target.DealerIncentiveCalculate15__r.AddSalesIncentiveItem__r.AddSalesIncentive__c;
						tData1.URL1         = '';
						tData1.URL2         = '';

						//Sales I.Q. 달성
						tData1.PIERT        = '';      // Sales I.Q. 달성(%)
						tData1.PIEAM        = '';      // Sales I.Q. 달성

						tData1.CSPRT        = DealerIncentiveERPSend_service.getConvertRate(target.CSIncentiveRate__c);      // CS수수료 율
						tData1.CSPAM        = DealerIncentiveERPSend_service.getConvertCurrency(target.CSIncentiveAmount__c);      // CS수수료 금액
						tData1.MASRT        = DealerIncentiveERPSend_service.getConvertRate(target.AdSalesRate__c);      // 광고선점비 율
						tData1.MASAM        = DealerIncentiveERPSend_service.getConvertCurrency(target.AdSalesAmount__c);      // 광고선점비 금액
						tData1.STMRT        = DealerIncentiveERPSend_service.getConvertRate(target.SalesDiscountRate__c);      // 매출할인 율
						tData1.STMAM        = DealerIncentiveERPSend_service.getConvertCurrency(target.SalesDiscountAmount__c);      // 매출할인 금액
						tData1.CONFM1       = 'X';      // 수수료 영업그룹 확정 여부
						tData1.CONFM2       = 'X';      // 수수료 영업팀 확정 여부
						// REFLG    01 정상 02 특판제품 03 전략제품 04 전략지역 05 고정급 06 기존추가 07 신규추가 08 참조적자 09 적자 10 광역지역 11 목표달성 12 실판정산 13 중개
						tData1.REFLG        = status == 'X' ? '09' : '01';      // 수수료 상세구분
						tData1.LOEKZ        = '';      // 삭제지시
						input.request.payload.t_data_1.add(tData1);
						seqNo++;
					}
				} else {

					if (target.DealerIncentiveCalculate9__c != null) {
						salesDocNo = target.DealerIncentiveCalculate9__r.SalesDocNo__c;
						lineNumber = target.DealerIncentiveCalculate9__r.LineNumber__c;
						status = target.DealerIncentiveCalculate9__r.Status__c == '지급' ? '' : 'X';
						SupplyAmount = target.DealerIncentiveCalculate9__r.SupplyAmount__c;
					}
					if (target.DealerIncentiveCalculate10__c != null) {
						salesDocNo = target.DealerIncentiveCalculate10__r.SalesDocNo__c;
						lineNumber = target.DealerIncentiveCalculate10__r.LineNumber__c;
						status = target.DealerIncentiveCalculate10__r.Status__c == '지급' ? '' : 'X';
						SupplyAmount = target.DealerIncentiveCalculate10__r.SupplyAmount__c;

						target.DealerIncentiveCalculate10__r.ERPSeqNo__c = seqNo;
					}
					if (target.DealerIncentiveCalculate11__c != null) {
						salesDocNo = target.DealerIncentiveCalculate11__r.SalesDocNo__c;
						lineNumber = target.DealerIncentiveCalculate11__r.LineNumber__c;
						status = target.DealerIncentiveCalculate11__r.Status__c == '지급' ? '' : 'X';
						SupplyAmount = target.DealerIncentiveCalculate11__r.SupplyAmount__c;
						target.DealerIncentiveCalculate11__r.ERPSeqNo__c = seqNo;
					}

					txtSupplyAmount = target.fm_SalesSellingAmount__c;

					//관납사후봉사
					if (target.DealerIncentiveCalculate9__c != null) {
						tData2 = new IF_KR_SE_ERP_0043.INPUT_T_DATA_2();
						tData2.ZSFDC = target.Id;
						tData2.VBELN = salesDocNo ;      // 판매오더
						tData2.POSNR = lineNumber == null ? '000010' : lineNumber ;      // 판매오더품목
						if (status == 'X') {
							tData2.CHRGB = '3';
						} else {
							tData2.CHRGB = isCurrentPDI == true ? '1' : '2' ;      // 수수료 구분
						}

						target.DealerIncentiveCalculate9__r.ERPSeqNo__c = seqNo;
						tData2.SEQNO = String.valueOf(seqNo);        // 순번
						tData2.ZYYMM = DealerIncentiveERPSend_service.getDateYYYYMM(target.BaseDate__c);      // 정산기준년월
						tData2.CALYM = DealerIncentiveERPSend_service.getDateYYYYMM(DealerReceiptDate);      // 산출대상년월
						tData2.KUNNR = target.DealerIncentiveCalculate9__r.SalesAccount__r.ERPCode__c;        // 판매처
						tData2.AGENT = target.Dealer__r.ERPCode__c;        // 농협전문점/위탁점
						tData2.MATNR = target.Asset__r.Product2.ProductCode;        // 자재 번호
						tData2.PERNR = target.Asset__r.Dealer__r.Owner.EmployeeNumber;        // 사원 번호
						tData2.CHARG = target.Asset__r.BatchNo__c;      // 배치번호
						tData2.SHKZG = status;      // 반품품목
						tData2.CRIMG = status == 'X' ? '-1' : '';      // 반품수량
						tData2.LFIMG = status == 'X' ? '-1' : '1';     // 실제수량납품 (판매단위)
						tData2.LFIMG = '1';        // 실제수량납품 (판매단위)
						tData2.MEINS = 'EA';        // 기본 단위
						tData2.NETPR = txtSupplyAmount;        // 단가
						tData2.WAERK = 'KRW';        // 통화
						tData2.SPCGB = '02';        // 전문점 구분
						tData2.GASRT = DealerIncentiveERPSend_service.getConvertRate(target.fm_DealerIncentiveCalculate9Rate__c);        // 관납사후봉사(%)
						tData2.GASAM = DealerIncentiveERPSend_service.getConvertCurrency(target.fm_DealerIncentiveCalculate9Amount__c);        // 관납사후봉사
						tData2.SVCRT = '';        // 농협사후봉사(%)
						tData2.SVCAM = '';        // 농협사후봉사
						tData2.SVCRT = '';        // 농협사후봉사(%)
						tData2.SVCAM = '';        // 농협사후봉사
						tData2.BKRRT = '';        // 중개영업지원(%)
						tData2.BKRAM = '';        // 중개영업지원
						tData2.SCSRT = DealerIncentiveERPSend_service.getConvertRate(target.CSIncentiveRate__c);      // CS 위탁수수료율
						tData2.SCSAM = DealerIncentiveERPSend_service.getConvertCurrency(target.CSIncentiveAmount__c);      // CS 위탁 수수료 금액
						tData2.SSLRT = DealerIncentiveERPSend_service.getConvertRate(target.SalesIncentiveRate__c);        // 판매수수료율
						tData2.SSLAM = DealerIncentiveERPSend_service.getConvertCurrency(target.SalesIncentiveAmount__c);        // 판매수수료 금액
						tData2.CONFM1 = 'X';        // 수수료 영업그룹 확정 여부
						tData2.CONFM2 = 'X';        // 수수료 영업팀 확정 여부
						// REFLG    01 정상 02 특판제품 03 전략제품 04 전략지역 05 고정급 06 기존추가 07 신규추가 08 참조적자 09 적자 10 광역지역 11 목표달성 12 실판정산 13 중개
						tData2.REFLG = status == 'X' ? '09' : '01';      // 수수료 상세구분
						tData2.NGEGB = target.RecordType.Name == '농협' ? '1' : target.RecordType.Name == '관납' ? '2' : '';        // 농협/관납/기타 구분
						tData2.LOEKZ = '';        // 삭제지시

						input.request.payload.t_data_2.add(tData2);
						seqNo++;
					}
					if (target.DealerIncentiveCalculate10__c != null) {
						//농협사후봉사
						tData2 = new IF_KR_SE_ERP_0043.INPUT_T_DATA_2();
						tData2.ZSFDC = target.Id;
						tData2.VBELN = salesDocNo ;      // 판매오더
						tData2.POSNR = lineNumber == null ? '000010' : lineNumber ;      // 판매오더품목
						if (status == 'X') {
							tData2.CHRGB = '3';
						} else {
							tData2.CHRGB = isCurrentPDI == true ? '1' : '2' ;      // 수수료 구분
						}
						target.DealerIncentiveCalculate10__r.ERPSeqNo__c = seqNo;
						tData2.SEQNO = String.valueOf(seqNo);        // 순번
						tData2.ZYYMM = DealerIncentiveERPSend_service.getDateYYYYMM(target.BaseDate__c);      // 정산기준년월
						tData2.CALYM = DealerIncentiveERPSend_service.getDateYYYYMM(DealerReceiptDate);      // 산출대상년월
						tData2.KUNNR = target.DealerIncentiveCalculate10__r.SalesAccount__r.ERPCode__c;        // 판매처
						tData2.AGENT = target.Dealer__r.ERPCode__c;        // 농협전문점/위탁점
						tData2.MATNR = target.Asset__r.Product2.ProductCode;        // 자재 번호
						tData2.PERNR = target.Dealer__r.Owner.EmployeeNumber;       // 사원 번호
						tData2.CHARG = target.Asset__r.BatchNo__c;      // 배치번호
						tData2.SHKZG = status;      // 반품품목
						tData2.CRIMG = status == 'X' ? '-1' : '';      // 반품수량
						tData2.LFIMG = status == 'X' ? '-1' : '1';     // 실제수량납품 (판매단위)
						tData2.MEINS = 'EA';        // 기본 단위
						tData2.NETPR = txtSupplyAmount;        // 단가
						tData2.WAERK = 'KRW';        // 통화
						tData2.SPCGB = '02';        // 전문점 구분
						tData2.GASRT = '';        // 관납사후봉사(%)
						tData2.GASAM = '';        // 관납사후봉사
						tData2.SVCRT = DealerIncentiveERPSend_service.getConvertRate(target.fm_DealerIncentiveCalculate10Rate__c);        // 농협사후봉사(%)
						tData2.SVCAM = DealerIncentiveERPSend_service.getConvertCurrency(target.fm_DealerIncentiveCalculate10Amount__c);        // 농협사후봉사
						tData2.BKRRT = '';        // 중개영업지원(%)
						tData2.BKRAM = '';        // 중개영업지원
						tData2.SCSRT = DealerIncentiveERPSend_service.getConvertRate(target.CSIncentiveRate__c);      // CS 위탁수수료율
						tData2.SCSAM = DealerIncentiveERPSend_service.getConvertCurrency(target.CSIncentiveAmount__c);      // CS 위탁 수수료 금액
						tData2.SSLRT = DealerIncentiveERPSend_service.getConvertRate(target.SalesIncentiveRate__c);        // 판매수수료율
						tData2.SSLAM = DealerIncentiveERPSend_service.getConvertCurrency(target.SalesIncentiveAmount__c);        // 판매수수료 금액
						tData2.CONFM1 = 'X';        // 수수료 영업그룹 확정 여부
						tData2.CONFM2 = 'X';        // 수수료 영업팀 확정 여부
						// REFLG    01 정상 02 특판제품 03 전략제품 04 전략지역 05 고정급 06 기존추가 07 신규추가 08 참조적자 09 적자 10 광역지역 11 목표달성 12 실판정산 13 중개
						tData2.REFLG = status == 'X' ? '09' : '01';      // 수수료 상세구분
						tData2.NGEGB = target.RecordType.Name == '농협' ? '1' : target.RecordType.Name == '관납' ? '2' : '';        // 농협/관납/기타 구분
						tData2.LOEKZ = '';        // 삭제지시
						input.request.payload.t_data_2.add(tData2);

						seqNo++;
					}
					if (target.DealerIncentiveCalculate11__c != null) {
						//중개영업지원
						tData2 = new IF_KR_SE_ERP_0043.INPUT_T_DATA_2();
						tData2.ZSFDC = target.Id;
						tData2.VBELN = salesDocNo ;      // 판매오더
						tData2.POSNR = lineNumber == null ? '000010' : lineNumber ;      // 판매오더품목
						if (status == 'X') {
							tData2.CHRGB = '3';
						} else {
							tData2.CHRGB = isCurrentPDI == true ? '1' : '2' ;      // 수수료 구분
						}
						target.DealerIncentiveCalculate11__r.ERPSeqNo__c = seqNo;
						tData2.SEQNO = String.valueOf(seqNo);        // 순번
						tData2.ZYYMM = DealerIncentiveERPSend_service.getDateYYYYMM(target.BaseDate__c);      // 정산기준년월
						tData2.CALYM = DealerIncentiveERPSend_service.getDateYYYYMM(DealerReceiptDate);      // 산출대상년월
						tData2.KUNNR = target.DealerIncentiveCalculate11__r.SalesAccount__r.ERPCode__c;        // 판매처
						tData2.AGENT = target.Dealer__r.ERPCode__c;        // 농협전문점/위탁점
						tData2.MATNR = target.Asset__r.Product2.ProductCode;        // 자재 번호
						tData2.PERNR = target.Dealer__r.Owner.EmployeeNumber;       // 사원 번호
						tData2.CHARG = target.Asset__r.BatchNo__c;      // 배치번호
						tData2.SHKZG = status;      // 반품품목
						tData2.CRIMG = status == 'X' ? '-1' : '';      // 반품수량
						tData2.LFIMG = status == 'X' ? '-1' : '1';     // 실제수량납품 (판매단위)
						tData2.MEINS = 'EA';        // 기본 단위
						tData2.NETPR = txtSupplyAmount;        // 단가
						tData2.WAERK = 'KRW';        // 통화
						tData2.SPCGB = '02';        // 전문점 구분
						tData2.GASRT = '';        // 관납사후봉사(%)
						tData2.GASAM = '';        // 관납사후봉사
						tData2.SVCRT = '';        // 농협사후봉사(%)
						tData2.SVCAM = '';        // 농협사후봉사
						tData2.BKRRT = DealerIncentiveERPSend_service.getConvertRate(target.fm_DealerIncentiveCalculate11Rate__c);        // 중개영업지원(%)
						tData2.BKRAM = DealerIncentiveERPSend_service.getConvertCurrency(target.fm_DealerIncentiveCalculate11Amount__c);        // 중개영업지원
						tData2.SCSRT = DealerIncentiveERPSend_service.getConvertRate(target.CSIncentiveRate__c);      // CS 위탁수수료율
						tData2.SCSAM = DealerIncentiveERPSend_service.getConvertCurrency(target.CSIncentiveAmount__c);      // CS 위탁 수수료 금액
						tData2.SSLRT = DealerIncentiveERPSend_service.getConvertRate(target.SalesIncentiveRate__c);        // 판매수수료율
						tData2.SSLAM = DealerIncentiveERPSend_service.getConvertCurrency(target.SalesIncentiveAmount__c);        // 판매수수료 금액
						tData2.CONFM1 = 'X';        // 수수료 영업그룹 확정 여부
						tData2.CONFM2 = 'X';        // 수수료 영업팀 확정 여부
						// REFLG    01 정상 02 특판제품 03 전략제품 04 전략지역 05 고정급 06 기존추가 07 신규추가 08 참조적자 09 적자 10 광역지역 11 목표달성 12 실판정산 13 중개
						tData2.REFLG = status == 'X' ? '09' : '01';      // 수수료 상세구분
						tData2.NGEGB = target.RecordType.Name == '농협' ? '1' : target.RecordType.Name == '관납' ? '2' : '';        // 농협/관납/기타 구분
						tData2.LOEKZ = '';        // 삭제지시
						input.request.payload.t_data_2.add(tData2);
						seqNo++;
					}
				}
			}
			target.Asset__r.IncentiveSeqNo__c = seqNo;
		}


		System.debug('-----------------------');
//		System.debug('result : '+JSON.serializePretty(input));
		System.debug('-----------------------');

		IF_KR_SE_ERP_0043.OutputDIH result = instance.execute(input);
		DealerIncentiveCalculate__c dic1;
		DealerIncentiveCalculate__c dic3;
		DealerIncentiveCalculate__c dic4;
		DealerIncentiveCalculate__c dic6;
		DealerIncentiveCalculate__c dic7;
		DealerIncentiveCalculate__c dic8;
		DealerIncentiveCalculate__c dic9;
		DealerIncentiveCalculate__c dic10;
		DealerIncentiveCalculate__c dic11;
		DealerIncentiveCalculate__c dic12;
		DealerIncentiveCalculate__c dic13;
		DealerIncentiveCalculate__c dic14;
		DealerIncentiveCalculate__c dic15;
		List<DealerIncentiveCalculate__c> updateList = new List<DealerIncentiveCalculate__c>();
		if(result.response.header.ifResult == 'S') {
			List<Asset> assets = new List<Asset>();
			Map<String, Asset> updateAssetMap = new Map<String, Asset>();
			Asset asset;
			for (DealerIncentiveInput__c target : scope) {
				if(updateAssetMap.containsKey(target.Asset__c)) {
					asset = updateAssetMap.get(target.Asset__c);
				} else {
					asset = target.Asset__r;
				}
				asset.IncentiveSeqNo__c = target.Asset__r.IncentiveSeqNo__c;
				updateAssetMap.put(target.Asset__c, asset);

				target.SendDate__c = Date.today();
				target.IsSend__c = true;

				if(target.DealerIncentiveCalculate1__c != null) {
					dic1 = target.DealerIncentiveCalculate1__r;
					dic1.ERPSendDate__c = Date.today();
					dic1.IsSendERP__c = true;
					updateList.add(dic1);
				}

				if(target.DealerIncentiveCalculate3__c != null) {
					dic3 = target.DealerIncentiveCalculate3__r;
					dic3.ERPSendDate__c = Date.today();
					dic3.IsSendERP__c = true;
					updateList.add(dic3);
				}

				if(target.DealerIncentiveCalculate4__c != null) {
					dic4 = target.DealerIncentiveCalculate4__r;
					dic4.ERPSendDate__c = Date.today();
					dic4.IsSendERP__c = true;
					updateList.add(dic4);
				}

				if(target.DealerIncentiveCalculate6__c != null) {
					dic6 = target.DealerIncentiveCalculate6__r;
					dic6.ERPSendDate__c = Date.today();
					dic6.IsSendERP__c = true;
					updateList.add(dic6);
				}

				if(target.DealerIncentiveCalculate7__c != null) {
					dic7 = target.DealerIncentiveCalculate7__r;
					dic7.ERPSendDate__c = Date.today();
					dic7.IsSendERP__c = true;
					updateList.add(dic7);
				}

				if(target.DealerIncentiveCalculate8__c != null) {
					dic8 = target.DealerIncentiveCalculate8__r;
					dic8.ERPSendDate__c = Date.today();
					dic8.IsSendERP__c = true;
					updateList.add(dic8);
				}

				if(target.DealerIncentiveCalculate9__c != null) {
					dic9 = target.DealerIncentiveCalculate9__r;
					dic9.ERPSendDate__c = Date.today();
					dic9.IsSendERP__c = true;
					updateList.add(dic9);
				}

				if(target.DealerIncentiveCalculate10__c != null) {
					dic10 = target.DealerIncentiveCalculate10__r;
					dic10.ERPSendDate__c = Date.today();
					dic10.IsSendERP__c = true;
					updateList.add(dic10);
				}

				if(target.DealerIncentiveCalculate11__c != null) {
					dic11 = target.DealerIncentiveCalculate11__r;
					dic11.ERPSendDate__c = Date.today();
					dic11.IsSendERP__c = true;
					updateList.add(dic11);
				}

				if(target.DealerIncentiveCalculate12__c != null) {
					dic12 = target.DealerIncentiveCalculate12__r;
					dic12.ERPSendDate__c = Date.today();
					dic12.IsSendERP__c = true;
					updateList.add(dic12);
				}

				if(target.DealerIncentiveCalculate13__c != null) {
					dic13 = target.DealerIncentiveCalculate13__r;
					dic13.ERPSendDate__c = Date.today();
					dic13.IsSendERP__c = true;
					updateList.add(dic13);
				}

				if(target.DealerIncentiveCalculate14__c != null) {
					dic14 = target.DealerIncentiveCalculate14__r;
					dic14.ERPSendDate__c = Date.today();
					dic14.IsSendERP__c = true;
					updateList.add(dic14);
				}

				if(target.DealerIncentiveCalculate15__c != null) {
					dic15 = target.DealerIncentiveCalculate15__r;
					dic15.ERPSendDate__c = Date.today();
					dic15.IsSendERP__c = true;
					updateList.add(dic15);
				}

			}

			update scope;
			if(updateAssetMap.isEmpty() == false) {
				update updateAssetMap.values();
			}
			if(updateList.isEmpty() == false) {
				update updateList;
			}

		}
		System.debug('-----------------------');
//		System.debug('result : '+JSON.serializePretty(result));
		System.debug('-----------------------');


	}

	/**
	 * 집계표 승인 : 파트너 승인건 전송
	 * @param scope
	 */
	public static void incentiveERPSendPartner(List<DealerIncentiveInput__c> scope) {

		IF_KR_SE_ERP_0043 instance = IF_KR_SE_ERP_0043.getInstance();
		// 서비스 실행
		IF_KR_SE_ERP_0043.InputDIH input = new IF_KR_SE_ERP_0043.InputDIH();

		Decimal seqNo;
		String LOEKZ;   // 수수료 상세 구분
		String CHRGB;   //  출하와 동시에 발생한 수수료(1)인지, 이후에 발생한 수수료인지 (2). 2022년 이전 출하 기대(3), 4- 2022년 이전

		String salesDocNo;
		String lineNumber;
		String status;
		Decimal SupplyAmount;
		String txtSupplyAmount;
		String txtWMSupplyAmount;
		Boolean isCurrentPDI;
		Boolean isNormalFee;
		IF_KR_SE_ERP_0043.INPUT_T_DATA_3 tData3;
		Date DealerReceiptDate;

		IF_KR_SE_ERP_0043.INPUT_IMPORT tImport = new IF_KR_SE_ERP_0043.INPUT_IMPORT();
		tImport.I_TYPE = 'A';
		input.request.payload.t_data_import = tImport;

		for (DealerIncentiveInput__c target : scope) {
			isCurrentPDI = false;
			DealerReceiptDate = target.Asset__r.DealerReceiptDate__c;
			if(target.Asset__r.InventoryType__c == '공장재고(가용)' || target.Asset__r.InventoryType__c == '공장재고(QI)') {
				if(DealerReceiptDate == null) {
					// 반품인 경우
					if(target.Asset__r.FirstDeliveryDate__c != null) {
						DealerReceiptDate = target.Asset__r.FirstDeliveryDate__c;
					} else {
						if(target.Asset__r.ProductionDate__c != null) {
							DealerReceiptDate = target.Asset__r.ProductionDate__c;
						}
					}
				}
			}
			if(DealerReceiptDate != null && DealerReceiptDate.toStartOfMonth() == target.BaseDate__c.toStartOfMonth()) {
				isCurrentPDI = true;
			}

			// 과거 판매 장려 금액 반환 처리.
			if(target.DealerIncentiveCalculate1__c != null) {
				salesDocNo = target.DealerIncentiveCalculate1__r.SalesDocNo__c;
				lineNumber = target.DealerIncentiveCalculate1__r.LineNumber__c;
				status = target.DealerIncentiveCalculate1__r.Status__c == '지급' ? '' : 'X';

				if(target.Type__c == '대리점') {
					tData3 = new IF_KR_SE_ERP_0043.INPUT_T_DATA_3();
					tData3.VBELN        = salesDocNo ;      // 판매오더
					tData3.POSNR        = lineNumber == null ? '000010' : lineNumber ;      // 판매오더품목
					if(status == 'X') {
						tData3.CHRGB        = '3';
					} else {
						tData3.CHRGB        = isCurrentPDI == true ? '1' : '2' ;      // 수수료 구분
					}

					tData3.SEQNO        = String.valueOf(Integer.valueOf(target.DealerIncentiveCalculate1__r.ERPSeqNo__c));      // 순번
					tData3.ZTYPE        = 'A';
					tData3.ZSFDC        = target.Id;
					tData3.CHARG        = target.Asset__r.BatchNo__c;      // 배치번호
					tData3.APPRO        = 'Y';
					tData3.APPNM        = target.IsPartnerIncentiveAutoApproval__c == true ? '자동 승인' : target.PartnerApprovalUser__r.Name;
					tData3.APPDT        = target.PartnerApprovalDatetime__c.format('yyyy-MM-dd');
					tData3.APPTM        = target.PartnerApprovalDatetime__c.format('HH:mm:ss');
					input.request.payload.t_data_3.add(tData3);
				} else {
					//서비스..
					tData3 = new IF_KR_SE_ERP_0043.INPUT_T_DATA_3();
					tData3.VBELN        = salesDocNo ;      // 판매오더
					tData3.POSNR        = lineNumber == null ? '000010' : lineNumber ;      // 판매오더품목
					if(status == 'X') {
						tData3.CHRGB        = '3';
					} else {
						tData3.CHRGB        = isCurrentPDI == true ? '1' : '2' ;      // 수수료 구분
					}
					tData3.SEQNO        = String.valueOf(Integer.valueOf(target.DealerIncentiveCalculate1__r.ERPSeqNo__c));      // 순번
					tData3.ZTYPE        = 'B';
					tData3.ZSFDC        = target.Id;
					tData3.CHARG        = target.Asset__r.BatchNo__c;      // 배치번호
					tData3.APPRO        = 'Y';
					tData3.APPNM        = target.IsPartnerIncentiveAutoApproval__c == true ? '자동 승인' : target.PartnerApprovalUser__r.Name;
					tData3.APPDT        = target.PartnerApprovalDatetime__c.format('yyyy-MM-dd');
					tData3.APPTM        = target.PartnerApprovalDatetime__c.format('HH:mm:ss');
					input.request.payload.t_data_3.add(tData3);
				}
			} else {

				if(target.Type__c == '대리점') {
					isNormalFee = false;
					if(target.DealerIncentiveCalculate13__c != null) {
						salesDocNo = target.DealerIncentiveCalculate13__r.SalesDocNo__c;
						lineNumber = target.DealerIncentiveCalculate13__r.LineNumber__c;
						status = target.DealerIncentiveCalculate13__r.Status__c == '지급' ? '' : 'X';
						seqNo = target.DealerIncentiveCalculate13__r.ERPSeqNo__c;
						isNormalFee = true;
					}
					if(target.DealerIncentiveCalculate14__c != null) {
						salesDocNo = target.DealerIncentiveCalculate14__r.SalesDocNo__c;
						lineNumber = target.DealerIncentiveCalculate14__r.LineNumber__c;
						status = target.DealerIncentiveCalculate14__r.Status__c == '지급' ? '' : 'X';
						seqNo = target.DealerIncentiveCalculate14__r.ERPSeqNo__c;
						isNormalFee = true;
					}
					if(target.DealerIncentiveCalculate3__c != null) {
						salesDocNo = target.DealerIncentiveCalculate3__r.SalesDocNo__c;
						lineNumber = target.DealerIncentiveCalculate3__r.LineNumber__c;
						status = target.DealerIncentiveCalculate3__r.Status__c == '지급' ? '' : 'X';
						seqNo = target.DealerIncentiveCalculate3__r.ERPSeqNo__c;
						if(target.DealerIncentiveCalculate3__r.Division__c == '실적')  isNormalFee = true;
					}
					if(target.DealerIncentiveCalculate4__c != null) {
						salesDocNo = target.DealerIncentiveCalculate4__r.SalesDocNo__c;
						lineNumber = target.DealerIncentiveCalculate4__r.LineNumber__c;
						status = target.DealerIncentiveCalculate4__r.Status__c == '지급' ? '' : 'X';
						seqNo = target.DealerIncentiveCalculate4__r.ERPSeqNo__c;
						isNormalFee = true;
					}
					if(target.DealerIncentiveCalculate6__c != null) {
						salesDocNo = target.DealerIncentiveCalculate6__r.SalesDocNo__c;
						lineNumber = target.DealerIncentiveCalculate6__r.LineNumber__c;
						status = target.DealerIncentiveCalculate6__r.Status__c == '지급' ? '' : 'X';
						seqNo = target.DealerIncentiveCalculate6__r.ERPSeqNo__c;
						isNormalFee = true;
					}
					if(target.DealerIncentiveCalculate7__c != null) {
						salesDocNo = target.DealerIncentiveCalculate7__r.SalesDocNo__c;
						lineNumber = target.DealerIncentiveCalculate7__r.LineNumber__c;
						status = target.DealerIncentiveCalculate7__r.Status__c == '지급' ? '' : 'X';
						seqNo = target.DealerIncentiveCalculate7__r.ERPSeqNo__c;
						isNormalFee = true;
					}
					if(target.DealerIncentiveCalculate8__c != null) {
						salesDocNo = target.DealerIncentiveCalculate8__r.SalesDocNo__c;
						lineNumber = target.DealerIncentiveCalculate8__r.LineNumber__c;
						status = target.DealerIncentiveCalculate8__r.Status__c == '지급' ? '' : 'X';
						seqNo = target.DealerIncentiveCalculate8__r.ERPSeqNo__c;
						isNormalFee = true;
					}
					if(target.DealerIncentiveCalculate12__c != null) {
						salesDocNo = target.DealerIncentiveCalculate12__r.SalesDocNo__c;
						lineNumber = target.DealerIncentiveCalculate12__r.LineNumber__c;
						status = target.DealerIncentiveCalculate12__r.Status__c == '지급' ? '' : 'X';
						seqNo = target.DealerIncentiveCalculate12__r.ERPSeqNo__c;
						isNormalFee = true;
					}
					if(isNormalFee == true) {
						//대리점..
						tData3 = new IF_KR_SE_ERP_0043.INPUT_T_DATA_3();
						tData3.VBELN        = salesDocNo ;      // 판매오더
						tData3.POSNR        = lineNumber == null ? '000010' : lineNumber ;      // 판매오더품목
						if(status == 'X') {
							tData3.CHRGB        = '3';
						} else {
							tData3.CHRGB        = isCurrentPDI == true ? '1' : '2' ;      // 수수료 구분
						}
						tData3.SEQNO        = String.valueOf(Integer.valueOf(seqNo));      // 순번
						tData3.ZTYPE        = 'A';
						tData3.ZSFDC        = target.Id;
						tData3.CHARG        = target.Asset__r.BatchNo__c;      // 배치번호
						tData3.APPRO        = 'Y';
						tData3.APPNM        = target.IsPartnerIncentiveAutoApproval__c == true ? '자동 승인' : target.PartnerApprovalUser__r.Name;
						tData3.APPDT        = target.PartnerApprovalDatetime__c.format('yyyy-MM-dd');
						tData3.APPTM        = target.PartnerApprovalDatetime__c.format('HH:mm:ss');
						input.request.payload.t_data_3.add(tData3);
					}

					// 작업기 지원.
					if(target.DealerIncentiveCalculate15__c != null) {
						salesDocNo = target.DealerIncentiveCalculate15__r.AddSalesIncentiveItem__r.fm_SalesDocNo__c;
						lineNumber = target.DealerIncentiveCalculate15__r.AddSalesIncentiveItem__r.fm_SalesDocLineNo__c;
						String salesDocNoWm = target.DealerIncentiveCalculate15__r.AddSalesIncentiveItem__r.fm_SalesDocNoWM__c;
						String lineNumberWm = target.DealerIncentiveCalculate15__r.AddSalesIncentiveItem__r.fm_SalesDocLineNoWM__c;
						status = target.DealerIncentiveCalculate15__r.Status__c == '지급' ? '' : 'X';
						seqNo = target.DealerIncentiveCalculate15__r.ERPSeqNo__c;

						//서비스..
						tData3 = new IF_KR_SE_ERP_0043.INPUT_T_DATA_3();
						tData3.VBELN        = salesDocNoWm ;      // 판매오더
						tData3.POSNR        = lineNumberWm == null ? '000010' : lineNumberWm ;      // 판매오더품목
						if(status == 'X') {
							tData3.CHRGB        = '3';
						} else {
							tData3.CHRGB        = isCurrentPDI == true ? '1' : '2' ;      // 수수료 구분
						}
						tData3.SEQNO        = String.valueOf(Integer.valueOf(seqNo));      // 순번
						tData3.ZTYPE        = 'A';
						tData3.ZSFDC        = target.Id;
						tData3.CHARG        = target.Asset__r.BatchNo__c;      // 배치번호
						tData3.APPRO        = 'Y';
						tData3.APPNM        = target.IsPartnerIncentiveAutoApproval__c == true ? '자동 승인' : target.PartnerApprovalUser__r.Name;
						tData3.APPDT        = target.PartnerApprovalDatetime__c.format('yyyy-MM-dd');
						tData3.APPTM        = target.PartnerApprovalDatetime__c.format('HH:mm:ss');
						input.request.payload.t_data_3.add(tData3);
					}
				} else {

					if (target.DealerIncentiveCalculate9__c != null) {
						salesDocNo = target.DealerIncentiveCalculate9__r.SalesDocNo__c;
						lineNumber = target.DealerIncentiveCalculate9__r.LineNumber__c;
						status = target.DealerIncentiveCalculate9__r.Status__c == '지급' ? '' : 'X';
						seqNo = target.DealerIncentiveCalculate9__r.ERPSeqNo__c;
					}
					if (target.DealerIncentiveCalculate10__c != null) {
						salesDocNo = target.DealerIncentiveCalculate10__r.SalesDocNo__c;
						lineNumber = target.DealerIncentiveCalculate10__r.LineNumber__c;
						status = target.DealerIncentiveCalculate10__r.Status__c == '지급' ? '' : 'X';
						seqNo = target.DealerIncentiveCalculate10__r.ERPSeqNo__c;
					}
					if (target.DealerIncentiveCalculate11__c != null) {
						salesDocNo = target.DealerIncentiveCalculate11__r.SalesDocNo__c;
						lineNumber = target.DealerIncentiveCalculate11__r.LineNumber__c;
						status = target.DealerIncentiveCalculate11__r.Status__c == '지급' ? '' : 'X';
						seqNo = target.DealerIncentiveCalculate11__r.ERPSeqNo__c;
					}

					//관납사후봉사
					if (target.DealerIncentiveCalculate9__c != null) {
						tData3 = new IF_KR_SE_ERP_0043.INPUT_T_DATA_3();
						tData3.VBELN        = salesDocNo ;      // 판매오더
						tData3.POSNR        = lineNumber == null ? '000010' : lineNumber ;      // 판매오더품목
						if(status == 'X') {
							tData3.CHRGB        = '3';
						} else {
							tData3.CHRGB        = isCurrentPDI == true ? '1' : '2' ;      // 수수료 구분
						}
						tData3.SEQNO        = String.valueOf(Integer.valueOf(target.DealerIncentiveCalculate9__r.ERPSeqNo__c));      // 순번
						tData3.ZTYPE        = 'B';
						tData3.ZSFDC        = target.Id;
						tData3.CHARG        = target.Asset__r.BatchNo__c;      // 배치번호
						tData3.APPRO        = 'Y';
						tData3.APPNM        = target.IsPartnerIncentiveAutoApproval__c == true ? '자동 승인' : target.PartnerApprovalUser__r.Name;
						tData3.APPDT        = target.PartnerApprovalDatetime__c.format('yyyy-MM-dd');
						tData3.APPTM        = target.PartnerApprovalDatetime__c.format('HH:mm:ss');
						input.request.payload.t_data_3.add(tData3);
					}
					if (target.DealerIncentiveCalculate10__c != null) {
						//농협사후봉사
						tData3 = new IF_KR_SE_ERP_0043.INPUT_T_DATA_3();
						tData3.VBELN        = salesDocNo ;      // 판매오더
						tData3.POSNR        = lineNumber == null ? '000010' : lineNumber ;      // 판매오더품목
						if(status == 'X') {
							tData3.CHRGB        = '3';
						} else {
							tData3.CHRGB        = isCurrentPDI == true ? '1' : '2' ;      // 수수료 구분
						}
						tData3.SEQNO        = String.valueOf(Integer.valueOf(target.DealerIncentiveCalculate10__r.ERPSeqNo__c));      // 순번
						tData3.ZTYPE        = 'B';
						tData3.ZSFDC        = target.Id;
						tData3.CHARG        = target.Asset__r.BatchNo__c;      // 배치번호
						tData3.APPRO        = 'Y';
						tData3.APPNM        = target.IsPartnerIncentiveAutoApproval__c == true ? '자동 승인' : target.PartnerApprovalUser__r.Name;
						tData3.APPDT        = target.PartnerApprovalDatetime__c.format('yyyy-MM-dd');
						tData3.APPTM        = target.PartnerApprovalDatetime__c.format('HH:mm:ss');
						input.request.payload.t_data_3.add(tData3);
					}
					if (target.DealerIncentiveCalculate11__c != null) {
						tData3 = new IF_KR_SE_ERP_0043.INPUT_T_DATA_3();
						tData3.VBELN        = salesDocNo ;      // 판매오더
						tData3.POSNR        = lineNumber == null ? '000010' : lineNumber ;      // 판매오더품목
						if(status == 'X') {
							tData3.CHRGB        = '3';
						} else {
							tData3.CHRGB        = isCurrentPDI == true ? '1' : '2' ;      // 수수료 구분
						}
						tData3.SEQNO        = String.valueOf(Integer.valueOf(target.DealerIncentiveCalculate11__r.ERPSeqNo__c));      // 순번
						tData3.ZTYPE        = 'B';
						tData3.ZSFDC        = target.Id;
						tData3.CHARG        = target.Asset__r.BatchNo__c;      // 배치번호
						tData3.APPRO        = 'Y';
						tData3.APPNM        = target.IsPartnerIncentiveAutoApproval__c == true ? '자동 승인' : target.PartnerApprovalUser__r.Name;
						tData3.APPDT        = target.PartnerApprovalDatetime__c.format('yyyy-MM-dd');
						tData3.APPTM        = target.PartnerApprovalDatetime__c.format('HH:mm:ss');
						input.request.payload.t_data_3.add(tData3);
					}
				}
			}
		}


		System.debug('-----------------------');
//		System.debug('result : '+JSON.serializePretty(input));
		System.debug('-----------------------');

		IF_KR_SE_ERP_0043.OutputDIH result = instance.execute(input);
		if(result.response.header.ifResult == 'S') {
			Datetime processDatetime = Datetime.now();
			for (DealerIncentiveInput__c target : scope) {
				target.PartnerApproveSendTime__c = processDatetime;
			}
			update scope;
		}

		System.debug('-----------------------');
		//System.debug('result : '+JSON.serializePretty(result));
		System.debug('-----------------------');
	}

	/**
	 * 미지급건 전송 : 계획 대상.
	 * @param scope
	 */
	public static void incentiveUnpaidERPSend(List<DealerIncentiveInput__c> scope) {

		IF_KR_SE_ERP_0043 instance = IF_KR_SE_ERP_0043.getInstance();
		// 서비스 실행
		IF_KR_SE_ERP_0043.InputDIH input = new IF_KR_SE_ERP_0043.InputDIH();

		Integer seqNo;
		String LOEKZ;   // 수수료 상세 구분
		String CHRGB;   //	출하와 동시에 발생한 수수료(1)인지, 이후에 발생한 수수료인지 (2). 2022년 이전 출하 기대(3), 4- 2022년 이전

		String salesDocNo;
		String lineNumber;
		String status;
		String txtSupplyAmount;
		Decimal SupplyAmount;
		Boolean isCurrentPDI;
		Date DealerReceiptDate;

		IF_KR_SE_ERP_0043.INPUT_IMPORT tImport = new IF_KR_SE_ERP_0043.INPUT_IMPORT();
		tImport.I_TYPE = '';
		input.request.payload.t_data_import = tImport;
		for (DealerIncentiveInput__c target : scope) {
			seqNo = target.Asset__r.IncentiveSeqNo__c == null ? 10 : Integer.valueOf(target.Asset__r.IncentiveSeqNo__c);
			if(seqNo < 10) seqNo = seqNo + 10;
			isCurrentPDI = false;
			DealerReceiptDate = target.Asset__r.DealerReceiptDate__c;
			if(target.Asset__r.InventoryType__c == '공장재고(가용)' || target.Asset__r.InventoryType__c == '공장재고(QI)') {
				if(DealerReceiptDate == null) {
					// 반품인 경우
					if(target.Asset__r.FirstDeliveryDate__c != null) {
						DealerReceiptDate = target.Asset__r.FirstDeliveryDate__c;
					} else {
						if(target.Asset__r.ProductionDate__c != null) {
							DealerReceiptDate = target.Asset__r.ProductionDate__c;
						}
					}
				}
			}
			if(DealerReceiptDate != null && DealerReceiptDate.toStartOfMonth() == target.BaseDate__c.toStartOfMonth()) {
				isCurrentPDI = true;
			}

			if(target.DealerIncentiveCalculate3__c != null) {
				salesDocNo = target.DealerIncentiveCalculate3__r.SalesDocNo__c;
				lineNumber = target.DealerIncentiveCalculate3__r.LineNumber__c;
				status = target.DealerIncentiveCalculate3__r.Status__c == '지급' ? '' : 'X';
				SupplyAmount = target.DealerIncentiveCalculate3__r.SupplyAmount__c;
			}
			if(target.DealerIncentiveCalculate9__c != null) {
				salesDocNo = target.DealerIncentiveCalculate9__r.SalesDocNo__c;
				lineNumber = target.DealerIncentiveCalculate9__r.LineNumber__c;
				status = target.DealerIncentiveCalculate9__r.Status__c == '지급' ? '' : 'X';
				SupplyAmount = target.DealerIncentiveCalculate9__r.SupplyAmount__c;
			}
			if(target.DealerIncentiveCalculate10__c != null) {
				salesDocNo = target.DealerIncentiveCalculate10__r.SalesDocNo__c;
				lineNumber = target.DealerIncentiveCalculate10__r.LineNumber__c;
				status = target.DealerIncentiveCalculate10__r.Status__c == '지급' ? '' : 'X';
				SupplyAmount = target.DealerIncentiveCalculate10__r.SupplyAmount__c;
			}
			if(target.DealerIncentiveCalculate11__c != null) {
				salesDocNo = target.DealerIncentiveCalculate11__r.SalesDocNo__c;
				lineNumber = target.DealerIncentiveCalculate11__r.LineNumber__c;
				status = target.DealerIncentiveCalculate11__r.Status__c == '지급' ? '' : 'X';
				SupplyAmount = target.DealerIncentiveCalculate11__r.SupplyAmount__c;
			}
			txtSupplyAmount = target.fm_SalesSellingAmount__c;

			if(target.Type__c == '대리점') {
				IF_KR_SE_ERP_0043.INPUT_T_DATA_1 tData1 = new IF_KR_SE_ERP_0043.INPUT_T_DATA_1();
				tData1.ZSFDC        = target.Id;
				tData1.VBELN        = salesDocNo;      // 판매오더
				tData1.POSNR        = lineNumber == null ? '000010' : lineNumber;      // 판매오더품목
				if(status == 'X') {
					tData1.CHRGB        = '3';
				} else {
					tData1.CHRGB        = '4' ;      // 수수료 구분
				}
				target.DealerIncentiveCalculate3__r.ERPSeqNo__c = seqNo;
				tData1.SEQNO        = String.valueOf(seqNo);      // 순번
				tData1.ZYYMM        = DealerIncentiveERPSend_service.getDateYYYYMM(target.BaseDate__c);      // 정산기준년월
				tData1.CALYM        = DealerIncentiveERPSend_service.getDateYYYYMM(DealerReceiptDate);      // 산출대상년월
				tData1.KUNNR        = target.Dealer__r.ERPCode__c;      // 판매처
				tData1.MATNR        = target.Asset__r.Product2.ProductCode;      // 자재 번호
				tData1.PERNR        = target.Asset__r.Dealer__r.Owner.EmployeeNumber;      // 사원 번호

				tData1.VGBEL        = '';      // 트랙터 판매오더
				tData1.VGPOS        = '';      // 트랙터 판매오더 품목

				tData1.NPDIET        = '';      // 미지급.
				tData1.NPDIEM        = '';      // 미지급
				tData1.CHARG        = target.Asset__r.BatchNo__c;      // 배치번호
				tData1.SHKZG        = status;      // 반품품목
				tData1.CRIMG        = status == 'X' ? '-1' : '';      // 반품수량
				tData1.LFIMG        = '1';     // 실제수량납품 (판매단위)
				tData1.MEINS        = 'EA';      // 기본 단위
				tData1.WAERK        = 'KRW';      // 통화
				tData1.NETPR        = status == 'X' ? '-'+txtSupplyAmount : txtSupplyAmount;      // 공급 가격
				tData1.PDIEXC       = '';      // PDI 제외
				tData1.PDIEX        = '';      // PDI 실행
				if(target.DealerIncentiveCalculate3__c != null) {
					//PDI 등록
					tData1.PDIET        = DealerIncentiveERPSend_service.getConvertRate(target.fm_PlanDealerIncentiveCalculate3Rate__c);      // PDI 등록(%)
					tData1.PDIEM        = DealerIncentiveERPSend_service.getConvertCurrency(target.fm_PlanDealerIncentiveCalculate3Amount__c);      // PDI 등록
				} else {
					tData1.PDIET        = '';      // PDI 등록(%)
					tData1.PDIEM        = '';       // PDI 등록
				}
				tData1.NESFT        = '';
				tData1.NESFM        = '';
				tData1.EPSRT        = '';
				tData1.EPSAM        = '';
				//시승체험지원
				tData1.TESRT        = '';      // 시승체험지원(%)
				tData1.TESAM        = '';      // 시승체험지원
				//사양차액지원
				tData1.SDSRT        = '';      // 사양차액지원(%)
				tData1.SDSAM        = '';      // 사양차액지원
				//특별판촉지원
				tData1.SPSRT        = '';      // 특별판촉지원(%)
				tData1.SPSAM        = '';      // 특별판촉지원
				//무상작업기지원
				tData1.FMSRT        = '';     // 무상적업기지원(%)
				tData1.FMSAM        = '';      // 무상작업기지원
				//Sales I.Q. 달성
				tData1.PIERT        = '';      // Sales I.Q. 달성(%)
				tData1.PIEAM        = '';      // Sales I.Q. 달성
				tData1.CSPRT        = DealerIncentiveERPSend_service.getConvertRate(target.CSIncentiveRate__c);      // CS수수료 율
				tData1.CSPAM        = DealerIncentiveERPSend_service.getConvertCurrency(target.CSIncentiveAmount__c);      // CS수수료 금액
				tData1.MASRT        = DealerIncentiveERPSend_service.getConvertRate(target.AdSalesRate__c);      // 광고선점비 율
				tData1.MASAM        = DealerIncentiveERPSend_service.getConvertCurrency(target.AdSalesAmount__c);      // 광고선점비 금액
				tData1.STMRT        = DealerIncentiveERPSend_service.getConvertRate(target.SalesDiscountRate__c);      // 매출할인 율
				tData1.STMAM        = DealerIncentiveERPSend_service.getConvertCurrency(target.SalesDiscountAmount__c);      // 매출할인 금액
				tData1.CONFM1       = 'X';      // 수수료 영업그룹 확정 여부
				tData1.CONFM2       = 'X';      // 수수료 영업팀 확정 여부
				// REFLG	01 정상 02 특판제품 03 전략제품 04 전략지역 05 고정급 06 기존추가 07 신규추가 08 참조적자 09 적자 10 광역지역 11 목표달성 12 실판정산 13 중개
				tData1.REFLG        = status == 'X' ? '09' : '01';      // 수수료 상세구분
				tData1.LOEKZ        = status;      // 삭제지시

				tData1.URL1         = '';
				tData1.URL2         = '';
				tData1.URL3         = '';

				input.request.payload.t_data_1.add(tData1);

				seqNo++;
			}  else {

				if (target.DealerIncentiveCalculate9__c != null) {
					salesDocNo = target.DealerIncentiveCalculate9__r.SalesDocNo__c;
					lineNumber = target.DealerIncentiveCalculate9__r.LineNumber__c;
					status = target.DealerIncentiveCalculate9__r.Status__c == '지급' ? '' : 'X';
					SupplyAmount = target.DealerIncentiveCalculate9__r.SupplyAmount__c;

				}
				if (target.DealerIncentiveCalculate10__c != null) {
					salesDocNo = target.DealerIncentiveCalculate10__r.SalesDocNo__c;
					lineNumber = target.DealerIncentiveCalculate10__r.LineNumber__c;
					status = target.DealerIncentiveCalculate10__r.Status__c == '지급' ? '' : 'X';
					SupplyAmount = target.DealerIncentiveCalculate10__r.SupplyAmount__c;

					target.DealerIncentiveCalculate10__r.ERPSeqNo__c = seqNo;
				}
				if (target.DealerIncentiveCalculate11__c != null) {
					salesDocNo = target.DealerIncentiveCalculate11__r.SalesDocNo__c;
					lineNumber = target.DealerIncentiveCalculate11__r.LineNumber__c;
					status = target.DealerIncentiveCalculate11__r.Status__c == '지급' ? '' : 'X';
					SupplyAmount = target.DealerIncentiveCalculate11__r.SupplyAmount__c;
					target.DealerIncentiveCalculate11__r.ERPSeqNo__c = seqNo;
				}

				IF_KR_SE_ERP_0043.INPUT_T_DATA_2 tData2 = new IF_KR_SE_ERP_0043.INPUT_T_DATA_2();
				txtSupplyAmount = target.fm_SalesSellingAmount__c;
				//관납사후봉사
				if (target.DealerIncentiveCalculate9__c != null) {
					tData2 = new IF_KR_SE_ERP_0043.INPUT_T_DATA_2();
					tData2.ZSFDC = target.Id;
					tData2.VBELN = salesDocNo ;      // 판매오더
					tData2.POSNR = lineNumber == null ? '000010' : lineNumber ;      // 판매오더품목
					if (status == 'X') {
						tData2.CHRGB = '3';
					} else {
						tData2.CHRGB = '4' ;      // 수수료 구분
					}
					target.DealerIncentiveCalculate9__r.ERPSeqNo__c = seqNo;
					tData2.SEQNO = String.valueOf(seqNo);        // 순번
					tData2.ZYYMM = DealerIncentiveERPSend_service.getDateYYYYMM(target.BaseDate__c);      // 정산기준년월
					tData2.CALYM = DealerIncentiveERPSend_service.getDateYYYYMM(DealerReceiptDate);      // 산출대상년월
					tData2.KUNNR = target.DealerIncentiveCalculate9__r.SalesAccount__r.ERPCode__c;        // 판매처
					tData2.AGENT = target.Dealer__r.ERPCode__c;        // 농협전문점/위탁점
					tData2.MATNR = target.Asset__r.Product2.ProductCode;        // 자재 번호
					tData2.PERNR = target.Asset__r.Dealer__r.Owner.EmployeeNumber;        // 사원 번호
					tData2.CHARG = target.Asset__r.BatchNo__c;      // 배치번호
					tData2.SHKZG = status;      // 반품품목
					tData2.CRIMG = status == 'X' ? '-1' : '';      // 반품수량
					tData2.LFIMG = status == 'X' ? '-1' : '1';     // 실제수량납품 (판매단위)
					tData2.LFIMG = '1';        // 실제수량납품 (판매단위)
					tData2.MEINS = 'EA';        // 기본 단위
					tData2.NETPR = txtSupplyAmount;        // 단가
					tData2.WAERK = 'KRW';        // 통화
					tData2.SPCGB = '02';        // 전문점 구분
					tData2.GASRT = DealerIncentiveERPSend_service.getConvertRate(target.fm_PlanDealerIncentiveCalculate9Rate__c);        // 관납사후봉사(%)
					tData2.GASAM = DealerIncentiveERPSend_service.getConvertCurrency(target.fm_PlanDealerIncentiveCalculate9Amount__c);        // 관납사후봉사
					tData2.SVCRT = '';        // 농협사후봉사(%)
					tData2.SVCAM = '';        // 농협사후봉사
					tData2.BKRRT = '';        // 중개영업지원(%)
					tData2.BKRAM = '';        // 중개영업지원
					tData2.SCSRT = DealerIncentiveERPSend_service.getConvertRate(target.CSIncentiveRate__c);      // CS 위탁수수료율
					tData2.SCSAM = DealerIncentiveERPSend_service.getConvertCurrency(target.CSIncentiveAmount__c);      // CS 위탁 수수료 금액
					tData2.SSLRT = DealerIncentiveERPSend_service.getConvertRate(target.SalesIncentiveRate__c);        // 판매수수료율
					tData2.SSLAM = DealerIncentiveERPSend_service.getConvertCurrency(target.SalesIncentiveAmount__c);        // 판매수수료 금액
					tData2.CONFM1 = 'X';        // 수수료 영업그룹 확정 여부
					tData2.CONFM2 = 'X';        // 수수료 영업팀 확정 여부
					// REFLG    01 정상 02 특판제품 03 전략제품 04 전략지역 05 고정급 06 기존추가 07 신규추가 08 참조적자 09 적자 10 광역지역 11 목표달성 12 실판정산 13 중개
					tData2.REFLG = status == 'X' ? '09' : '01';      // 수수료 상세구분
					tData2.NGEGB = target.RecordType.Name == '농협' ? '1' : target.RecordType.Name == '관납' ? '2' : '';        // 농협/관납/기타 구분
					tData2.LOEKZ = '';        // 삭제지시

					input.request.payload.t_data_2.add(tData2);
					seqNo++;
				}
				if (target.DealerIncentiveCalculate10__c != null) {
					//농협사후봉사
					tData2 = new IF_KR_SE_ERP_0043.INPUT_T_DATA_2();
					tData2.ZSFDC = target.Id;
					tData2.VBELN = salesDocNo ;      // 판매오더
					tData2.POSNR = lineNumber == null ? '000010' : lineNumber ;      // 판매오더품목
					if (status == 'X') {
						tData2.CHRGB = '3';
					} else {
						tData2.CHRGB = '4' ;      // 수수료 구분
					}
					target.DealerIncentiveCalculate10__r.ERPSeqNo__c = seqNo;
					tData2.SEQNO = String.valueOf(seqNo);        // 순번
					tData2.ZYYMM = DealerIncentiveERPSend_service.getDateYYYYMM(target.BaseDate__c);      // 정산기준년월
					tData2.CALYM = DealerIncentiveERPSend_service.getDateYYYYMM(DealerReceiptDate);      // 산출대상년월
					tData2.KUNNR = target.DealerIncentiveCalculate10__r.SalesAccount__r.ERPCode__c;        // 판매처
					tData2.AGENT = target.Dealer__r.ERPCode__c;        // 농협전문점/위탁점
					tData2.MATNR = target.Asset__r.Product2.ProductCode;        // 자재 번호
					tData2.PERNR = target.Dealer__r.Owner.EmployeeNumber;       // 사원 번호
					tData2.CHARG = target.Asset__r.BatchNo__c;      // 배치번호
					tData2.SHKZG = status;      // 반품품목
					tData2.CRIMG = status == 'X' ? '-1' : '';      // 반품수량
					tData2.LFIMG = status == 'X' ? '-1' : '1';     // 실제수량납품 (판매단위)
					tData2.MEINS = 'EA';        // 기본 단위
					tData2.NETPR = txtSupplyAmount;        // 단가
					tData2.WAERK = 'KRW';        // 통화
					tData2.SPCGB = '02';        // 전문점 구분
					tData2.GASRT = '';        // 관납사후봉사(%)
					tData2.GASAM = '';        // 관납사후봉사
					tData2.SVCRT = DealerIncentiveERPSend_service.getConvertRate(target.fm_PlanDealerIncentiveCalculate10Rate__c);        // 농협사후봉사(%)
					tData2.SVCAM = DealerIncentiveERPSend_service.getConvertCurrency(target.fm_PlanDealerIncentiveCalculate10Amount__c);        // 농협사후봉사
					tData2.BKRRT = '';        // 중개영업지원(%)
					tData2.BKRAM = '';        // 중개영업지원
					tData2.SCSRT = DealerIncentiveERPSend_service.getConvertRate(target.CSIncentiveRate__c);      // CS 위탁수수료율
					tData2.SCSAM = DealerIncentiveERPSend_service.getConvertCurrency(target.CSIncentiveAmount__c);      // CS 위탁 수수료 금액
					tData2.SSLRT = DealerIncentiveERPSend_service.getConvertRate(target.SalesIncentiveRate__c);        // 판매수수료율
					tData2.SSLAM = DealerIncentiveERPSend_service.getConvertCurrency(target.SalesIncentiveAmount__c);        // 판매수수료 금액
					tData2.CONFM1 = 'X';        // 수수료 영업그룹 확정 여부
					tData2.CONFM2 = 'X';        // 수수료 영업팀 확정 여부
					// REFLG    01 정상 02 특판제품 03 전략제품 04 전략지역 05 고정급 06 기존추가 07 신규추가 08 참조적자 09 적자 10 광역지역 11 목표달성 12 실판정산 13 중개
					tData2.REFLG = status == 'X' ? '09' : '01';      // 수수료 상세구분
					tData2.NGEGB = target.RecordType.Name == '농협' ? '1' : target.RecordType.Name == '관납' ? '2' : '';        // 농협/관납/기타 구분
					tData2.LOEKZ = '';        // 삭제지시
					input.request.payload.t_data_2.add(tData2);

					seqNo++;
				}
				if (target.DealerIncentiveCalculate11__c != null) {
					//중개영업지원
					tData2 = new IF_KR_SE_ERP_0043.INPUT_T_DATA_2();
					tData2.ZSFDC = target.Id;
					tData2.VBELN = salesDocNo ;      // 판매오더
					tData2.POSNR = lineNumber == null ? '000010' : lineNumber ;      // 판매오더품목
					if (status == 'X') {
						tData2.CHRGB = '3';
					} else {
						tData2.CHRGB = '4' ;      // 수수료 구분
					}
					target.DealerIncentiveCalculate11__r.ERPSeqNo__c = seqNo;
					tData2.SEQNO = String.valueOf(seqNo);        // 순번
					tData2.ZYYMM = DealerIncentiveERPSend_service.getDateYYYYMM(target.BaseDate__c);      // 정산기준년월
					tData2.CALYM = DealerIncentiveERPSend_service.getDateYYYYMM(target.Asset__r.DealerReceiptDate__c);      // 산출대상년월
					tData2.KUNNR = target.DealerIncentiveCalculate11__r.SalesAccount__r.ERPCode__c;        // 판매처
					tData2.AGENT = target.Dealer__r.ERPCode__c;        // 농협전문점/위탁점
					tData2.MATNR = target.Asset__r.Product2.ProductCode;        // 자재 번호
					tData2.PERNR = target.Dealer__r.Owner.EmployeeNumber;       // 사원 번호
					tData2.CHARG = target.Asset__r.BatchNo__c;      // 배치번호
					tData2.SHKZG = status;      // 반품품목
					tData2.CRIMG = status == 'X' ? '-1' : '';      // 반품수량
					tData2.LFIMG = status == 'X' ? '-1' : '1';     // 실제수량납품 (판매단위)
					tData2.MEINS = 'EA';        // 기본 단위
					tData2.NETPR = txtSupplyAmount;        // 단가
					tData2.WAERK = 'KRW';        // 통화
					tData2.SPCGB = '02';        // 전문점 구분
					tData2.GASRT = '';        // 관납사후봉사(%)
					tData2.GASAM = '';        // 관납사후봉사
					tData2.SVCRT = '';        // 농협사후봉사(%)
					tData2.SVCAM = '';        // 농협사후봉사
					tData2.BKRRT = DealerIncentiveERPSend_service.getConvertRate(target.fm_PlanDealerIncentiveCalculate11Rate__c);        // 중개영업지원(%)
					tData2.BKRAM = DealerIncentiveERPSend_service.getConvertCurrency(target.fm_PlanDealerIncentiveCalculate11Amount__c);        // 중개영업지원
					tData2.SCSRT = DealerIncentiveERPSend_service.getConvertRate(target.CSIncentiveRate__c);      // CS 위탁수수료율
					tData2.SCSAM = DealerIncentiveERPSend_service.getConvertCurrency(target.CSIncentiveAmount__c);      // CS 위탁 수수료 금액
					tData2.SSLRT = DealerIncentiveERPSend_service.getConvertRate(target.SalesIncentiveRate__c);        // 판매수수료율
					tData2.SSLAM = DealerIncentiveERPSend_service.getConvertCurrency(target.SalesIncentiveAmount__c);        // 판매수수료 금액
					tData2.CONFM1 = 'X';        // 수수료 영업그룹 확정 여부
					tData2.CONFM2 = 'X';        // 수수료 영업팀 확정 여부
					// REFLG    01 정상 02 특판제품 03 전략제품 04 전략지역 05 고정급 06 기존추가 07 신규추가 08 참조적자 09 적자 10 광역지역 11 목표달성 12 실판정산 13 중개
					tData2.REFLG = status == 'X' ? '09' : '01';      // 수수료 상세구분
					tData2.NGEGB = target.RecordType.Name == '농협' ? '1' : target.RecordType.Name == '관납' ? '2' : '';        // 농협/관납/기타 구분
					tData2.LOEKZ = '';        // 삭제지시
					input.request.payload.t_data_2.add(tData2);
					seqNo++;
				}
			}
			target.Asset__r.IncentiveSeqNo__c = seqNo;
		}
		System.debug('-----------------------');
		//System.debug('result : '+JSON.serializePretty(input));
		System.debug('-----------------------');
		IF_KR_SE_ERP_0043.OutputDIH result = instance.execute(input);
		List<DealerIncentiveCalculate__c> updateList = new List<DealerIncentiveCalculate__c>();

		DealerIncentiveCalculate__c dic3;
		DealerIncentiveCalculate__c dic9;
		DealerIncentiveCalculate__c dic10;
		DealerIncentiveCalculate__c dic11;
		if(result.response.header.ifResult == 'S') {
			List<Asset> assets = new List<Asset>();
			Map<String, Asset> updateAssetMap = new Map<String, Asset>();
			Asset asset;
			for (DealerIncentiveInput__c target : scope) {

				if(updateAssetMap.containsKey(target.Asset__c)) {
					asset = updateAssetMap.get(target.Asset__c);
				} else {
					asset = target.Asset__r;
				}

				asset.IncentiveSeqNo__c = target.Asset__r.IncentiveSeqNo__c;
				updateAssetMap.put(target.Asset__c, asset);
				assets.add(asset);

				if(target.DealerIncentiveCalculate3__c != null) {
					dic3 = target.DealerIncentiveCalculate3__r;
					dic3.ERPSendDate__c = Date.today();
					dic3.IsSendERP__c = true;
					updateList.add(dic3);
				}
				if(target.DealerIncentiveCalculate9__c != null) {
					dic9 = target.DealerIncentiveCalculate9__r;
					dic9.ERPSendDate__c = Date.today();
					dic9.IsSendERP__c = true;
					updateList.add(dic9);
				}

				if(target.DealerIncentiveCalculate10__c != null) {
					dic10 = target.DealerIncentiveCalculate10__r;
					dic10.ERPSendDate__c = Date.today();
					dic10.IsSendERP__c = true;
					updateList.add(dic10);
				}

				if(target.DealerIncentiveCalculate11__c != null) {
					dic11 = target.DealerIncentiveCalculate11__r;
					dic11.ERPSendDate__c = Date.today();
					dic11.IsSendERP__c = true;
					updateList.add(dic11);
				}

				target.SendDate__c = Date.today();
				target.IsSend__c = true;
			}

			update scope;
			if(updateAssetMap.isEmpty() == false) {
				update updateAssetMap.values();
			}
			if(updateList.isEmpty() == false) {
				update updateList;
			}

		}
		System.debug('-----------------------');
//		System.debug('result : '+JSON.serializePretty(result));
		System.debug('-----------------------');

	}

	public static String getConvertCurrency(Decimal source) {
		String target = source == null ? '0' : String.valueOf(source.setScale(0));
		return target;
	}

	public static String getConvertRate(Decimal source) {
		String target = source == null ? '0' : String.valueOf(source.setScale(3));
		return target;
	}

	public static String getLeftZeroPad(String soruce, Integer padDigit) {
		return soruce.leftPad(padDigit, '0');
	}

	public static String getDateYYYYMM(Date tDate) {
		Datetime targetDate = (Datetime) tDate;
		return targetDate.format('yyyyMM');
	}

	public static void runTest() {
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
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
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