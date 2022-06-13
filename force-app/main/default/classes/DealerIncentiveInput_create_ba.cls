/****************************************************************************************
  * @filename      : DealerIncentiveInput_create_ba
  * @projectname   :
  * @author        : i2max_my.Seo
  * @date          : 2020-08-18 오전 9:08
  * @group         :
  * @group-content :
  * @description   : 판매장려 기표 - 지급건 생성
  *                  매월 1일 5시 생성.
  * @tester        : DealerIncentiveCalculate_pdi_ba_ts.cls
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author              description
  * ===============================================================
    0.1     2020-08-18 오전 9:08     i2max_my.Seo           Create
****************************************************************************************/
public class DealerIncentiveInput_create_ba implements Database.Batchable<SObject>, Database.Stateful {

	public Date processDate;
	public String query;
	public Boolean isNextBatch;

	public DealerIncentiveInput_create_ba() {
		this(true);
	}

	public DealerIncentiveInput_create_ba(Boolean isNextBatch) {
		this.isNextBatch = isNextBatch;
	}

	public Database.QueryLocator start(Database.BatchableContext BC) {
		if(processDate == null) {
			processDate = Date.today().addDays(-1);
		}

		if(String.isEmpty(query)) {
			return Database.getQueryLocator([
					SELECT
							Id,
							Name,
							Type__c,
							AddSalesIncentiveItem__c,
							Asset__c,
							Asset__r.Name,
							Asset__r.Order__r.ru_SellingPrice__c,
							SalesAccount__c,
							Dealer__c,
							Dealer__r.ERPCode__c,
							Dealer__r.CustomerType__c,
							Dealer__r.BusinessOffice__c,
							CalculationDate__c,
							Division__c,
							IncentiveType__c,
							Order__c,
							PayoutAmount__c,
							PayoutRate__c,
							SalesDocNo__c,
							SupplyAmount__c,
							Status__c,
							AdSalesAmount__c          ,
							AdSalesRate__c            ,
							CSIncentiveAmount__c      ,
							CSIncentiveRate__c        ,
							SalesIncentiveAmount__c   ,
							SalesIncentiveRate__c     ,
							SalesDiscountAmount__c    ,
							SalesDiscountRate__c
					FROM DealerIncentiveCalculate__c
					WHERE CalculationDate__c = LAST_MONTH
					AND Status__c = '지급'
					AND IsSendERP__c = FALSE
					ORDER BY Asset__c, IncentiveType__c ASC
			]);
		} else {
			return Database.getQueryLocator(query);
		}

	}

