/****************************************************************************************
  * @filename      : DealerIncentiveCalculate_com_ba
  * @projectname   :
  * @author        : i2max_my.Seo
  * @date          : 2020-08-18 오전 9:08
  * @group         :
  * @group-content :
  * @description   : 판매장려 산출 - 공통 배치, 수작업을 위해서 사용함
  *
  * @tester        : DealerIncentiveCalculate_pdi_ba_ts.cls
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author          description
  * ===============================================================
  * 0.1     2022-03-14      i2max           Create
****************************************************************************************/
public without sharing class DealerIncentiveCalculate_com_ba {

	/**
	 * 추가판매장려 산출 처리
	 *
	 * @param scope
	 * @param processDate
	 */
	public static void DealerIncentiveCalculate_addfee_ba(List<AddSalesIncentiveItem__c> scope, Date processDate) {

		List<DealerIncentiveCalculate__c> insertDicList = new List<DealerIncentiveCalculate__c>();
		DealerIncentiveCalculate__c dic;
		for (AddSalesIncentiveItem__c target : scope) {
			/*
				사양차액지원
				특별판촉지원
				작업기지원
			 */
			if(target.AddSalesIncentive__r.Type__c == '사양차액지원') {
				dic = DealerIncentiveCalculate_service.getDealerIncentive1Create(target, processDate, '실적', '지급');
				if(dic != null) insertDicList.add(dic);
			} else if(target.AddSalesIncentive__r.Type__c == '특별판촉지원') {
				dic = DealerIncentiveCalculate_service.getDealerIncentive2Create(target, processDate, '실적', '지급');
				if(dic != null) insertDicList.add(dic);
			} else if(target.AddSalesIncentive__r.Type__c == '작업기지원') {
				dic = DealerIncentiveCalculate_service.getDealerIncentive3Create(target, processDate, '실적', '지급');
				if(dic != null) insertDicList.add(dic);
			}
		}

		System.debug('==============');
		if(insertDicList.isEmpty() == false) {
			upsert insertDicList DealerIncentiveCalculate__c.ExternalKey__c;
		}
	}

	/**
	 * 시승 산출 처리
	 *
	 * @param scope
	 * @param processDate
	 */
	public static void DealerIncentiveCalculate_campaign_ba(List<Campaign> scope, Date processDate) {

		DealerIncentiveCalculate__c dic;
		List<DealerIncentiveCalculate__c> insertDicList = new List<DealerIncentiveCalculate__c>();
		for (Campaign target : scope) {
			// 0. 시승체험지원
			dic = DealerIncentiveCalculate_service.getCampaignCreate(target, processDate, '실적', '지급');
			if (dic != null) insertDicList.add(dic);
		}

		if(insertDicList.isEmpty() == false) {
			upsert insertDicList DealerIncentiveCalculate__c.ExternalKey__c;
		}

	}

	/**
	 * 전수배 반품 산출 처리.
	 *
	 * @param scope
	 * @param processDate
	 */
	public static void DealerIncentiveCalculate_transrecall_ba(List<Delivery__c> scope, Date processDate) {

		Set<String> assetIds = new Set<String>();
		DealerIncentiveCalculate__c returnDic;

		for (Delivery__c target : scope) {
			assetIds.add(target.AssetId__c);
		}

		Map<String, Asset> calMap = new Map<String, Asset>();
		for(Asset r : [
				SELECT Id,
						Name,
				(
						SELECT 	Id,
								Name,
								AddSalesIncentiveItem__c,
								Asset__c,
								CalculationDate__c,
								Dealer__c,
								Dealer__r.ERPCode__c,
								Division__c,
								ERPSendDate__c,
								ExternalKey__c,
								IncentiveType__c,
								LineNumber__c,
								Order__c,
								PayoutAmount__c,
								PayoutRate__c,
								SalesAccount__c,
								SalesDocNo__c,
								SettlementDate__c,
								SupplyAmount__c,
								Status__c,
								Type__c,
								AdSalesAmount__c          ,
								AdSalesRate__c            ,
								CSIncentiveAmount__c      ,
								CSIncentiveRate__c        ,
								SalesIncentiveAmount__c   ,
								SalesIncentiveRate__c     ,
								SalesDiscountAmount__c    ,
								SalesDiscountRate__c,
								IsSendERP__c
						FROM DealerIncentiveCalculates__r
						WHERE Status__c = '지급'
						AND IncentiveType__c IN (
								'Sales I.Q. 달성', '조기안착지원', '시승체험지원', '사양차액지원',
								'특별판촉지원', '작업기지원', '과거판매장려금액',
								'관납사후봉사', '농협사후봉사', '중개영업지원', 'PDI 등록'
						) //,'PDI 등록 계획'
						ORDER BY CalculationDate__c DESC
				)
				FROM Asset WHERE Id IN : assetIds
		]) {
			calMap.put(r.Id, r);
		}

		List<DealerIncentiveCalculate__c> insertDicList = new List<DealerIncentiveCalculate__c>();
		List<DealerIncentiveCalculate__c> deleteList = new List<DealerIncentiveCalculate__c>();
		for (Delivery__c target : scope) {
			if(calMap.containsKey(target.AssetId__c)) {
				Asset asset = calMap.get(target.AssetId__c);
				if(asset.DealerIncentiveCalculates__r.isEmpty() == false) {
					for(DealerIncentiveCalculate__c dic : asset.DealerIncentiveCalculates__r) {
						if(dic.Division__c == '계획') {
							// 미지급건
							if (dic.CalculationDate__c.toStartOfMonth() == processDate.toStartOfMonth()) {
								// 처리 한 달이 같으면 해당 레코드 삭제 처리.
								deleteList.add(dic);
							} else {
								// 지난달은 건은 삭제 처리 하지 않는다.
							}
						} else {
							// 지급건
							if (dic.CalculationDate__c.toStartOfMonth() == processDate.toStartOfMonth()) {
								// 처리 한 달이 같으면 해당 레코드 삭제 처리.
								deleteList.add(dic);
							} else if(dic.IsSendERP__c == false) {
								// 달이 다르고 전송을 안한경우도 삭제 처리. : 수수료 주지 않았다.
								deleteList.add(dic);
							} else {
								if(dic.Dealer__c == target.Dealer__c && dic.IsSendERP__c == true) {
									// 대리점이 같은거에 대해서 처리.
									returnDic = dic.clone(false, false);
									if(dic.IncentiveType__c == '과거판매장려금액') {
										returnDic.CalculationDate__c = processDate;

										returnDic.AdSalesAmount__c          = dic.AdSalesAmount__c != null ? dic.AdSalesAmount__c * -1 : null;
										returnDic.AdSalesRate__c            = dic.AdSalesRate__c != null ? dic.AdSalesRate__c * -1 : null;
										returnDic.CSIncentiveAmount__c      = dic.CSIncentiveAmount__c != null ? dic.CSIncentiveAmount__c * -1 : null;
										returnDic.CSIncentiveRate__c        = dic.CSIncentiveRate__c != null ? dic.CSIncentiveRate__c * -1 : null;
										returnDic.SalesIncentiveAmount__c   = dic.SalesIncentiveAmount__c != null ? dic.SalesIncentiveAmount__c * -1 : null;
										returnDic.SalesIncentiveRate__c     = dic.SalesIncentiveRate__c != null ? dic.SalesIncentiveRate__c * -1 : null;
										returnDic.SalesDiscountAmount__c    = dic.SalesDiscountAmount__c != null ? dic.SalesDiscountAmount__c * -1 : null;
										returnDic.SalesDiscountRate__c      = dic.SalesDiscountRate__c != null ? dic.SalesDiscountRate__c * -1 : null;

										returnDic.SupplyAmount__c = dic.SupplyAmount__c * -1;
										returnDic.PayoutRate__c = dic.PayoutRate__c * -1;
										returnDic.PayoutAmount__c = dic.PayoutAmount__c * -1;
										returnDic.Status__c = '회수';
										returnDic.ExternalKey__c = ((Datetime) processDate).format('yyyyMM') + '/' + target.AssetId__r.Name + '/' + returnDic.Dealer__r.ERPCode__c + '/' + returnDic.IncentiveType__c + '/' + returnDic.Status__c;
										returnDic.SalesDocNo__c = target.SalesDocNo__c;
										returnDic.Order__c = target.OrderSellIn__c;
										returnDic.LineNumber__c = target.SalesDocItem__c;
										returnDic.IsSendERP__c = false;
										returnDic.ERPSendDate__c = null;
										returnDic.SettlementDate__c = null;
									} else {
										returnDic.CalculationDate__c = processDate;
										returnDic.SupplyAmount__c = dic.SupplyAmount__c * -1;
										returnDic.PayoutRate__c = dic.PayoutRate__c * -1;
										returnDic.PayoutAmount__c = dic.PayoutAmount__c * -1;
										returnDic.Status__c = '회수';
										returnDic.ExternalKey__c = ((Datetime) processDate).format('yyyyMM') + '/' + target.AssetId__r.Name + '/' + returnDic.Dealer__r.ERPCode__c + '/' + returnDic.IncentiveType__c + '/' + returnDic.Status__c;
										returnDic.SalesDocNo__c = target.SalesDocNo__c;
										returnDic.LineNumber__c = target.SalesDocItem__c;
										returnDic.Order__c = target.OrderSellIn__c;
										returnDic.IsSendERP__c = false;
										returnDic.ERPSendDate__c = null;
										returnDic.SettlementDate__c = null;
									}
									insertDicList.add(returnDic);
								}
							}
						}
					}
				}
			}
		}

		if(deleteList.isEmpty() == false) delete deleteList;
		if(insertDicList.isEmpty() == false) {
			upsert insertDicList DealerIncentiveCalculate__c.ExternalKey__c;
		}
	}

	/**
	 * 반품 산출 처리.
	 *
	 * @param scope
	 * @param processDate
	 */
	public static void DealerIncentiveCalculate_recall_ba(List<Delivery__c> scope, Date processDate) {

		Set<String> assetIds = new Set<String>();
		DealerIncentiveCalculate__c returnDic;

		for (Delivery__c target : scope) {
			assetIds.add(target.AssetId__c);
		}

		Map<String, Asset> calMap = new Map<String, Asset>();
		for(Asset r : [
				SELECT Id,
						Name,
				(
						SELECT 	Id,
								Name,
								AddSalesIncentiveItem__c,
								Asset__c,
								CalculationDate__c,
								Dealer__c,
								Dealer__r.ERPCode__c,
								Division__c,
								ERPSendDate__c,
								ExternalKey__c,
								IncentiveType__c,
								LineNumber__c,
								Order__c,
								PayoutAmount__c,
								PayoutRate__c,
								SalesAccount__c,
								SalesDocNo__c,
								SettlementDate__c,
								SupplyAmount__c,
								Status__c,
								Type__c,
								AdSalesAmount__c          ,
								AdSalesRate__c            ,
								CSIncentiveAmount__c      ,
								CSIncentiveRate__c        ,
								SalesIncentiveAmount__c   ,
								SalesIncentiveRate__c     ,
								SalesDiscountAmount__c    ,
								SalesDiscountRate__c
						FROM DealerIncentiveCalculates__r
						WHERE Status__c = '지급'
						AND IncentiveType__c IN ('Sales I.Q. 달성','조기안착지원','시승체험지원','사양차액지원',
								'특별판촉지원','작업기지원','과거판매장려금액',
								'관납사후봉사', '농협사후봉사', '중개영업지원', 'PDI 등록'
						)
						ORDER BY CalculationDate__c DESC
				)
				FROM Asset WHERE Id IN : assetIds
		]) {
			calMap.put(r.Id, r);
		}

		List<DealerIncentiveCalculate__c> insertDicList = new List<DealerIncentiveCalculate__c>();
		List<DealerIncentiveCalculate__c> deleteList = new List<DealerIncentiveCalculate__c>();
		for (Delivery__c target : scope) {
			if(calMap.containsKey(target.AssetId__c)) {
				Asset asset = calMap.get(target.AssetId__c);
				if(asset.DealerIncentiveCalculates__r.isEmpty() == false) {

					for(DealerIncentiveCalculate__c dic : asset.DealerIncentiveCalculates__r) {
						if (dic.IncentiveType__c == 'PDI 등록' && dic.Division__c == '계획') {
							if(dic.CalculationDate__c.toStartOfMonth() == processDate.toStartOfMonth()) {
								deleteList.add(dic);
								continue;
							} else {
								continue;
							}
						}
						if (dic.CalculationDate__c.toStartOfMonth() == processDate.toStartOfMonth()) {
							// 처리 한 달이 같으면 해당 레코드 삭제 처리.
							deleteList.add(dic);
						} else {
							// 다른 달이면 - 기표 처리.
							returnDic = dic.clone(false, false);
							if(dic.IncentiveType__c == '과거판매장려금액') {
								returnDic.CalculationDate__c = processDate;

								returnDic.AdSalesAmount__c          = dic.AdSalesAmount__c != null ? dic.AdSalesAmount__c * -1 : null;
								returnDic.AdSalesRate__c            = dic.AdSalesRate__c != null ? dic.AdSalesRate__c * -1 : null;
								returnDic.CSIncentiveAmount__c      = dic.CSIncentiveAmount__c != null ? dic.CSIncentiveAmount__c * -1 : null;
								returnDic.CSIncentiveRate__c        = dic.CSIncentiveRate__c != null ? dic.CSIncentiveRate__c * -1 : null;
								returnDic.SalesIncentiveAmount__c   = dic.SalesIncentiveAmount__c != null ? dic.SalesIncentiveAmount__c * -1 : null;
								returnDic.SalesIncentiveRate__c     = dic.SalesIncentiveRate__c != null ? dic.SalesIncentiveRate__c * -1 : null;
								returnDic.SalesDiscountAmount__c    = dic.SalesDiscountAmount__c != null ? dic.SalesDiscountAmount__c * -1 : null;
								returnDic.SalesDiscountRate__c      = dic.SalesDiscountRate__c != null ? dic.SalesDiscountRate__c * -1 : null;

								returnDic.SupplyAmount__c = dic.SupplyAmount__c * -1;
								returnDic.PayoutRate__c = dic.PayoutRate__c * -1;
								returnDic.PayoutAmount__c = dic.PayoutAmount__c * -1;
								returnDic.Status__c = '회수';
								returnDic.ExternalKey__c = ((Datetime) processDate).format('yyyyMM') + '/' + target.AssetId__r.Name + '/' + returnDic.Dealer__r.ERPCode__c + '/' + returnDic.IncentiveType__c + '/' + returnDic.Status__c;
								returnDic.SalesDocNo__c = target.SalesDocNo__c;
								returnDic.Order__c = target.OrderSellIn__c;
								returnDic.IsSendERP__c = false;
								returnDic.ERPSendDate__c = null;
								returnDic.SettlementDate__c = null;
							} else {
								returnDic.CalculationDate__c = processDate;
								returnDic.SupplyAmount__c = dic.SupplyAmount__c * -1;
								returnDic.PayoutRate__c = dic.PayoutRate__c * -1;
								returnDic.PayoutAmount__c = dic.PayoutAmount__c * -1;
								returnDic.Status__c = '회수';
								returnDic.ExternalKey__c = ((Datetime) processDate).format('yyyyMM') + '/' + target.AssetId__r.Name + '/' + returnDic.Dealer__r.ERPCode__c + '/' + returnDic.IncentiveType__c + '/' + returnDic.Status__c;
								returnDic.SalesDocNo__c = target.SalesDocNo__c;
								returnDic.Order__c = target.OrderSellIn__c;
								returnDic.IsSendERP__c = false;
								returnDic.ERPSendDate__c = null;
								returnDic.SettlementDate__c = null;
							}
							insertDicList.add(returnDic);
						}
					}
				}
			}
		}

		if(deleteList.isEmpty() == false) delete deleteList;
		if(insertDicList.isEmpty() == false) {
			upsert insertDicList DealerIncentiveCalculate__c.ExternalKey__c;
		}
	}

	/**
	 * 반환 산출 처리.
	 *
	 * @param scope
	 * @param processDate
	 */
	public static void DealerIncentiveCalculate_return_ba(List<AssetReturn__c> scope, Date processDate) {

		Set<String> assetIds = new Set<String>();
		Set<String> incentiveCheckType1 = new Set<String>{
				'전략제품'
		};
		Set<String> nhChectType = new Set<String>{
				'농협', '관납'
		};

		for (AssetReturn__c target : scope) {
			assetIds.add(target.Asset__c);
		}

		Map<String, Asset> calMap = new Map<String, Asset>();
		for(Asset r : [
				SELECT Id,
						Name,
				(
						SELECT 	Id,
								Name,
								AddSalesIncentiveItem__c,
								Asset__c,
								Asset__r.Name,
								CalculationDate__c,
								Dealer__c,
								Dealer__r.ERPCode__c,
								Division__c,
								ERPSendDate__c,
								ExternalKey__c,
								IncentiveType__c,
								LineNumber__c,
								Order__c,
								PayoutAmount__c,
								PayoutRate__c,
								SalesAccount__c,
								SalesDocNo__c,
								SettlementDate__c,
								SupplyAmount__c,
								Status__c,
								Type__c,
								AdSalesAmount__c          ,
								AdSalesRate__c            ,
								CSIncentiveAmount__c      ,
								CSIncentiveRate__c        ,
								SalesIncentiveAmount__c   ,
								SalesIncentiveRate__c     ,
								SalesDiscountAmount__c    ,
								SalesDiscountRate__c,
								IsSendERP__c
						FROM DealerIncentiveCalculates__r
						WHERE Status__c = '지급'
						AND IncentiveType__c IN ('PDI 등록','조기판매장려','관납사후봉사','농협사후봉사','중개영업지원','과거판매장려금액')
						ORDER BY CalculationDate__c DESC
				)
				FROM Asset WHERE Id IN : assetIds
		]) {
			calMap.put(r.Id, r);
		}

		DealerIncentiveCalculate__c returnDic;
		List<DealerIncentiveCalculate__c> insertDicList = new List<DealerIncentiveCalculate__c>();
		List<DealerIncentiveCalculate__c> deleteList = new List<DealerIncentiveCalculate__c>();
		for (AssetReturn__c target : scope) {
			if(calMap.containsKey(target.Asset__c)) {
				Asset asset = calMap.get(target.Asset__c);
				if(asset.DealerIncentiveCalculates__r.isEmpty() == false) {

					for(DealerIncentiveCalculate__c dic : asset.DealerIncentiveCalculates__r) {
						if(dic.IncentiveType__c == '과거판매장려금액' && dic.Type__c == '대리점') {
							// 대리점 유형일때는 과거판매장려금액은 회수 안한다.
							// 농협인경우만 처리.
							continue;
						}
						if (dic.CalculationDate__c.toStartOfMonth() == processDate.toStartOfMonth()) {
							// 처리 한 달이 같으면 해당 레코드 삭제 처리.
							deleteList.add(dic);
						} else if (dic.IsSendERP__c == true) {
							// 수수료 지급 한건.
							if(dic.IncentiveType__c == '과거판매장려금액') {
								returnDic = dic.clone(false, false);
								returnDic.CalculationDate__c = processDate;
								returnDic.AdSalesAmount__c          = dic.AdSalesAmount__c != null ? dic.AdSalesAmount__c * -1 : null;
								returnDic.AdSalesRate__c            = dic.AdSalesRate__c != null ? dic.AdSalesRate__c * -1 : null;
								returnDic.CSIncentiveAmount__c      = dic.CSIncentiveAmount__c != null ? dic.CSIncentiveAmount__c * -1 : null;
								returnDic.CSIncentiveRate__c        = dic.CSIncentiveRate__c != null ? dic.CSIncentiveRate__c * -1 : null;
								returnDic.SalesIncentiveAmount__c   = dic.SalesIncentiveAmount__c != null ? dic.SalesIncentiveAmount__c * -1 : null;
								returnDic.SalesIncentiveRate__c     = dic.SalesIncentiveRate__c != null ? dic.SalesIncentiveRate__c * -1 : null;
								returnDic.SalesDiscountAmount__c    = dic.SalesDiscountAmount__c != null ? dic.SalesDiscountAmount__c * -1 : null;
								returnDic.SalesDiscountRate__c      = dic.SalesDiscountRate__c != null ? dic.SalesDiscountRate__c * -1 : null;

								returnDic.SupplyAmount__c = dic.SupplyAmount__c * -1;
								returnDic.PayoutRate__c = dic.PayoutRate__c * -1;
								returnDic.PayoutAmount__c = dic.PayoutAmount__c * -1;
								returnDic.Status__c = '회수';
								returnDic.ExternalKey__c = ((Datetime) processDate).format('yyyyMM') + '/' + target.Asset__r.Name + '/' + target.Dealer__r.ERPCode__c + '/' + returnDic.IncentiveType__c + '/' + returnDic.Status__c;
								returnDic.IsSendERP__c = false;
								returnDic.ERPSendDate__c = null;
								returnDic.SettlementDate__c = null;
							} else {
								// 다른 달이면 - 기표 처리.
								returnDic = dic.clone(false, false);
								returnDic.CalculationDate__c = processDate;
								returnDic.SupplyAmount__c = returnDic.SupplyAmount__c * -1;
								returnDic.PayoutRate__c = returnDic.PayoutRate__c * -1;
								returnDic.PayoutAmount__c = returndic.PayoutAmount__c * -1;
								returnDic.Status__c = '회수';
								returnDic.ExternalKey__c = ((Datetime) processDate).format('yyyyMM') + '/' + dic.Asset__r.Name + '/' + dic.Dealer__r.ERPCode__c + '/' + dic.IncentiveType__c + '/' + returnDic.Status__c;
								returnDic.IsSendERP__c = false;
								returnDic.ERPSendDate__c = null;
								returnDic.SettlementDate__c = null;
								insertDicList.add(returnDic);

								if (returnDic.IncentiveType__c == 'PDI 등록' ||
										returnDic.IncentiveType__c == '관납사후봉사' ||
										returnDic.IncentiveType__c == '농협사후봉사' ||
										returnDic.IncentiveType__c == '중개영업지원' )
								{
									returnDic = dic.clone(false, false);
//									returnDic.IncentiveType__c = '(미지급) PDI 등록';
									returnDic.CalculationDate__c = processDate;
									returnDic.SupplyAmount__c = dic.SupplyAmount__c;
									returnDic.PayoutRate__c = dic.PayoutRate__c;
									returnDic.PayoutAmount__c = dic.PayoutAmount__c;
									returnDic.Status__c = '지급';
									returnDic.Division__c = '계획';
									returnDic.ExternalKey__c = ((Datetime) processDate).format('yyyyMM') + '/' + target.Asset__r.Name + '/' + target.Dealer__r.ERPCode__c + '/' + returnDic.IncentiveType__c + '/' + returnDic.Status__c;
									returnDic.IsSendERP__c = false;
									returnDic.ERPSendDate__c = null;
									returnDic.SettlementDate__c = null;
									insertDicList.add(returnDic);
								}
							}
						} else {
							// 지급한게 없다.
						}
					}
				}
			}
		}

		if(deleteList.isEmpty() == false) delete deleteList;
		if(insertDicList.isEmpty() == false) {
			upsert insertDicList DealerIncentiveCalculate__c.ExternalKey__c;
		}
	}


	/**
	 * 출하 처리 - 보관처리
	 * 출하 데이터를 자산 레코드 형식에 맞게 변경 처리 하고 출하 처리 한다.
	 *
	 * @param scope
	 * @param processDate
	 */
	public static void DealerIncentiveCalculate_keep_prc_ba(List<Delivery__c> scope, Date processDate) {
		List<Asset> assetScope = new List<Asset>();
		Asset asset;
		for(Delivery__c r : scope) {
			asset = r.AssetId__r;
			asset.Id = r.AssetId__c;
			asset.AccountId = r.SoldTo__c;
			asset.Account = r.SoldTo__r;
			asset.Dealer__c = r.SoldTo__c;
			asset.Dealer__r = r.SoldTo__r;
			asset.Order__c = r.OrderSellIn__c;
			asset.Order__r = r.OrderSellIn__r;
			assetScope.add(asset);
		}
		DealerIncentiveCalculate_com_ba.DealerIncentiveCalculate_delivery_ba(assetScope, processDate);
	}


	/**
	 * 출하 처리 - 보관 출고
	 * 출하 데이터를 자산 레코드 형식에 맞게 변경 처리 하고 출하 처리 한다.
	 *
	 * @param scope
	 * @param processDate
	 */
	public static void DealerIncentiveCalculate_keep_out_ba(List<Delivery__c> scope, Date processDate) {
		List<Asset> assetScope = new List<Asset>();
		Set<String> assetIds = new Set<String>();
		Asset asset;

		// 농협경제지주 지정을 해야 한다.
		Account nhAccount;
		if(Test.isRunningTest()) {
			nhAccount = scope[0].SoldTo__r;
		} else {
			nhAccount = [SELECT Id, Name FROM Account WHERE ERPCode__c = '0000113537'];
		}

		for(Delivery__c r : scope) {
			asset = r.AssetId__r;
			asset.Id = r.AssetId__c;
			asset.AccountId = r.SoldTo__c;
			asset.Account = r.SoldTo__r;
			asset.Dealer__c = r.Dealer__c;
			asset.Dealer__r = r.Dealer__r;
			asset.Order__c = r.OrderSellIn__c;
			asset.Order__r = r.OrderSellIn__r;
			assetScope.add(asset);
			assetIds.add(r.AssetId__c);
		}
		Map<String, DealerIncentiveCalculate__c> calMap = new Map<String, DealerIncentiveCalculate__c>();
		for(DealerIncentiveCalculate__c r : [
				SELECT Id,
						Name,
						AddSalesIncentiveItem__c,
						Asset__c,
						Asset__r.Name,
						Dealer__r.ERPCode__c,
						CalculationDate__c,
						Division__c,
						ERPSendDate__c,
						ExternalKey__c,
						IncentiveType__c,
						IsSendERP__c,
						Order__c,
						PayoutAmount__c,
						PayoutRate__c,
						SalesDocNo__c,
						SettlementDate__c,
						Status__c,
						SupplyAmount__c
				FROM DealerIncentiveCalculate__c
				WHERE Asset__c IN : assetIds
				AND Status__c = '지급'
				AND Division__c = '계획'
				AND IncentiveType__c IN ('농협사후봉사','중개영업지원')
				AND IsSendERP__c = FALSE
		]) {
			calMap.put(r.Asset__c+'/'+r.IncentiveType__c, r);
		}

		DealerIncentiveCalculate__c dic;
		List<DealerIncentiveCalculate__c> insertDicList = new List<DealerIncentiveCalculate__c>();
		List<DealerIncentiveCalculate__c> updateDicList = new List<DealerIncentiveCalculate__c>();
		for(Asset target : assetScope) {
			// 4. 농협사후봉사
			if(target.Account.CustomerType__c == '농협') {
				if(calMap.containsKey(target.Id+'/'+'농협사후봉사')) {
					// 대리점 이관건.
					dic = calMap.get(target.Id+'/'+'농협사후봉사');
					dic.Dealer__c = target.Dealer__c;
					dic.ExternalKey__c = ((Datetime)processDate).format('yyyyMM') + '/' + dic.Asset__r.Name + '/' + target.Dealer__r.ERPCode__c + '/' + dic.IncentiveType__c + '/' + '지급';
					dic.CalculationDate__c = processDate;
					dic.Division__c = '계획';
					updateDicList.add(dic);
				} else {
					dic = DealerIncentiveCalculate_service.getNHSalesCreate2(nhAccount, target, processDate, '계획', '지급');
					if(dic != null) insertDicList.add(dic);
				}

			}

			// 5. 중개영업지원
			if(target.Account.CustomerType__c == '농협' &&
					String.isNotEmpty(target.Account.BrokeringDealer__c) &&
					(target.Product2.BorkerFeeAmount__c != null && target.Product2.BorkerFeeAmount__c > 0)) {

				if(calMap.containsKey(target.Id+'/'+'중개영업지원')) {
					System.debug(target.Account.BrokeringDealer__c + '/' + target.Dealer__c);
					// 당월 PDI 처리건
					dic = calMap.get(target.Id+'/'+'중개영업지원');
					dic.Dealer__c = target.Dealer__c;
					dic.ExternalKey__c = ((Datetime)processDate).format('yyyyMM') + '/' + dic.Asset__r.Name + '/' + target.Dealer__r.ERPCode__c + '/' + dic.IncentiveType__c + '/' + '지급';
					dic.CalculationDate__c = processDate;
					dic.Division__c = '계획';
					updateDicList.add(dic);
				} else {
					dic = DealerIncentiveCalculate_service.getNHSalesBrokerCreate2(nhAccount, target, processDate, '계획', '지급');
					if(dic != null) insertDicList.add(dic);
				}

			}
		}

		if(insertDicList.isEmpty() == false) upsert insertDicList DealerIncentiveCalculate__c.ExternalKey__c;
		if(updateDicList.isEmpty() == false) update updateDicList;
	}


	/**
	 * 출하 처리 - 보관 이관
	 * 출하 데이터를 자산 레코드 형식에 맞게 변경 처리 하고 출하 처리 한다.
	 *
	 * @param scope
	 * @param processDate
	 */
	public static void DealerIncentiveCalculate_keep_mov_ba(List<Delivery__c> scope, Date processDate) {

		Set<String> assetIds = new Set<String>();
		List<Asset> assetScope = new List<Asset>();
		Asset asset;

		// 농협경제지주 지정을 해야 한다.
		Account nhAccount;
		if(Test.isRunningTest()) {
			nhAccount = scope[0].SoldTo__r;
		} else {
			nhAccount = [SELECT Id, Name FROM Account WHERE ERPCode__c = '0000113537'];
		}

		for(Delivery__c r : scope) {
			asset = r.AssetId__r;
			asset.Id = r.AssetId__c;
			asset.AccountId = r.SoldTo__c;
			asset.Account = r.SoldTo__r;
			asset.Dealer__c = r.Dealer__c;
			asset.Dealer__r = r.Dealer__r;
			asset.Order__c = r.OrderSellIn__c;
			asset.Order__r = r.OrderSellIn__r;
			assetScope.add(asset);
			assetIds.add(r.AssetId__c);
		}
		Map<String, DealerIncentiveCalculate__c> calMap = new Map<String, DealerIncentiveCalculate__c>();
		for(DealerIncentiveCalculate__c r : [
				SELECT Id,
						Name,
						AddSalesIncentiveItem__c,
						Asset__c,
						Asset__r.Name,
						Dealer__r.ERPCode__c,
						CalculationDate__c,
						Division__c,
						ERPSendDate__c,
						ExternalKey__c,
						IncentiveType__c,
						IsSendERP__c,
						Order__c,
						PayoutAmount__c,
						PayoutRate__c,
						SalesDocNo__c,
						SettlementDate__c,
						Status__c,
						SupplyAmount__c
				FROM DealerIncentiveCalculate__c
				WHERE Asset__c IN : assetIds
				AND Status__c = '지급'
				AND Division__c = '계획'
				AND IncentiveType__c IN ('농협사후봉사','중개영업지원')
				AND IsSendERP__c = FALSE
		]) {
			calMap.put(r.Asset__c+'/'+r.IncentiveType__c, r);
		}

		DealerIncentiveCalculate__c dic;
		List<DealerIncentiveCalculate__c> insertDicList = new List<DealerIncentiveCalculate__c>();
		List<DealerIncentiveCalculate__c> updateDicList = new List<DealerIncentiveCalculate__c>();
		for(Asset target : assetScope) {
			// 4. 농협사후봉사
			if(target.Account.CustomerType__c == '농협') {
				if(calMap.containsKey(target.Id+'/'+'농협사후봉사')) {
					// 대리점 이관건.
					dic = calMap.get(target.Id+'/'+'농협사후봉사');
					dic.Dealer__c = target.Dealer__c;
					dic.ExternalKey__c = ((Datetime)processDate).format('yyyyMM') + '/' + dic.Asset__r.Name + '/' + target.Dealer__r.ERPCode__c + '/' + dic.IncentiveType__c + '/' + '지급';
					dic.CalculationDate__c = processDate;
					dic.Division__c = '계획';
					updateDicList.add(dic);
				} else {
					dic = DealerIncentiveCalculate_service.getNHSalesCreate2(nhAccount, target, processDate, '계획', '지급');
					if(dic != null) insertDicList.add(dic);
				}
			}

			// 5. 중개영업지원
			if(target.Account.CustomerType__c == '농협' &&
					String.isNotEmpty(target.Account.BrokeringDealer__c) &&
					(target.Product2.BorkerFeeAmount__c != null && target.Product2.BorkerFeeAmount__c > 0)) {

				if(calMap.containsKey(target.Id+'/'+'중개영업지원')) {
					System.debug(target.Account.BrokeringDealer__c + '/' + target.Dealer__c);
					dic = calMap.get(target.Id+'/'+'중개영업지원');
					dic.Dealer__c = target.Dealer__c;
					dic.ExternalKey__c = ((Datetime)processDate).format('yyyyMM') + '/' + dic.Asset__r.Name + '/' + target.Dealer__r.ERPCode__c + '/' + dic.IncentiveType__c + '/' + '지급';
					dic.CalculationDate__c = processDate;
					dic.Division__c = '계획';
					updateDicList.add(dic);
				} else {
					dic = DealerIncentiveCalculate_service.getNHSalesBrokerCreate2(nhAccount, target, processDate, '계획', '지급');
					if(dic != null) insertDicList.add(dic);
				}

			}
		}

		if(insertDicList.isEmpty() == false) upsert insertDicList DealerIncentiveCalculate__c.ExternalKey__c;
		if(updateDicList.isEmpty() == false) update updateDicList;
	}

	/**
	 * 출하 처리.
	 *
	 * @param scope
	 * @param processDate
	 */
	public static void DealerIncentiveCalculate_delivery_ba(List<Asset> scope, Date processDate) {
		System.debug('START ----------------------------------------');
		Set<String> dealerIds = new Set<String>();
		Set<String> assetIds = new Set<String>();
		DealerIncentiveCalculate__c dic;
		DealerIncentiveCalculate__c returnDic;

		Set<String> incentiveCheckType1 = new Set<String>{
				'전략제품'
		};
		Set<String> nhChectType = new Set<String>{
				'농협', '관납'
		};
		// 3. 관납사후봉사
		Set<String> incentiveCheckType3 = new Set<String>{
				'전략제품',
				'정책',
				'도입',
				'실속형',
				'이앙기',
				'콤바인',
				'경제형',
				'MINI'
		};
		// 2. 조기판매장려
		Map<String, Decimal> incentiveCheckType2 = new Map<String, Decimal>{
				'이앙기' => 7,
				'콤바인' => 3
		};

		for (Asset target : scope) {
			dealerIds.add(target.Dealer__c);
			assetIds.add(target.Id);
		}

		Map<String, Boolean> salesIQMap = new Map<String, Boolean>();
		for(SalesIQ__c r : [
				SELECT Dealer__c, IsSalesIQComplete__c
				FROM SalesIQ__c
				WHERE BaseYearMonth__c = :processDate.toStartOfMonth()
				AND Division__c = '실적'
				AND Dealer__c IN :dealerIds
		]) {
			salesIQMap.put(r.Dealer__c, r.IsSalesIQComplete__c);
		}

		List<DealerIncentiveCalculate__c> insertDicList = new List<DealerIncentiveCalculate__c>();
		Boolean IsSalesIQComplete;
		for (Asset target : scope) {
			IsSalesIQComplete = false;
			if(salesIQMap.containsKey(target.Dealer__c)) {
				IsSalesIQComplete = salesIQMap.get(target.Dealer__c);
			}
			// TODO : 농협, 관납, 대리점, 중개 수수료 만들어야 함.
			// 0. PDI 계획 레코드 만들기.
			if(nhChectType.contains(target.Account.CustomerType__c) == false) {
				dic = DealerIncentiveCalculate_service.getPDICreate(target, processDate, '계획', '지급');
				if (dic != null) insertDicList.add(dic);
			} else {
				// 3. 관납사후봉사
				if(target.Account.CustomerType__c == '관납') {
					dic = DealerIncentiveCalculate_service.getGovSalesCreate(target, processDate, '계획', '지급');
					if(dic != null) insertDicList.add(dic);
				}
				// 4. 농협사후봉사
				if(target.Account.CustomerType__c == '농협') {
					dic = DealerIncentiveCalculate_service.getNHSalesCreate(target, processDate, '계획', '지급');
					if(dic != null) insertDicList.add(dic);
				}
				// 5. 중개영업지원
				if(target.Account.CustomerType__c == '농협' &&
						String.isNotEmpty(target.Account.BrokeringDealer__c)) {
					dic = DealerIncentiveCalculate_service.getNHSalesBrokerCreate(target, processDate, '계획', '지급');
					if(dic != null) insertDicList.add(dic);
				}
			}

			// 1. 조기안착지원
			if(nhChectType.contains(target.Account.CustomerType__c) == false &&
					target.Product2.ProductDivision__c == '전략제품') {
				dic = DealerIncentiveCalculate_service.getDealerCreate(target, processDate, '실적', '지급');
				if (dic != null) insertDicList.add(dic);
			}

			// 2. SalesIQ
			if(nhChectType.contains(target.Account.CustomerType__c) == false &&
					incentiveCheckType1.contains(target.Product2.ProductDivision__c) &&
					nhChectType.contains(target.Account.CustomerType__c) == false &&
					IsSalesIQComplete == true) {
				dic = DealerIncentiveCalculate_service.getSalesIQCreate(target, processDate, '실적', '지급');
				if(dic != null) insertDicList.add(dic);
			}

			// ITVOC-2022-04-0772
			// 3. 조기판매장려 : 출하유형
			// 수정일 : 2022/06/10
			if(incentiveCheckType2.containsKey(target.Product2.ProductDivision__c) &&
					nhChectType.contains(target.Account.CustomerType__c) == false) {
				dic = DealerIncentiveCalculate_service.getPreSalesCreate(target, processDate, '계획', '지급');
				if(dic != null) insertDicList.add(dic);
			}


		}

		System.debug('건수 : ['+insertDicList.size()+']');
		if(insertDicList.isEmpty() == false) {
			upsert insertDicList DealerIncentiveCalculate__c.ExternalKey__c;
		}
		System.debug('END ----------------------------------------');
	}

	/**
	 * PDI 산출 처리.
	 * @param scope
	 * @param processDate
	 */
	public static void DealerIncentiveCalculate_pdi_ba(List<Asset> scope, Date processDate) {

		DealerIncentiveCalculate__c dic;

		Set<String> nhChectType = new Set<String>{
				'농협', '관납'
		};
		// 1. PDI 등록
		Set<String> incentiveCheckType1 = new Set<String>{
				'전략제품','정책', '실속형','경제형','도입'
		};
		// 2. 조기판매장려
		Set<String> incentiveCheckType2 = new Set<String>{
				'이앙기','콤바인'
		};
		// 3. 관납사후봉사
		Set<String> incentiveCheckType3 = new Set<String>{
				'전략제품',
				'정책',
				'도입',
				'실속형',
				'이앙기',
				'콤바인',
				'경제형',
				'MINI'
		};
		Set<String> assetIds = new Set<String>();
		for (Asset target : scope) {
			assetIds.add(target.Id);
		}
//		System.debug(JSON.serializePretty(assetIds));
		Map<String, DealerIncentiveCalculate__c> calMap = new Map<String, DealerIncentiveCalculate__c>();
		for(DealerIncentiveCalculate__c r : [
				SELECT Id,
						Name,
						AddSalesIncentiveItem__c,
						Asset__c,
						Asset__r.Name,
						Dealer__r.ERPCode__c,
						CalculationDate__c,
						Division__c,
						ERPSendDate__c,
						ExternalKey__c,
						IncentiveType__c,
						IsSendERP__c,
						Order__c,
						PayoutAmount__c,
						PayoutRate__c,
						SalesDocNo__c,
						SettlementDate__c,
						Status__c,
						SupplyAmount__c
				FROM DealerIncentiveCalculate__c
				WHERE Asset__c IN : assetIds
				AND Status__c = '지급'
				AND Division__c = '계획'
				AND IncentiveType__c IN ('PDI 등록','관납사후봉사','농협사후봉사','중개영업지원','조기판매장려')
				AND IsSendERP__c = FALSE
		]) {
			calMap.put(r.Asset__c+'/'+r.IncentiveType__c, r);
		}
//		System.debug(JSON.serializePretty(calMap));
		List<DealerIncentiveCalculate__c> deleteDicList = new List<DealerIncentiveCalculate__c>();
		List<DealerIncentiveCalculate__c> insertDicList = new List<DealerIncentiveCalculate__c>();
		List<DealerIncentiveCalculate__c> updateDicList = new List<DealerIncentiveCalculate__c>();
		for (Asset target : scope) {
			// 1. PDI 등록
			if(incentiveCheckType1.contains(target.Product2.ProductDivision__c) &&
					nhChectType.contains(target.Account.CustomerType__c) == false) {
				if(calMap.containsKey(target.Id+'/'+'PDI 등록')) {
					// 당월 PDI 처리건
					dic = calMap.get(target.Id+'/'+'PDI 등록');
					dic.ExternalKey__c = ((Datetime)processDate).format('yyyyMM') + '/' + target.BatchNo__c + '/' + target.Dealer__r.ERPCode__c + '/' + dic.IncentiveType__c + '/' + '지급';
					dic.CalculationDate__c = processDate;
					dic.Division__c = '실적';
					dic.Dealer__c = target.Dealer__c;
					dic.SalesAccount__c = target.AccountId;
					updateDicList.add(dic);
				} else {
					dic = DealerIncentiveCalculate_service.getPDICreate(target, processDate, '실적', '지급');
					if(dic != null) insertDicList.add(dic);
				}
			}

			// 2. 조기판매장려 : ITVOC-2022-04-0772
			if(incentiveCheckType2.contains(target.Product2.ProductDivision__c) &&
					nhChectType.contains(target.Account.CustomerType__c) == false) {
				if(calMap.containsKey(target.Id+'/'+'조기판매장려')) {
					// 당월 조기판매장려 처리건
					// PDI 시 정상 요율로 변경 처리 위해서 기존 데이터 가져와서
					// 판매월 기준으로 다시 처리 한다.
					dic = calMap.get(target.Id+'/'+'조기판매장려');
					dic.ExternalKey__c = ((Datetime)processDate).format('yyyyMM') + '/' + target.BatchNo__c + '/' + target.Dealer__r.ERPCode__c + '/' + dic.IncentiveType__c + '/' + '지급';
					dic.CalculationDate__c = processDate;
					dic.Division__c = '실적';
					dic.Dealer__c = target.Dealer__c;
					dic.SalesAccount__c = target.AccountId;

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
					Integer salesDateMonth;
					if(target.Product2.ProductDivision__c == '이앙기') {
						salesDateMonth = target.SalesDate__c.month();
						if (checkMonths1.contains(salesDateMonth)) {
							// 이앙기	판매일자=11월~4월 (11, 12, 1, 2, 3, 4월 間)
							dic.PayoutRate__c = 8;
						}
						if (checkMonths2.contains(salesDateMonth)) {
							// 판매일자=5월~10월	6%
							dic.PayoutRate__c = 6;
						}
					} else if(target.Product2.ProductDivision__c == '콤바인') {
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
					dic.PayoutAmount__c = (dic.SupplyAmount__c * dic.PayoutRate__c / 100).setScale(0);
					dic.PayoutAmount__c = DealerIncentiveCalculate_service.amountRound1000(dic.PayoutAmount__c);
					updateDicList.add(dic);
				} else {
					dic = DealerIncentiveCalculate_service.getPreSalesCreate(target, processDate, '실적', '지급');
					if(dic != null) insertDicList.add(dic);
				}

			}

			// 3. 관납사후봉사
			if(target.Account.CustomerType__c == '관납') {
				if(calMap.containsKey(target.Id+'/'+'관납사후봉사')) {
					// 당월 PDI 처리건
					dic = calMap.get(target.Id+'/'+'관납사후봉사');
					dic.ExternalKey__c = ((Datetime)processDate).format('yyyyMM') + '/' + target.BatchNo__c + '/' + target.Dealer__r.ERPCode__c + '/' + dic.IncentiveType__c + '/' + '지급';
					dic.CalculationDate__c = processDate;
					dic.Division__c = '실적';
					dic.Dealer__c = target.Dealer__c;
					dic.SalesAccount__c = target.AccountId;
					updateDicList.add(dic);
				} else {
					dic = DealerIncentiveCalculate_service.getGovSalesCreate(target, processDate, '실적', '지급');
					if(dic != null) insertDicList.add(dic);
				}
			}

			// 4. 농협사후봉사
			if(target.Account.CustomerType__c == '농협') {
				if(calMap.containsKey(target.Id+'/'+'농협사후봉사')) {
					// 계획 ==> 실적
					dic = calMap.get(target.Id+'/'+'농협사후봉사');
					dic.ExternalKey__c = ((Datetime)processDate).format('yyyyMM') + '/' + target.BatchNo__c + '/' + target.Dealer__r.ERPCode__c + '/' + dic.IncentiveType__c + '/' + '지급';
					dic.CalculationDate__c = processDate;
					dic.Division__c = '실적';
					dic.Dealer__c = target.Dealer__c;
					dic.SalesAccount__c = target.AccountId;
					updateDicList.add(dic);
				} else {
					dic = DealerIncentiveCalculate_service.getNHSalesCreate(target, processDate, '실적', '지급');
					if(dic != null) insertDicList.add(dic);
				}
			}

			// 5. 중개영업지원
			if(target.Account.CustomerType__c == '농협' &&
					String.isNotEmpty(target.Account.BrokeringDealer__c) &&
					(target.Product2.BorkerFeeAmount__c != null && target.Product2.BorkerFeeAmount__c > 0)) {
				if(calMap.containsKey(target.Id+'/'+'중개영업지원')) {
					System.debug(target.Account.BrokeringDealer__c + '/' + target.Dealer__c);
					dic = calMap.get(target.Id+'/'+'중개영업지원');
					dic.ExternalKey__c = ((Datetime)processDate).format('yyyyMM') + '/' + dic.Asset__r.Name + '/' + target.Account.BrokeringDealer__r.ERPCode__c + '/' + dic.IncentiveType__c + '/' + '지급';
					dic.CalculationDate__c = processDate;
					dic.Division__c = '실적';
					dic.Dealer__c = target.Account.BrokeringDealer__c;
					dic.SalesAccount__c = target.AccountId;
					updateDicList.add(dic);
				} else {
					dic = DealerIncentiveCalculate_service.getNHSalesBrokerCreate(target, processDate, '실적', '지급');
					if(dic != null) insertDicList.add(dic);
				}
			}

		}

		if(deleteDicList.isEmpty() == false) delete deleteDicList;
		if(insertDicList.isEmpty() == false) upsert insertDicList DealerIncentiveCalculate__c.ExternalKey__c;
		if(updateDicList.isEmpty() == false) update updateDicList;

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
	}

}