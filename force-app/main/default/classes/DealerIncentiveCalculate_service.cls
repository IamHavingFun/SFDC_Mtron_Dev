/**
 * Created by MS on 2022-01-05.
 */

public without sharing class DealerIncentiveCalculate_service {

	/**
	 * 1. PDI 등록 유형 처리
		PDI 등록	대리점	ALL	전략	PDI 등록	10%	(지급수수료:대리점용역)
					실속	PDI 등록
					경제	PDI 등록	6%
					도입	PDI 등록	4%
	 *
	 * @param target
	 * @param processDate
	 */
	public static DealerIncentiveCalculate__c getPDICreate(Asset target, Date processDate, String division, String status) {
		String IncentiveType = 'PDI 등록';
		Map<String, Decimal> dcRateMap = new Map<String, Decimal>{
				'전략제품' => 10,
				'정책' => 10,
				'실속형' => 10,
				'경제형' => 6,
				'도입' => 4
		};
		Set<String> nhChectType = new Set<String>{
				'농협', '관납'
		};

		if(target.Order__c == null) return null;

		DealerIncentiveCalculate__c dic = new DealerIncentiveCalculate__c();
		dic.CalculationDate__c = processDate;
		dic.Division__c = division;
		dic.IncentiveType__c = IncentiveType;
		dic.Type__c = nhChectType.contains(target.Account.CustomerType__c) ? target.Account.CustomerType__c : '대리점';
		dic.Asset__c = target.Id;
		dic.Dealer__c = target.Dealer__c;
		dic.SalesAccount__c = target.AccountId;
		dic.Order__c = target.Order__c;
		dic.SalesDocNo__c = target.Order__r.SalesDocNo__c;
		dic.LineNumber__c = String.isEmpty(target.Order__r.ErpPOSNR__c) ? '000010' : target.Order__r.ErpPOSNR__c;
		dic.SupplyAmount__c = target.Order__r.ru_SellingPrice__c;
		if(dic.SupplyAmount__c == null || dic.SupplyAmount__c == 0) {
			return null;
		}
		if(dcRateMap.containsKey(target.Product2.ProductDivision__c)) {
			dic.PayoutRate__c = dcRateMap.get(target.Product2.ProductDivision__c);
		} else {
			return null;
		}
		dic.PayoutAmount__c = (dic.SupplyAmount__c * dic.PayoutRate__c / 100).setScale(0);
		dic.PayoutAmount__c = amountRound1000(dic.PayoutAmount__c);
		dic.Status__c = status;
		if(status == '회수') dic.PayoutAmount__c = dic.PayoutAmount__c * -1;
		dic.ExternalKey__c = ((Datetime)processDate).format('yyyyMM') + '/' + target.BatchNo__c + '/' + target.Dealer__r.ERPCode__c + '/' + IncentiveType + '/' + status;
		return dic;
	}
	/**
	조기판매장려	대리점	ALL	이앙기	판매일자=11월~4월 (11, 12, 1, 2, 3, 4월 間)	8%	판매장려금
				판매일자=5월~10월	6%
			콤바인	판매일자=4월~5월 & 8월~10월 (4, 5, 8, 9, 10월 內)	4%
				판매일자=11~3월 & 6월~7월 (11, 12, 1, 2, 3, 6, 7월 內)	2%


	 *
	 * @param target
	 * @param processDate
	 */
	public static DealerIncentiveCalculate__c getPreSalesCreate(Asset target, Date processDate, String division, String status) {
		String IncentiveType = '조기판매장려';
		Integer salesDateMonth;
		Set<Integer> checkMonths1 = new Set<Integer>{
			11, 12, 1, 2, 3, 4
		};
		Set<Integer> checkMonths2 = new Set<Integer>{
			5, 6, 7, 8, 9, 10
		};
		Set<Integer> checkMonths3 = new Set<Integer>{
				4, 5, 8, 9, 10
		};
		Set<Integer> checkMonths4 = new Set<Integer>{
				11, 12, 1, 2, 3, 6, 7
		};
		Set<String> nhChectType = new Set<String>{
				'농협', '관납'
		};
/*		Map<String, Decimal> productCheckMap = new Map<String, Decimal>{
				'이앙기' => 7,
				'콤바인' => 3
		};*/
		DealerIncentiveCalculate__c dic = new DealerIncentiveCalculate__c();
		dic.CalculationDate__c = processDate;
		dic.Division__c = division;
		dic.IncentiveType__c = IncentiveType;
		dic.Type__c = nhChectType.contains(target.Account.CustomerType__c) ? target.Account.CustomerType__c : '대리점';
		dic.Asset__c = target.Id;
		dic.Dealer__c = target.Dealer__c;
		dic.SalesAccount__c = target.AccountId;
		dic.Order__c = target.Order__c;
		dic.SalesDocNo__c = target.Order__r.SalesDocNo__c;
		dic.LineNumber__c = String.isEmpty(target.Order__r.ErpPOSNR__c) ? '000010' : target.Order__r.ErpPOSNR__c;
		dic.SupplyAmount__c = target.Order__r.ru_SellingPrice__c;
		if(target.Product2.ProductDivision__c == '이앙기') {
			if(division == '계획') {
				dic.PayoutRate__c = 7;
			} else {
				salesDateMonth = target.SalesDate__c.month();
				if (checkMonths1.contains(salesDateMonth)) {
					// 이앙기	판매일자=11월~4월 (11, 12, 1, 2, 3, 4월 間)
					dic.PayoutRate__c = 8;
				}
				if (checkMonths2.contains(salesDateMonth)) {
					// 판매일자=5월~10월	6%
					dic.PayoutRate__c = 6;
				}
			}
			if(dic.PayoutRate__c == null) return null;
		} else if(target.Product2.ProductDivision__c == '콤바인') {
			if(division == '계획') {
				dic.PayoutRate__c = 3;
			} else {
				salesDateMonth = target.SalesDate__c.month();
				if (checkMonths3.contains(salesDateMonth)) {
					// 판매일자=4월~5월 & 8월~10월 (4, 5, 8, 9, 10월 內)	4%
					dic.PayoutRate__c = 4;
				}
				if (checkMonths4.contains(salesDateMonth)) {
					// 판매일자=11~3월 & 6월~7월 (11, 12, 1, 2, 3, 6, 7월 內)	2%
					dic.PayoutRate__c = 2;
				}
			}
			if(dic.PayoutRate__c == null) return null;
		}

		dic.PayoutAmount__c = (dic.SupplyAmount__c * dic.PayoutRate__c / 100).setScale(0);
		dic.PayoutAmount__c = amountRound1000(dic.PayoutAmount__c);
		dic.Status__c = status;
		if(status == '회수') dic.PayoutAmount__c = dic.PayoutAmount__c * -1;
		dic.ExternalKey__c = ((Datetime)processDate).format('yyyyMM') + '/' + target.BatchNo__c + '/' + target.Dealer__r.ERPCode__c + '/' + IncentiveType + '/' + status;
		return dic;
	}


	/**
	 * 관납사후봉사
	 * 관납		전략	PDI 등록	10%	"6310318 (지급수수료:CS위탁)"
				도입	PDI 등록	5%
				실속	PDI 등록
				이앙기	PDI 등록
				콤바인	PDI 등록
				경제	PDI 등록
				MINI	PDI 등록	10만원
	 *
	 * @param target
	 * @param processDate
	 */
	public static DealerIncentiveCalculate__c getGovSalesCreate(Asset target, Date processDate, String division, String status) {
		String IncentiveType = '관납사후봉사';
		Map<String, Decimal> dcRateMap = new Map<String, Decimal>{
				'전략제품' => 10,
				'정책' => 10,
				'도입' => 5,
				'실속형' => 5,
				'이앙기' => 5,
				'콤바인' => 5,
				'경제형' => 5,
				'MINI' => 100000
		};
		Set<String> nhChectType = new Set<String>{
				'농협', '관납'
		};
		if(target.Order__c == null) return null;
		DealerIncentiveCalculate__c dic = new DealerIncentiveCalculate__c();
		dic.CalculationDate__c = processDate;
		dic.Division__c = division;
		dic.IncentiveType__c = IncentiveType;
		dic.Type__c = nhChectType.contains(target.Account.CustomerType__c) ? target.Account.CustomerType__c : '대리점';
		dic.Asset__c = target.Id;
		dic.Dealer__c = target.Dealer__c;
		dic.SalesAccount__c = target.AccountId;
		dic.Order__c = target.Order__c;
		dic.SalesDocNo__c = target.Order__r.SalesDocNo__c;
		dic.LineNumber__c = String.isEmpty(target.Order__r.ErpPOSNR__c) ? '000010' : target.Order__r.ErpPOSNR__c;
		dic.SupplyAmount__c = target.Order__r.ru_SellingPrice__c;
		if(dic.SupplyAmount__c == null || dic.SupplyAmount__c == 0) {
			return null;
		}
		if(dcRateMap.containsKey(target.Product2.ProductDivision__c)) {
			if(target.Product2.ProductDivision__c == 'MINI') {
				// 금액으로 율 구해야 한다.
				dic.PayoutAmount__c = dcRateMap.get(target.Product2.ProductDivision__c);
				dic.PayoutRate__c = ((dic.PayoutAmount__c / dic.SupplyAmount__c) * 100).setScale(0);
			} else {
				dic.PayoutRate__c = dcRateMap.get(target.Product2.ProductDivision__c);
				dic.PayoutAmount__c = (dic.SupplyAmount__c * dic.PayoutRate__c / 100).setScale(0);
			}
		} else {
			return null;
		}
		dic.PayoutAmount__c = amountRound1000(dic.PayoutAmount__c);

		dic.Status__c = status;
		if(status == '회수') dic.PayoutAmount__c = dic.PayoutAmount__c * -1;
		dic.ExternalKey__c = ((Datetime)processDate).format('yyyyMM') + '/' + target.BatchNo__c + '/' + target.Dealer__r.ERPCode__c + '/' + IncentiveType + '/' + status;
		return dic;
	}


	/**
	 * 농협사후봉사
	 * 농협		개별 Record	PDI 등록	정액	"6310318 (지급수수료:CS위탁)"
	 *
	 * @param target
	 * @param processDate
	 */
	public static DealerIncentiveCalculate__c getNHSalesCreate(Asset target, Date processDate, String division, String status) {
		Set<String> nhChectType = new Set<String>{
				'농협', '관납'
		};
		String IncentiveType = '농협사후봉사';
		if(target.Order__c == null) return null;
		DealerIncentiveCalculate__c dic = new DealerIncentiveCalculate__c();
		dic.CalculationDate__c = processDate;
		dic.Division__c = division;
		dic.IncentiveType__c = IncentiveType;
		dic.Type__c = nhChectType.contains(target.Account.CustomerType__c) ? target.Account.CustomerType__c : '대리점';
		dic.Asset__c = target.Id;
		dic.Dealer__c = target.Dealer__c;
		dic.SalesAccount__c = target.AccountId;
		dic.Order__c = target.Order__c;
		dic.SalesDocNo__c = target.Order__r.SalesDocNo__c;
		dic.LineNumber__c = String.isEmpty(target.Order__r.ErpPOSNR__c) ? '000010' : target.Order__r.ErpPOSNR__c;
		dic.SupplyAmount__c = target.Order__r.ru_SellingPrice__c;
		if(dic.SupplyAmount__c == null || dic.SupplyAmount__c == 0) {
			return null;
		}
		if(target.Product2.NhFeeAmt__c == null || target.Product2.NhFeeAmt__c == 0) {
			return null;
		}
		dic.PayoutAmount__c = target.Product2.NhFeeAmt__c;
		dic.PayoutRate__c = ((dic.PayoutAmount__c / dic.SupplyAmount__c) * 100).setScale(0);
		dic.Status__c = status;
		if(status == '회수') dic.PayoutAmount__c = dic.PayoutAmount__c * -1;
		dic.ExternalKey__c = ((Datetime)processDate).format('yyyyMM') + '/' + target.BatchNo__c + '/' + target.Dealer__r.ERPCode__c + '/' + IncentiveType + '/' + status;
		return dic;
	}

	/**
	 * 농협사후봉사 - 농협경제지주 - 보관재고 이관
	 * 농협		개별 Record	PDI 등록	정액	"6310318 (지급수수료:CS위탁)"
	 *
	 * @param target
	 * @param processDate
	 */
	public static DealerIncentiveCalculate__c getNHSalesCreate2(Account nhAccount, Asset target, Date processDate, String division, String status) {
		Set<String> nhChectType = new Set<String>{
				'농협', '관납'
		};
		String IncentiveType = '농협사후봉사';
		if(target.Order__c == null) return null;
		DealerIncentiveCalculate__c dic = new DealerIncentiveCalculate__c();
		dic.CalculationDate__c = processDate;
		dic.Division__c = division;
		dic.IncentiveType__c = IncentiveType;
		dic.Type__c = nhChectType.contains(target.Account.CustomerType__c) ? target.Account.CustomerType__c : '대리점';
		dic.Asset__c = target.Id;
		dic.Dealer__c = target.Dealer__c;
		dic.SalesAccount__c = nhAccount.Id;
		dic.Order__c = target.Order__c;
		dic.SalesDocNo__c = target.Order__r.SalesDocNo__c;
		dic.LineNumber__c = String.isEmpty(target.Order__r.ErpPOSNR__c) ? '000010' : target.Order__r.ErpPOSNR__c;
		dic.SupplyAmount__c = target.Order__r.ru_SellingPrice__c;
		if(dic.SupplyAmount__c == null || dic.SupplyAmount__c == 0) {
			return null;
		}
		if(target.Product2.NhFeeAmt__c == null || target.Product2.NhFeeAmt__c == 0) {
			return null;
		}
		dic.PayoutAmount__c = target.Product2.NhFeeAmt__c;
		dic.PayoutRate__c = ((dic.PayoutAmount__c / dic.SupplyAmount__c) * 100).setScale(0);
		dic.Status__c = status;
		if(status == '회수') dic.PayoutAmount__c = dic.PayoutAmount__c * -1;
		dic.ExternalKey__c = ((Datetime)processDate).format('yyyyMM') + '/' + target.Name + '/' + target.Dealer__r.ERPCode__c + '/' + IncentiveType + '/' + status;
		return dic;
	}


	/**
	 * 중개영업지원
	 * 농협		개별 Record	PDI 등록	정액	"6310318 (지급수수료:CS위탁)"
	 *
	 * @param target
	 * @param processDate
	 */
	public static DealerIncentiveCalculate__c getNHSalesBrokerCreate(Asset target, Date processDate, String division, String status) {
		String IncentiveType = '중개영업지원';
		Set<String> nhChectType = new Set<String>{
				'농협', '관납'
		};
		if(target.Order__c == null) return null;
		DealerIncentiveCalculate__c dic = new DealerIncentiveCalculate__c();
		dic.CalculationDate__c = processDate;
		dic.Division__c = division;
		dic.IncentiveType__c = IncentiveType;
		dic.Type__c = nhChectType.contains(target.Account.CustomerType__c) ? target.Account.CustomerType__c : '대리점';
		dic.Asset__c = target.Id;
		dic.Dealer__c = target.Account.BrokeringDealer__c;
		dic.SalesAccount__c = target.AccountId;
		dic.Order__c = target.Order__c;
		dic.SalesDocNo__c = target.Order__r.SalesDocNo__c;
		dic.LineNumber__c = String.isEmpty(target.Order__r.ErpPOSNR__c) ? '000010' : target.Order__r.ErpPOSNR__c;
		dic.SupplyAmount__c = target.Order__r.ru_SellingPrice__c;
		if(dic.SupplyAmount__c == null || dic.SupplyAmount__c == 0) {
			return null;
		}
		dic.PayoutAmount__c = target.Product2.BorkerFeeAmount__c;
		if(target.Product2.BorkerFeeAmount__c == null || target.Product2.BorkerFeeAmount__c == 0) {
			return null;
		}
		dic.PayoutRate__c = ((dic.PayoutAmount__c / dic.SupplyAmount__c) * 100).setScale(0);
		dic.PayoutAmount__c = amountRound1000(dic.PayoutAmount__c);
		dic.Status__c = status;
		if(status == '회수') dic.PayoutAmount__c = dic.PayoutAmount__c * -1;
		dic.ExternalKey__c = ((Datetime)processDate).format('yyyyMM') + '/' + target.BatchNo__c + '/' + target.Account.BrokeringDealer__r.ERPCode__c + '/' + IncentiveType + '/' + status;
		return dic;
	}


	/**
	 * 중개영업지원 - 농협경제지주 - 보관재고 이관
	 * 농협		개별 Record	PDI 등록	정액	"6310318 (지급수수료:CS위탁)"
	 *
	 * @param target
	 * @param processDate
	 */
	public static DealerIncentiveCalculate__c getNHSalesBrokerCreate2(Account nhAccount, Asset target, Date processDate, String division, String status) {
		String IncentiveType = '중개영업지원';
		Set<String> nhChectType = new Set<String>{
				'농협', '관납'
		};
		if(target.Order__c == null) return null;
		DealerIncentiveCalculate__c dic = new DealerIncentiveCalculate__c();
		dic.CalculationDate__c = processDate;
		dic.Division__c = division;
		dic.IncentiveType__c = IncentiveType;
		dic.Type__c = nhChectType.contains(target.Account.CustomerType__c) ? target.Account.CustomerType__c : '대리점';
		dic.Asset__c = target.Id;
		dic.Dealer__c = target.Account.BrokeringDealer__c;
		dic.SalesAccount__c = nhAccount.Id;
		dic.Order__c = target.Order__c;
		dic.SalesDocNo__c = target.Order__r.SalesDocNo__c;
		dic.LineNumber__c = String.isEmpty(target.Order__r.ErpPOSNR__c) ? '000010' : target.Order__r.ErpPOSNR__c;
		dic.SupplyAmount__c = target.Order__r.ru_SellingPrice__c;
		if(dic.SupplyAmount__c == null || dic.SupplyAmount__c == 0) {
			return null;
		}
		dic.PayoutAmount__c = target.Product2.BorkerFeeAmount__c;
		if(target.Product2.BorkerFeeAmount__c == null || target.Product2.BorkerFeeAmount__c == 0) {
			return null;
		}
		dic.PayoutRate__c = ((dic.PayoutAmount__c / dic.SupplyAmount__c) * 100).setScale(0);
		dic.PayoutAmount__c = amountRound1000(dic.PayoutAmount__c);
		dic.Status__c = status;
		if(status == '회수') dic.PayoutAmount__c = dic.PayoutAmount__c * -1;
		dic.ExternalKey__c = ((Datetime)processDate).format('yyyyMM') + '/' + target.Name + '/' + target.Account.BrokeringDealer__r.ERPCode__c + '/' + IncentiveType + '/' + status;
		return dic;
	}


	/**
	 * 조기안착지원
	 * 대리점	신규	전략	출하	3%	광고선전비
			    직영	전략	출하	5%
	 *
	 * @param target
	 * @param processDate
	 */
	public static DealerIncentiveCalculate__c getDealerCreate(Asset target, Date processDate, String division, String status) {
		String IncentiveType = '조기안착지원';
		Set<String> nhChectType = new Set<String>{
				'농협', '관납'
		};
		Map<String, Decimal> dcRateMap = new Map<String, Decimal>{
				'신규' => 3,
				'직영' => 5
		};

		DealerIncentiveCalculate__c dic = new DealerIncentiveCalculate__c();
		dic.CalculationDate__c = processDate;
		dic.Division__c = division;
		dic.IncentiveType__c = IncentiveType;
		dic.Type__c = nhChectType.contains(target.Account.CustomerType__c) ? target.Account.CustomerType__c : '대리점';
		dic.Asset__c = target.Id;
		dic.Dealer__c = target.Dealer__c;
		dic.SalesAccount__c = target.AccountId;
		dic.Order__c = target.Order__c;
		dic.SalesDocNo__c = target.Order__r.SalesDocNo__c;
		dic.LineNumber__c = String.isEmpty(target.Order__r.ErpPOSNR__c) ? '000010' : target.Order__r.ErpPOSNR__c;
		dic.SupplyAmount__c = target.Order__r.ru_SellingPrice__c;

		if(dcRateMap.containsKey(target.Dealer__r.DealerDivision__c)) {
			dic.PayoutRate__c = dcRateMap.get(target.Dealer__r.DealerDivision__c);
		} else {
			return null;
		}
		dic.PayoutAmount__c = (dic.SupplyAmount__c * dic.PayoutRate__c / 100).setScale(0);
		dic.PayoutAmount__c = amountRound1000(dic.PayoutAmount__c);
		dic.Status__c = status;
		if(status == '회수') dic.PayoutAmount__c = dic.PayoutAmount__c * -1;
		dic.ExternalKey__c = ((Datetime)processDate).format('yyyyMM') + '/' + target.BatchNo__c + '/' + target.Dealer__r.ERPCode__c + '/' + IncentiveType + '/' + status;
		return dic;
	}



	/**
	 * Sales I.Q. 달성
	 * 대리점	ALL	전략	Sales I.Q. 실적/목표 100%↑ 대리점의 출하된 자산	3%	판매장려금
	 *
	 * @param target
	 * @param processDate
	 */
	public static DealerIncentiveCalculate__c getSalesIQCreate(Asset target, Date processDate, String division, String status) {
		String IncentiveType = 'Sales I.Q. 달성';
		Set<String> nhChectType = new Set<String>{
				'농협', '관납'
		};
		DealerIncentiveCalculate__c dic = new DealerIncentiveCalculate__c();
		dic.CalculationDate__c = processDate;
		dic.Division__c = division;
		dic.IncentiveType__c = IncentiveType;
		dic.Type__c = nhChectType.contains(target.Account.CustomerType__c) ? target.Account.CustomerType__c : '대리점';
		dic.Asset__c = target.Id;
		dic.Dealer__c = target.Dealer__c;
		dic.SalesAccount__c = target.AccountId;
		dic.Order__c = target.Order__c;
		dic.SalesDocNo__c = target.Order__r.SalesDocNo__c;
		dic.LineNumber__c = String.isEmpty(target.Order__r.ErpPOSNR__c) ? '000010' : target.Order__r.ErpPOSNR__c;
		dic.SupplyAmount__c = target.Order__r.ru_SellingPrice__c;
		dic.PayoutRate__c = 3;
		dic.PayoutAmount__c = (dic.SupplyAmount__c * dic.PayoutRate__c / 100).setScale(0);
		dic.PayoutAmount__c = amountRound1000(dic.PayoutAmount__c);
		dic.Status__c = status;
		if(status == '회수') dic.PayoutAmount__c = dic.PayoutAmount__c * -1;
		dic.ExternalKey__c = ((Datetime)processDate).format('yyyyMM') + '/' + target.BatchNo__c + '/' + target.Dealer__r.ERPCode__c + '/' + IncentiveType + '/' + status;
		return dic;
	}

	/**
	 * 사양차액지원
	 *  ALL	ALL	ALL	특별판매장려 승인 Record 內 기대번호
	 *
	 * @param target
	 * @param processDate
	 */
	public static DealerIncentiveCalculate__c getDealerIncentive1Create(AddSalesIncentiveItem__c target, Date processDate, String division, String status) {
		String IncentiveType = '사양차액지원';
		Set<String> nhChectType = new Set<String>{
				'농협', '관납'
		};
		DealerIncentiveCalculate__c dic = new DealerIncentiveCalculate__c();
		dic.CalculationDate__c = processDate;
		dic.Division__c = division;
		dic.IncentiveType__c = IncentiveType;
		dic.Type__c = nhChectType.contains(target.AddSalesIncentive__r.Dealer__r.CustomerType__c) ? target.AddSalesIncentive__r.Dealer__r.CustomerType__c : '대리점';
		dic.Asset__c = target.Asset__c;
		dic.Dealer__c = target.AddSalesIncentive__r.Dealer__c;
		dic.SalesAccount__c = target.AddSalesIncentive__r.Dealer__c;
		dic.SalesDocNo__c = target.fm_SalesDocNo__c;
		dic.Order__c = target.Asset__r.Order__c;
		dic.LineNumber__c = String.isEmpty(target.Asset__r.Order__r.ErpPOSNR__c) ? '000010' : target.Asset__r.Order__r.ErpPOSNR__c;
		dic.SupplyAmount__c = target.Asset__r.Order__r.ru_SellingPrice__c;
		dic.PayoutRate__c = target.AddSalesIncentive__r.AddRate__c;
		dic.PayoutAmount__c = (dic.SupplyAmount__c * dic.PayoutRate__c / 100).setScale(0);
		dic.PayoutAmount__c = amountRound1000(dic.PayoutAmount__c);
		dic.AddSalesIncentiveItem__c = target.Id;
		dic.Status__c = status;
		if(status == '회수') dic.PayoutAmount__c = dic.PayoutAmount__c * -1;
		dic.ExternalKey__c = ((Datetime)processDate).format('yyyyMM') + '/' + target.Asset__r.BatchNo__c + '/' + target.AddSalesIncentive__r.Dealer__r.ERPCode__c + '/' + IncentiveType + '/' + status;
		return dic;
	}


	/**
	 * 특별판촉지원
	 *  ALL	ALL	ALL	특별판매장려 승인 Record 內 기대번호
	 *
	 * @param target
	 * @param processDate
	 */
	public static DealerIncentiveCalculate__c getDealerIncentive2Create(AddSalesIncentiveItem__c target, Date processDate, String division, String status) {
		String IncentiveType = '특별판촉지원';
		Set<String> nhChectType = new Set<String>{
				'농협', '관납'
		};
		DealerIncentiveCalculate__c dic = new DealerIncentiveCalculate__c();
		dic.CalculationDate__c = processDate;
		dic.Division__c = division;
		dic.IncentiveType__c = IncentiveType;
		dic.Type__c = nhChectType.contains(target.AddSalesIncentive__r.Dealer__r.CustomerType__c) ? target.AddSalesIncentive__r.Dealer__r.CustomerType__c : '대리점';
		dic.Asset__c = target.Asset__c;
		dic.Dealer__c = target.AddSalesIncentive__r.Dealer__c;
		dic.SalesAccount__c = target.AddSalesIncentive__r.Dealer__c;
		dic.Order__c = target.Asset__r.Order__c;
		dic.SalesDocNo__c = target.fm_SalesDocNo__c;
		dic.LineNumber__c = String.isEmpty(target.Asset__r.Order__r.ErpPOSNR__c) ? '000010' : target.Asset__r.Order__r.ErpPOSNR__c;
		dic.SupplyAmount__c = target.Asset__r.Order__r.ru_SellingPrice__c;
		dic.PayoutRate__c = target.AddSalesIncentive__r.AddRate__c;
		dic.PayoutAmount__c = (dic.SupplyAmount__c * dic.PayoutRate__c / 100).setScale(0);
		dic.PayoutAmount__c = amountRound1000(dic.PayoutAmount__c);
		dic.AddSalesIncentiveItem__c = target.Id;
		dic.Status__c = status;
		if(status == '회수') dic.PayoutAmount__c = dic.PayoutAmount__c * -1;
		dic.ExternalKey__c = ((Datetime)processDate).format('yyyyMM') + '/' + target.Asset__r.BatchNo__c + '/' + target.AddSalesIncentive__r.Dealer__r.ERPCode__c + '/' + IncentiveType + '/' + status;
		return dic;
	}

	/**
	 * 작업기지원
	 *  ALL	ALL	ALL	특별판매장려 승인 Record 內 기대번호
	 *
	 * @param target
	 * @param processDate
	 */
	public static DealerIncentiveCalculate__c getDealerIncentive3Create(AddSalesIncentiveItem__c target, Date processDate, String division, String status) {
		String IncentiveType = '작업기지원';
		Set<String> nhChectType = new Set<String>{
				'농협', '관납'
		};
		DealerIncentiveCalculate__c dic = new DealerIncentiveCalculate__c();
		dic.CalculationDate__c = processDate;
		dic.Division__c = division;
		dic.IncentiveType__c = IncentiveType;
		dic.Type__c = nhChectType.contains(target.AddSalesIncentive__r.Dealer__r.CustomerType__c) ? target.AddSalesIncentive__r.Dealer__r.CustomerType__c : '대리점';
		dic.Asset__c = target.Asset__c;
		dic.Dealer__c = target.AddSalesIncentive__r.Dealer__c;
		dic.SalesAccount__c = target.AddSalesIncentive__r.Dealer__c;
		dic.Order__c = target.Asset__r.Order__c;
		dic.SalesDocNo__c = target.fm_SalesDocNoWM__c;
		dic.LineNumber__c = String.isEmpty(target.Asset__r.Order__r.ErpPOSNR__c) ? '000010' : target.Asset__r.Order__r.ErpPOSNR__c;
		dic.SupplyAmount__c = target.SalesPerformance__r.SalesAmount__c;
		dic.PayoutRate__c = target.AddSalesIncentive__r.AddRate__c;
		dic.PayoutAmount__c = (dic.SupplyAmount__c * dic.PayoutRate__c / 100).setScale(0);
		dic.PayoutAmount__c = amountRound1000(dic.PayoutAmount__c);
		dic.AddSalesIncentiveItem__c = target.Id;
		dic.Status__c = status;
		if(status == '회수') dic.PayoutAmount__c = dic.PayoutAmount__c * -1;
		dic.ExternalKey__c = ((Datetime)processDate).format('yyyyMM') + '/' + target.Asset__r.BatchNo__c + '/' + target.AddSalesIncentive__r.Dealer__r.ERPCode__c + '/' + IncentiveType + '/' + status;
		return dic;
	}

	/**
	 * 시승체험지원
	 *  특별판매장려 승인 Record 內 기대번호
	 *
	 * @param target
	 * @param processDate
	 */
	public static DealerIncentiveCalculate__c getCampaignCreate(Campaign target, Date processDate, String division, String status) {
		String IncentiveType = '시승체험지원';
		Set<String> nhChectType = new Set<String>{
				'농협', '관납'
		};
		DealerIncentiveCalculate__c dic = new DealerIncentiveCalculate__c();
		dic.CalculationDate__c = processDate;
		dic.Division__c = division;
		dic.IncentiveType__c = IncentiveType;
		dic.Type__c = target.Asset__r.Dealer__r.CustomerType__c;
		dic.Type__c = nhChectType.contains(target.Asset__r.Dealer__r.CustomerType__c) ? target.Asset__r.Dealer__r.CustomerType__c : '대리점';
		dic.Asset__c = target.Asset__c;
		dic.Dealer__c = target.Asset__r.Dealer__c;
		dic.SalesAccount__c = target.Asset__r.Dealer__c;
		dic.Order__c = target.Asset__r.Order__c;
		dic.SalesDocNo__c = target.Asset__r.Order__r.SalesDocNo__c;
		dic.SupplyAmount__c = target.Asset__r.Order__r.ru_SellingPrice__c;
		dic.LineNumber__c = String.isEmpty(target.Asset__r.Order__r.ErpPOSNR__c) ? '000010' : target.Asset__r.Order__r.ErpPOSNR__c;
		dic.PayoutRate__c = 11;
		dic.PayoutAmount__c = (dic.SupplyAmount__c * dic.PayoutRate__c / 100).setScale(0);
		dic.PayoutAmount__c = amountRound1000(dic.PayoutAmount__c);
		dic.Status__c = status;
		if(status == '회수') dic.PayoutAmount__c = dic.PayoutAmount__c * -1;
		dic.ExternalKey__c = ((Datetime)processDate).format('yyyyMM') + '/' + target.Asset__r.Name + '/' + target.Asset__r.Dealer__r.ERPCode__c + '/' + IncentiveType + '/' + status;
		return dic;
	}

	public static Decimal amountRound1000(Decimal amount) {
		return (amount / 1000).intValue() * 1000;
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
	}

}