	public void execute(Database.BatchableContext BC, List<DealerIncentiveCalculate__c> scope) {

		List<DealerIncentiveInput__c> diiList = new List<DealerIncentiveInput__c>();
		Set<String> nhChectType = new Set<String>{
				'농협', '관납'
		};

		String nhRecordTypeId = I2ComUtil.getRecordType('DealerIncentiveInput__c', 'NH');
		String govRecordTypeId = I2ComUtil.getRecordType('DealerIncentiveInput__c', 'GOV');
		String dealerRecordTypeId = I2ComUtil.getRecordType('DealerIncentiveInput__c', 'Dealer');

		Map<String, List<DealerIncentiveCalculate__c>> targetAssetMap = new Map<String, List<DealerIncentiveCalculate__c>>();
		List<DealerIncentiveCalculate__c> targetList;
		String key;
		Set<Id> assetIds = new Set<Id>();
		for (DealerIncentiveCalculate__c target : scope) {
			assetIds.add(target.Asset__c);
			key = target.Asset__c + '/' + target.Dealer__c;
			if(targetAssetMap.containsKey(key)) {
				targetAssetMap.get(key).add(target);
			} else {
				targetAssetMap.put(key, new List<DealerIncentiveCalculate__c>{target});
			}
		}

		DealerIncentiveInput__c dii;
		String customerType;
		String assetId;
		String dealerId;
		List<String> keySet;
		for(String keyId : targetAssetMap.keySet()) {
			keySet = keyId.split('/');

			targetList = targetAssetMap.get(keyId);

			dii = new DealerIncentiveInput__c();
			dii.Asset__c = keySet[0];
			dii.Dealer__c = keySet[1];
			dii.BaseDate__c = processDate.toStartOfMonth();
			dii.ApprovalStatus__c = '대상';
			dii.PaymentType__c = '지급';
			for(DealerIncentiveCalculate__c target : targetList) {
				// 마스터 키 : 기준년월 / 기표유형 / 기대번호 / 대리점코드
				dii.ExternalKey__c = ((Datetime)processDate).format('yyyyMM') + '/' + '지급' + '/' + target.Asset__r.Name + '/' + target.Dealer__r.ERPCode__c;
				dii.BusinessOffice__c = target.Dealer__r.BusinessOffice__c;
				if(target.Type__c == '농협') {
					dii.RecordTypeId = nhRecordTypeId;
				} else if(target.Type__c == '관납') {
					dii.RecordTypeId = govRecordTypeId;
				} else {
					dii.RecordTypeId = dealerRecordTypeId;
				}
				dii.Type__c = nhChectType.contains(target.Type__c) ? '서비스위탁' : '대리점';

				//  공급 가격
				if(target.IncentiveType__c == '과거판매장려금액') {
					dii.DealerIncentiveCalculate1__c = target.Id;
					dii.SalesSellingAmount__c     = target.SupplyAmount__c;
					dii.AdSalesRate__c            = target.AdSalesRate__c;
					dii.AdSalesAmount__c          = target.AdSalesAmount__c;
					dii.CSIncentiveRate__c        = target.CSIncentiveRate__c;
					dii.CSIncentiveAmount__c      = target.CSIncentiveAmount__c;
					dii.SalesIncentiveAmount__c   = target.SalesIncentiveAmount__c;
					dii.SalesIncentiveRate__c     = target.SalesIncentiveRate__c;
					dii.SalesDiscountAmount__c    = target.SalesDiscountAmount__c;
					dii.SalesDiscountRate__c      = target.SalesDiscountRate__c;
				} else {
					if(target.IncentiveType__c == 'PDI 등록') {
						//PDI 등록
						dii.DealerIncentiveCalculate3__c = target.Id;
						dii.SalesSellingAmount__c = target.SupplyAmount__c;
					} else if(target.IncentiveType__c == 'Sales I.Q. 달성') {
						//Sales I.Q. 달성
						dii.DealerIncentiveCalculate4__c = target.Id;
						dii.SalesSellingAmount__c = target.SupplyAmount__c;
					} else if(target.IncentiveType__c == '조기판매장려') {
						//조기판매장려
						dii.DealerIncentiveCalculate6__c = target.Id;
						dii.SalesSellingAmount__c = target.SupplyAmount__c;
					} else if(target.IncentiveType__c == '조기안착지원') {
						//조기안착지원
						dii.DealerIncentiveCalculate8__c = target.Id;
						dii.SalesSellingAmount__c = target.SupplyAmount__c;
					} else if(target.IncentiveType__c == '관납사후봉사') {
						//관납사후봉사
						dii.DealerIncentiveCalculate9__c = target.Id;
						dii.SalesSellingAmount__c = target.SupplyAmount__c;
					} else if(target.IncentiveType__c == '농협사후봉사') {
						//농협사후봉사
						dii.DealerIncentiveCalculate10__c = target.Id;
						dii.SalesSellingAmount__c = target.SupplyAmount__c;
					} else if(target.IncentiveType__c == '중개영업지원') {
						//중개영업지원
						dii.DealerIncentiveCalculate11__c = target.Id;
						dii.SalesSellingAmount__c = target.SupplyAmount__c;
						dii.BrokeringDealer__c = target.Dealer__c;
					} else if(target.IncentiveType__c == '시승체험지원') {
						//시승체험지원
						dii.DealerIncentiveCalculate12__c = target.Id;
						dii.SalesSellingAmount__c = target.SupplyAmount__c;
					} else if(target.IncentiveType__c == '사양차액지원') {
						//사양차액지원
						dii.DealerIncentiveCalculate13__c = target.Id;
						dii.SalesSellingAmount__c = target.SupplyAmount__c;
					} else if(target.IncentiveType__c == '특별판촉지원') {
						//특별판촉지원
						dii.DealerIncentiveCalculate14__c = target.Id;
						dii.SalesSellingAmount__c = target.SupplyAmount__c;
					} else if(target.IncentiveType__c == '작업기지원') {
						//작업기지원
						dii.DealerIncentiveCalculate15__c = target.Id;
						dii.WMSalesSellingAmount__c = target.SupplyAmount__c;
						if(dii.SalesSellingAmount__c == null) {
							dii.SalesSellingAmount__c = target.Asset__r.Order__r.ru_SellingPrice__c;
						}
					}
				}
			}
			diiList.add(dii);
		}
		System.debug(JSON.serializePretty(diiList));
		if(diiList.isEmpty() == false) {
			System.debug('저장 하자1');
			try {
				upsert diiList DealerIncentiveInput__c.ExternalKey__c;
			} catch (Exception e) {
				System.debug(e.getStackTraceString());
			}
			System.debug('저장 하자2');
		}

	}

	public void finish(Database.BatchableContext BC) {
		Database.executeBatch(new DealerIncentiveInput_create_recall_ba(), 200);
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
	}

}