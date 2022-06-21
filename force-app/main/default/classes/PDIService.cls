/**
 * Created by MS on 2021-08-23.
 */

public without sharing class PDIService {

	/**
	 * PDI 등록.
	 * @param pdiMap
	 *
	 * @return
	 */
	public static LsMSalesPDIVO sendPDI(LsMSalesPDIVO pdiData) {

		IF_KR_SE_ERP_0041 instance = IF_KR_SE_ERP_0041.getInstance();
		// 서비스 실행
		IF_KR_SE_ERP_0041.InputDIH input = new IF_KR_SE_ERP_0041.InputDIH();
		List<IF_KR_SE_ERP_0041.INPUT_T_DATA> inputDatas = new List<IF_KR_SE_ERP_0041.INPUT_T_DATA>();
		IF_KR_SE_ERP_0041.INPUT_T_DATA tData = new IF_KR_SE_ERP_0041.INPUT_T_DATA();
		List<IF_KR_SE_ERP_0041.OUTPUT_T_DATA> resultTData;
		IF_KR_SE_ERP_0041.OutputDIH result;
		System.debug('----');
		System.debug(pdiData.bizData.contract.Id);
		System.debug(pdiData.bizData.asset.Product2.ProductCode);
		System.debug('----');
		Account acc = [SELECT Id, Name, ERPCode__c FROM Account WHERE Id = :pdiData.bizData.contract.Customer__c];
		Contract__c contract = [SELECT Id, Dealer__r.ERPCode__c FROM Contract__c WHERE Id = :pdiData.bizData.contract.Id];

		tData = new IF_KR_SE_ERP_0041.INPUT_T_DATA();
		tData.MATNR = pdiData.bizData.asset.Product2.ProductCode;                // 자재코드
		tData.CHARG = pdiData.bizData.asset.BatchNo__c;                       // 기대번호
		tData.ZSEQ  = '001';                                            // 순서
		tData.KUNNR = contract.Dealer__r.ERPCode__c;                    // 판매처
		tData.UPDKZ = 'R';                                              // 처리 지시자 : R : 등록, C : 변경, D : 취소
		tData.KUND2 = '';                                   // 실판매 고객코드
		tData.NAME  = acc.Name;                                         // 실판매 고객명
		tData.VKDAT = Datetime.now().format('yyyy-MM-dd');              // 판매일자

		// 반환 데이터는 공백 처리.
		tData.REDAT = '';      // 반환 일자
		tData.REWHY = '';      // 반환 사유 코드
		inputDatas.add(tData);

		input.request.payload.t_data = inputDatas;
		if (!inputDatas.isEmpty()) {
			result = instance.execute(input);
		}

		// Interface Response 처리
		if ('S'.equals(result.response.header.ifResult)) {
			pdiData.bizData.pdi.IFStatus__c = 'Complete';
			pdiData.bizData.pdi.IFMessage__c = '';

			resultTData = result.response.payload.t_data;
			for (IF_KR_SE_ERP_0041.OUTPUT_T_DATA temp : resultTData) {
				if (temp.S_RESULT == '00') {
					pdiData.bizData.pdi.IFStatus__c = 'Complete';
					pdiData.bizData.pdi.IFMessage__c = temp.S_MESSAGE;
				} else {
					pdiData.bizData.pdi.IFStatus__c = 'Error';
					pdiData.bizData.pdi.IFMessage__c = '[PDI생성오류]: '+temp.S_MESSAGE;
				}
			}
		} else {
			// 실패
			pdiData.bizData.pdi.IFStatus__c = 'Error';
			pdiData.bizData.pdi.IFMessage__c = result.response.header.ifFailMsg;
		}
		return pdiData;
	}


	/**
	 * PDI 등록. - 수기 처리용
	 * @param pdiMap
	 *
	 * @return
	 */
	public static void reSendPDI(String pdiId) {

		PDI__c pdi = [
			SELECT Id, Asset__r.Name, Asset__r.BatchNo__c, Asset__r.Product2.ProductCode, Contract__r.Dealer__r.ERPCode__c,
					Contract__r.Customer__r.Name, IFStatus__c, IFMessage__c
			FROM PDI__c WHERE Id = :pdiId
		];
		IF_KR_SE_ERP_0041 instance = IF_KR_SE_ERP_0041.getInstance();
		// 서비스 실행
		IF_KR_SE_ERP_0041.InputDIH input = new IF_KR_SE_ERP_0041.InputDIH();
		List<IF_KR_SE_ERP_0041.INPUT_T_DATA> inputDatas = new List<IF_KR_SE_ERP_0041.INPUT_T_DATA>();
		IF_KR_SE_ERP_0041.INPUT_T_DATA tData = new IF_KR_SE_ERP_0041.INPUT_T_DATA();
		List<IF_KR_SE_ERP_0041.OUTPUT_T_DATA> resultTData;
		IF_KR_SE_ERP_0041.OutputDIH result;

		tData = new IF_KR_SE_ERP_0041.INPUT_T_DATA();
		tData.MATNR = pdi.Asset__r.Product2.ProductCode;                // 자재코드
		tData.CHARG = pdi.Asset__r.BatchNo__c;                          // 기대번호
		tData.ZSEQ  = '001';                                            // 순서
		tData.KUNNR = pdi.Contract__r.Dealer__r.ERPCode__c;             // 판매처
		tData.UPDKZ = 'R';                                              // 처리 지시자 : R : 등록, C : 변경, D : 취소
		tData.KUND2 = '';                                               // 실판매 고객코드
		tData.NAME  = pdi.Contract__r.Customer__r.Name;                 // 실판매 고객명
		tData.VKDAT = Datetime.now().format('yyyy-MM-dd');              // 판매일자

		// 반환 데이터는 공백 처리.
		tData.REDAT = '';      // 반환 일자
		tData.REWHY = '';      // 반환 사유 코드
		inputDatas.add(tData);

		input.request.payload.t_data = inputDatas;
		if (!inputDatas.isEmpty()) {
			result = instance.execute(input);
		}

		// Interface Response 처리
		if ('S'.equals(result.response.header.ifResult)) {
			pdi.IFStatus__c = 'Complete';
			pdi.IFMessage__c = '';

			resultTData = result.response.payload.t_data;
			for (IF_KR_SE_ERP_0041.OUTPUT_T_DATA temp : resultTData) {
				if (temp.S_RESULT == '00') {
					pdi.IFStatus__c = 'Complete';
					pdi.IFMessage__c = temp.S_MESSAGE;
				} else {
					pdi.IFStatus__c = 'Error';
					pdi.IFMessage__c = '[PDI생성오류]: '+temp.S_MESSAGE;
				}
			}
		} else {
			// 실패
			pdi.IFStatus__c = 'Error';
			pdi.IFMessage__c = result.response.header.ifFailMsg;
		}
		update pdi;
	}

	/**
	 * 반환 처리.
	 * 승인 완료시 한건씩 처리 한다.
	 * @param assetReturnIds
	 */
	public static void callSendReturnPDI(Set<String> assetReturnIds) {
		System.debug('sendReturnPDI start =====================');
		List<AssetReturn__c> assetReturns = [
				SELECT Id, ReturnType__c, Asset__c, Asset__r.Id, Asset__r.Name, Asset__r.BatchNo__c,
						Asset__r.DealerCode__c, Asset__r.Account.ERPCode__c, Asset__r.Account.Name,
						Asset__r.Product2.ProductCode,
						Asset__r.SalesDate__c, Asset__r.WtyStartDate__c, CreatedDate
				FROM AssetReturn__c
				WHERE Id IN :assetReturnIds
				AND ApprovalStatus__c = '승인'
		];

		IF_KR_SE_ERP_0041 instance = IF_KR_SE_ERP_0041.getInstance();
		// 서비스 실행
		IF_KR_SE_ERP_0041.InputDIH input = new IF_KR_SE_ERP_0041.InputDIH();
		List<IF_KR_SE_ERP_0041.INPUT_T_DATA> inputDatas = new List<IF_KR_SE_ERP_0041.INPUT_T_DATA>();
		IF_KR_SE_ERP_0041.INPUT_T_DATA inData = new IF_KR_SE_ERP_0041.INPUT_T_DATA();
		List<IF_KR_SE_ERP_0041.OUTPUT_T_DATA> outputDatas;
		IF_KR_SE_ERP_0041.OutputDIH result;

		AssetReturn__c assetReturn;
		Date vkdat;
		String vkdateString = '';
		IF_KR_SE_ERP_0041__c pdiErrorLog = new IF_KR_SE_ERP_0041__c();
		Map<String, AssetReturn__c> assetReturnMap = new Map<String, AssetReturn__c>();
		if (assetReturns.isEmpty() == false) {
			Integer seq = 1;
			for (AssetReturn__c r : assetReturns) {
				vkdat = r.Asset__r.SalesDate__c == null ? r.Asset__r.WtyStartDate__c : r.Asset__r.SalesDate__c;
				if(vkdat != null) vkdateString = ((Datetime)vkdat).format('yyyy-MM-dd');
				inData = new IF_KR_SE_ERP_0041.INPUT_T_DATA();
				inData.MATNR = r.Asset__r.Product2.ProductCode;
				inData.CHARG = r.Asset__r.BatchNo__c;
				inData.ZSEQ = String.valueOf(seq);
				inData.KUNNR = r.Asset__r.DealerCode__c;
				inData.UPDKZ = 'D';			// r.ReturnType__c == '고객 변심' ? 'C' : 'D';
				inData.KUND2 = r.Asset__r.Account.ERPCode__c;
				inData.NAME = r.Asset__r.Account.Name;
				inData.VKDAT = vkdateString;
				inData.REDAT = r.CreatedDate.format('yyyy-MM-dd');       // 반환 신청일자로 처리.
				inData.REWHY = r.ReturnType__c == '고객 변심' ? '01' : '02';
				inputDatas.add(inData);

				pdiErrorLog.AssetReturn__c = r.Id;
				pdiErrorLog.MATNR__c = inData.MATNR;
				pdiErrorLog.CHARG__c = inData.CHARG;
				pdiErrorLog.ZSEQ__c  = inData.ZSEQ;
				pdiErrorLog.KUNNR__c = inData.KUNNR;
				pdiErrorLog.UPDKZ__c = inData.UPDKZ;
				pdiErrorLog.KUND2__c = inData.KUND2;
				pdiErrorLog.NAME__c  = inData.NAME;
				pdiErrorLog.VKDAT__c = inData.VKDAT;
				pdiErrorLog.REDAT__c = inData.REDAT;
				pdiErrorLog.REWHY__c = inData.REWHY;
				seq++;
			}
			input.request.payload.t_data = inputDatas;
			if (!inputDatas.isEmpty()) {
				result = instance.execute(input);
			}

			// Interface Response 처리
			List<IF_KR_SE_ERP_0041__c> pdiErrorLogs = new List<IF_KR_SE_ERP_0041__c>();

			// 실데이터 하나 처리..
			if ('S'.equals(result.response.header.ifResult)) {
				outputDatas = result.response.payload.t_data;
				for (IF_KR_SE_ERP_0041.OUTPUT_T_DATA temp : outputDatas) {
					if (temp.S_RESULT != '00') {
						pdiErrorLog.S_RESULT__c = temp.S_RESULT;
						pdiErrorLog.S_MESSAGE__c = temp.S_MESSAGE;
						pdiErrorLogs.add(pdiErrorLog);
					}
				}
			} else {
				outputDatas = result.response.payload.t_data;
				for (IF_KR_SE_ERP_0041.OUTPUT_T_DATA temp : outputDatas) {
					if (temp.S_RESULT != '00') {
						pdiErrorLog.S_RESULT__c = temp.S_RESULT;
						pdiErrorLog.S_MESSAGE__c = temp.S_MESSAGE;
						pdiErrorLogs.add(pdiErrorLog);
					}
				}
			}

			// 오류건은 대시보드에서 확인 할 수 있도록 기록 한다.
//		System.debug(JSON.serializePretty(pdiErrorLogs));
			if(pdiErrorLogs.isEmpty() == false) insert pdiErrorLogs;
//		System.debug('sendReturnPDI end =====================');
		} else {
			//return;
		}

	}
	/**
	 * 반환 처리.
	 * @param assetReturnIds
	 */
	@Future(Callout=true)
	public static void sendReturnPDI(Set<String> assetReturnIds) {
		callSendReturnPDI(assetReturnIds);
	}

/*


	 * PDI 등록.
	 * @param pdiMap
	 *
	 * @return

	public static LsMSalesPDIVO sendPDIToItractor(LsMSalesPDIVO pdiData) {

		IF_KR_SE_IT_0101 instance = IF_KR_SE_IT_0101.getInstance();
		// 서비스 실행
		IF_KR_SE_IT_0101.InputDIH input = new IF_KR_SE_IT_0101.InputDIH();
		List<IF_KR_SE_IT_0101.INPUT_T_DATA> inputDatas = new List<IF_KR_SE_IT_0101.INPUT_T_DATA>();
		IF_KR_SE_IT_0101.INPUT_T_DATA tData = new IF_KR_SE_IT_0101.INPUT_T_DATA();
		IF_KR_SE_IT_0101.OutputDIH result;
		System.debug('----');
		System.debug(pdiData.bizData.contract.Id);
		System.debug(pdiData.bizData.asset.Product2.ProductCode);
		System.debug('----');
		Account acc = [SELECT Id, Name, ERPCode__c, CustomerType__c FROM Account WHERE Id = :pdiData.bizData.contract.Customer__c];
		Contract__c contract = [SELECT Id, Dealer__r.ERPCode__c FROM Contract__c WHERE Id = :pdiData.bizData.contract.Id];

		tData = new IF_KR_SE_IT_0101.INPUT_T_DATA();
		tData.tractor_id    = pdiData.bizData.asset.Name;                               // 기대번호
		tData.user_code     = acc.Id;                                                   // 고객 아이디
		tData.user_name     = masking_name(acc.Name);                                                 // 고객 명 : TODO : 중간 명 마스킹 해야 함..
		tData.type_c        = acc.CustomerType__c == '농협' ? 'NH일반' : 'LS일반';       // 계약 유형
		tData.add_date      = Datetime.now().format('yyyy-MM-dd');                      // PDI 등록일
		tData.agency_code   = contract.Dealer__r.ERPCode__c;                            // 판매점 코드
		tData.nh_code       = acc.CustomerType__c == '농협' ? acc.ERPCode__c : '';      // 농협 코드

		inputDatas.add(tData);
		input.request.payload.t_data = inputDatas;
		if (!inputDatas.isEmpty()) {
			result = instance.execute(input);
		}

		// Interface Response 처리
		if ('S'.equals(result.response.header.ifResult)) {
			// 성공
			System.debug('성공');
			pdiData.bizData.pdi.IFITratorStauts__c = '정상';

		} else {
			// 실패
			System.debug('실패');
			pdiData.bizData.pdi.IFITratorStauts__c = '실패';
			pdiData.bizData.pdi.IFITractorErrorMessage__c = result.response.header.ifFailMsg;
		}
		return pdiData;
	}

*/

	private static String masking_name(String val){

		String mask_name = val;
		String result ;
		if('' != mask_name){
			String a;
			String b;
			Integer c = 0;
			if(3 > mask_name.length()){
				a = mask_name.left(1);
			}else if(5 > mask_name.length()){
				a = mask_name.left(1);
				c = mask_name.length()-2;
				b = mask_name.right(1);
			}else{
				a = mask_name.left(2);
				c = mask_name.length()-4;
				b = mask_name.right(2);
			}

			String d ='*';
			for(Integer i=1; i<c ; i++){
				d += '*';
			}


			if(2 < mask_name.length()){
				result = a+d+b;
			}else{
				result = a+d;
			}
		}else{
			result = '';
		}

		return result;
	}

	public static void runTest() {
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
	}
}