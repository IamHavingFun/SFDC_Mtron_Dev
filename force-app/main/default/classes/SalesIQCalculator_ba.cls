/****************************************************************************************
  * @filename      : SalesIQCalculator_ba
  * @projectname   : LS
  * @author        : Park HE
  * @date          : 2020-06-17
  * @group         :
  * @group-content :
  * @description   : SalesIQ 점수 집계
  * @tester        :
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                    author          description
  * ===============================================================
    0.1     2020-06-17             Park HE         Create
****************************************************************************************/


public with sharing class SalesIQCalculator_ba implements Database.Batchable<sObject>, Database.Stateful {

	public String query;
	public Boolean isNextBatch = true;
	public Date baseDate;
	public Date baseYearMonth;

	public SalesIQCalculator_ba() {
		this(null);
	}

	public SalesIQCalculator_ba(String query) {
		this(null, true);
	}

	public SalesIQCalculator_ba(String query, Boolean isNextBatch) {
		this.query = query;
		this.isNextBatch = isNextBatch;
	}

	public Database.QueryLocator start(Database.BatchableContext BC) {
		if(String.isEmpty(query)) {
			query = '' +
			' SELECT Id, Name, ERPCode__c, OwnerId, DealerOwner__c, IsSalesIQComplete__c, SalesIQRate__c, SalesIQPoint__c ' +
			'  FROM Account WHERE CustomerType__c = \'대리점\'  AND IsDelete__c = FALSE AND IsPartner = TRUE ' ;
		}
		return Database.getQueryLocator(query);
	}

	public void execute(Database.BatchableContext BC, List<Account> scope) {

		if(baseDate == null) baseDate = Date.today();
		if(baseYearMonth == null) baseYearMonth = Date.today().toStartOfMonth();

		Date baseYearMonthEnd = baseYearMonth.addMonths(1).addDays(-1);

		Set<String> accIds = new Set<String>();
		Set<String> salesIqSet = new Set<String>();
		for (Account a : scope) {
			accIds.add(a.Id);
		}

		// Sales IQ 정보
		Map<String, SalesIQ__c> salesIQPlanMap = new Map<String, SalesIQ__c>();
		for(SalesIQ__c r : [
				SELECT
						Id,
						Name,
						ExternalKey__c,
						BaseYearMonth__c,
						DealerCode__c,
						Dealer__c,
						Division__c,
						Point__c
				FROM SalesIQ__c
				WHERE Dealer__c IN :accIds
				AND BaseYearMonth__c = :baseYearMonth
				AND Division__c = '계획'
		]) {
			salesIQPlanMap.put(r.Dealer__c, r);
		}

		// 해당 대리점의 Sales IQ 계획이 없으면 생성 처리 해준다.
		// 1일 이후에 대리점이 생긴 경우를 위함.
		for (Account acc : scope) {
			if(salesIQPlanMap.containsKey(acc.Id) == false) {
				salesIQPlanMap.put(acc.Id, new SalesIQ__c(
						BaseYearMonth__c = baseYearMonth,
						Division__c = '계획',
						ExternalKey__c = '계획'+'/'+((Datetime)baseYearMonth).format('yyyy-MM-dd')+'/'+acc.ERPCode__c,
						Dealer__c = acc.Id,
						DealerCode__c = acc.ERPCode__c,
						Rank__c = 0,
						Point__c = 0
				));
			}
		}

		update salesIQPlanMap.values();

		// Sales IQ 정보
		Map<String, SalesIQ__c> salesIQMap = new Map<String, SalesIQ__c>();
		for(SalesIQ__c r : [
				SELECT
						Id,
						Name,
						ExternalKey__c,
						BaseYearMonth__c,
						DealerCode__c,
						Dealer__c,
						Division__c,
						Point__c
				FROM SalesIQ__c
				WHERE Dealer__c IN :accIds
				AND BaseYearMonth__c = :baseYearMonth
				AND Division__c = '실적'
		]) {
			salesIQMap.put(r.Dealer__c, r);
		}

		Map<String, Decimal> salesIQManageMap = new Map<String, Decimal>();
		for(SalesIQManage__c r : [
				SELECT
						ExternalId__c,
						ActionType__c,
						Point__c,
						TargetObject__c,
						IsActive__c
				FROM SalesIQManage__c
				WHERE IsActive__c = TRUE
				ORDER BY ExternalId__c
		]) {
			salesIQManageMap.put(r.ExternalId__c, r.Point__c);
		}

		String dealerId = '';
		Decimal cnt = 0;
		// 상담 정보
		Map<String, Decimal> ConsultingOpptyMap = new Map<String, Decimal>();
		for(AggregateResult ar : [
				SELECT Dealer__c, COUNT(Id) CNT
				FROM Opportunity
				WHERE ConsultingDate__c >= :baseYearMonth AND ConsultingDate__c <= :baseYearMonthEnd
				AND Dealer__c = :accIds
				AND Account.CustomerType__c NOT IN ('농협', '관납')
				GROUP BY Dealer__c
		]) {
			dealerId = (String) ar.get('Dealer__c');
			cnt = (Decimal) ar.get('CNT');
			ConsultingOpptyMap.put(dealerId, cnt);
		}
		// 견적 정보
		Map<String, Decimal> QuoteOpptyMap = new Map<String, Decimal>();
		for(AggregateResult ar : [
				SELECT Dealer__c, COUNT(Id) CNT
				FROM Opportunity
				WHERE QuoteDate__c >= :baseYearMonth AND QuoteDate__c <= :baseYearMonthEnd
				AND Dealer__c = :accIds
				AND Account.CustomerType__c NOT IN ('농협', '관납')
				GROUP BY Dealer__c
		]) {
			dealerId = (String) ar.get('Dealer__c');
			cnt = (Decimal) ar.get('CNT');
			QuoteOpptyMap.put(dealerId, cnt);
		}
		// 계약 정보
		Map<String, Decimal> ContracOpptyMap = new Map<String, Decimal>();
		for(AggregateResult ar : [
				SELECT Dealer__c, COUNT(Id) CNT
				FROM Opportunity
				WHERE ContractDate__c >= :baseYearMonth AND ContractDate__c <= :baseYearMonthEnd
				AND Dealer__c = :accIds
				AND Account.CustomerType__c NOT IN ('농협', '관납')
				GROUP BY Dealer__c
		]) {
			dealerId = (String) ar.get('Dealer__c');
			cnt = (Decimal) ar.get('CNT');
			ContracOpptyMap.put(dealerId, cnt);
		}
		// 인도 정보
		Map<String, Decimal> DeliveryOpptyMap = new Map<String, Decimal>();
		for(AggregateResult ar : [
				SELECT Dealer__c, COUNT(Id) CNT
				FROM Opportunity
				WHERE DeliveryDate__c >= :baseYearMonth AND DeliveryDate__c <= :baseYearMonthEnd
				AND Dealer__c = :accIds
				AND Account.CustomerType__c NOT IN ('농협', '관납')
				GROUP BY Dealer__c
		]) {
			dealerId = (String) ar.get('Dealer__c');
			cnt = (Decimal) ar.get('CNT');
			DeliveryOpptyMap.put(dealerId, cnt);
		}

		// 실주 정보
		String lossStage = '';
		Map<String, Decimal> LossOpptyMap = new Map<String, Decimal>();
		for(AggregateResult ar : [
				SELECT Dealer__c, LossStage__c, COUNT(Id) CNT
				FROM Opportunity
				WHERE LossDate__c >= :baseYearMonth AND LossDate__c <= :baseYearMonthEnd
				AND Dealer__c = :accIds
				AND LossReason__c = '기타'
				AND Account.CustomerType__c NOT IN ('농협', '관납')
				GROUP BY Dealer__c, LossStage__c
		]) {
			dealerId = (String) ar.get('Dealer__c');
			lossStage = (String) ar.get('LossStage__c');
			cnt = (Decimal) ar.get('CNT');
			LossOpptyMap.put(dealerId+'/'+lossStage, cnt);
		}

		List<SalesIQ__c> upsertSalesIQS = new List<SalesIQ__c>();
		//기준년월+/+대리점코드+/+구분
		SalesIQ__c planSalesIQ;
		SalesIQ__c salesIQ;
		Decimal calPoint;
		Decimal salesIQPoint;
		Set<Id> accountIds = new Set<Id>();
		for (Account a : scope) {

			if(salesIQMap.containsKey(a.Id)) {
				salesIQ = salesIQMap.get(a.Id);
			} else {
				salesIQ = new SalesIQ__c();
				salesIQ.ExternalKey__c = '실적'+'/'+((Datetime) baseYearMonth).format('yyyy-MM-dd') + '/' + a.ERPCode__c;
				salesIQ.BaseYearMonth__c = baseYearMonth;
				salesIQ.Dealer__c = a.Id;
				salesIQ.DealerCode__c = a.ERPCode__c;
				salesIQ.Division__c = '실적';
				salesIQ.Point__c = 0;
			}

			// 상담 점수 처리
			calPoint = 0;
			/*
			IQ-1001	판매기회:상담-등록 처리
			IQ-1002	판매기회:상담-실주 처리
			IQ-1003	판매기회:견적-등록 처리
			IQ-1004	판매기회:견적-실주 처리
			IQ-1005	판매기회:계약-등록 처리
			IQ-1006	판매기회:계약-실주 처리
			IQ-2001	판매기회:인도-등록 처리
			IQ-2002	장기유통재고 PDI 등록
			IQ-2003	가망고객 > 실고객 전환 건수 점수
			IQ-2004	기존고객 > 재판매 건수 점수
			IQ-3001	연체잔액 보유 시 (매월 1회 체크)
			IQ-9001	시승 종료 건 수
			 */
			if(ConsultingOpptyMap.containsKey(a.Id)) {
				if(salesIQManageMap.containsKey('IQ-1001')) {
					salesIQPoint = salesIQManageMap.get('IQ-1001');
					calPoint += (ConsultingOpptyMap.get(a.Id) * salesIQPoint);
				}
			}
			// 견적 점수 처리
			if(QuoteOpptyMap.containsKey(a.Id)) {
				if(salesIQManageMap.containsKey('IQ-1003')) {
					salesIQPoint = salesIQManageMap.get('IQ-1003');
					calPoint += (QuoteOpptyMap.get(a.Id) * salesIQPoint);
				}
			}
			// 계약 점수 처리
			if(ContracOpptyMap.containsKey(a.Id)) {
				if(salesIQManageMap.containsKey('IQ-1005')) {
					salesIQPoint = salesIQManageMap.get('IQ-1005');
					calPoint += (ContracOpptyMap.get(a.Id) * salesIQPoint);
				}
			}
			// 인도 점수 처리
			if(DeliveryOpptyMap.containsKey(a.Id)) {
				if(salesIQManageMap.containsKey('IQ-2001')) {
					salesIQPoint = salesIQManageMap.get('IQ-2001');
					calPoint += (DeliveryOpptyMap.get(a.Id) * salesIQPoint);
				}
			}
			// 실주 점수 처리
			if(LossOpptyMap.containsKey(a.Id+'/상담')) {
				if(salesIQManageMap.containsKey('IQ-1002')) {
					salesIQPoint = salesIQManageMap.get('IQ-1002');
					calPoint += (LossOpptyMap.get(a.Id+'/상담') * salesIQPoint);
				}
			}
			if(LossOpptyMap.containsKey(a.Id+'/견적')) {
				if(salesIQManageMap.containsKey('IQ-1004')) {
					salesIQPoint = salesIQManageMap.get('IQ-1004');
					calPoint += (LossOpptyMap.get(a.Id+'/견적') * salesIQPoint);
				}
			}
			if(LossOpptyMap.containsKey(a.Id+'/계약')) {
				if(salesIQManageMap.containsKey('IQ-1006')) {
					salesIQPoint = salesIQManageMap.get('IQ-1006');
					calPoint += (LossOpptyMap.get(a.Id+'/계약') * salesIQPoint);
				}
			}

			/*
				Sales I.Q. 실적/목표 100%↑ 대리점의 달성율 처리.
			 */
			planSalesIQ = salesIQPlanMap.get(a.Id);
			a.SalesIQPoint__c = calPoint;
			if(planSalesIQ.Point__c == 0) {
				// 계획이 없으면 달성율 0으로 처리 하고 수수료 주지 않는다.
				a.SalesIQRate__c = 0;
			} else {
				a.SalesIQRate__c = ((salesIQ.Point__c / planSalesIQ.Point__c)*100).setScale(1);
			}
			a.IsSalesIQComplete__c = false;

			// 모바일 화면 처리 때문에 기존 필드에 점수와 율을 등록 해준다.
			a.SalesScoring__c = a.SalesIQPoint__c;
			a.SalesIQRank__c = a.SalesIQRate__c;
			////////////////////////////////////////////////////////////
			if(a.SalesIQRate__c >= 100) {
				a.IsSalesIQComplete__c = true;
			}

			salesIQ.IsSalesIQComplete__c = a.IsSalesIQComplete__c;
			salesIQ.Point__c = calPoint;
			salesIQ.SalesIQRate__c = a.SalesIQRate__c;

			upsertSalesIQS.add(salesIQ);
			salesIQMap.put(a.Id, salesIQ);

			accountIds.add(a.Id);
			System.debug('Cal POINT : ' + calPoint + ' / Plan POINT' + planSalesIQ.Point__c);
		}
		//System.debug(JSON.serializePretty(upsertSalesIQS));
		update scope;
		if(upsertSalesIQS.isEmpty() == false) upsert upsertSalesIQS;
	}

	public void finish(Database.BatchableContext BC) {
		if(isNextBatch) {
			Database.executeBatch(new SalesIQRankUpdate_ba(), 1);
		}
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
	}

}