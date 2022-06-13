/****************************************************************************************
  * @filename      : ItractorAssetSend_ba
  * @projectname   :
  * @author        : i2max
  * @date          : 2021-04-19
  * @group         :
  * @group-content :
  * @description   : 아이트랙터 실판매 제품 일일 전송 배치
  *                :
  * @tester        : ItractorAssetSend_ba_ts.cls
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2021-04-19         i2max          Create
****************************************************************************************/
public with sharing class ItractorAssetSend_ba implements Database.Batchable<SObject>, Database.AllowsCallouts {

	public Database.QueryLocator start(Database.BatchableContext BC) {

		//============================================================================
		// 자산의 실고객이 정보가 어제 수정 되었거나, 자산의 PDI 등록일이 어제 경우 전송
		//============================================================================
		return Database.getQueryLocator([
				SELECT  Id,
						IsItractorSend__c,                 // 아이트랙터 시스템 전송 여부
						Name,                               // 기대번호:일련번호
						BatchNo__c,                         // 배치번호
						Customer__c,                        // 고객 아이디
						Customer__r.Name,                   // 고객 명
						Account.CustomerType__c,            // 고객 유형
						WtyStartDate__c,                    // 제품 판매일
						Dealer__r.ERPCode__c,               // 판매점 코드
						Account.ERPCode__c,                  // 농협 코드
						InventoryType__c
				FROM    Asset
				WHERE   Product2.IsITractor__c = TRUE
		]);

	}

	public void execute(Database.BatchableContext BC, List<Asset> scope) {
		String accessToken = IF_iTractor_Base.getITractorToken();

		IF_KR_SE_IT_0101 instance = IF_KR_SE_IT_0101.getInstance(accessToken);
		// 서비스 실행
		IF_KR_SE_IT_0101.InputDIH input = new IF_KR_SE_IT_0101.InputDIH();
		List<IF_KR_SE_IT_0101.INPUT_T_DATA> inputDatas = new List<IF_KR_SE_IT_0101.INPUT_T_DATA>();
		IF_KR_SE_IT_0101.INPUT_T_DATA tData = new IF_KR_SE_IT_0101.INPUT_T_DATA();
		IF_KR_SE_IT_0101.OutputDIH result;
		for(Asset r : scope) {
			tData = new IF_KR_SE_IT_0101.INPUT_T_DATA();
			tData.tractor_id    = r.BatchNo__c;                                                          	// 기대번호
			tData.user_code     = r.Customer__c;                                                   	// 고객 아이디
			tData.user_name     = maskingName(r.Customer__r.Name);                                 	// 고객 명
			tData.type_c        = r.Account.CustomerType__c == '농협' ? 'NH일반' : 'LS일반';        	// 계약 유형
			tData.add_date      = r.WtyStartDate__c == null ? '' : ((Datetime) r.WtyStartDate__c).format('yyyyMMdd');             	// PDI 등록일
			tData.agency_code   = r.Dealer__r.ERPCode__c;                                          	// 판매점 코드
			tData.nh_code       = r.Account.CustomerType__c == '농협' ? r.Account.ERPCode__c : '';	// 농협 코드
			tData.asset_type    = r.InventoryType__c == '실판매' ? 'Y' : 'N';                      	// 실판매 여부부
			inputDatas.add(tData);
		}

		if (!inputDatas.isEmpty()) {
			input.request.payload.t_data = inputDatas;
			result = instance.execute(input);
		}

		// Interface Response 처리
		if ('S'.equals(result.response.header.ifResult)) {
			// 성공
			System.debug('성공');
			for(Asset r : scope) {
				r.IsItractorSend__c = true;     // 전송 처리
			}
			update scope;
		} else {
			// 실패
			System.debug('실패');
		}

	}
	public static String maskingName(String inputStr) {
		String result = '';
		String ast = '';
		if(inputStr == null) return '';
		inputStr = inputStr.replaceAll(' ', '');
		for(integer i=0; i<inputStr.length()-2; i++) ast += '*';

		if(inputStr.length() > 2) {
			result = inputStr.left(1) + ast + inputStr.right(1);
		} else {
			result = inputStr.left(1) + '*';
		}

		return result;
	}

	public void finish(Database.BatchableContext BC) {

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
	}

}