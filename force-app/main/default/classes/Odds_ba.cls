/****************************************************************************************
  * @filename      : Odds_ba
  * @projectname   :
  * @author        : i2max
  * @date          : 2021-04-19
  * @group         :
  * @group-content :
  * @description   : 승률 처리
  *                     주기 : 매일
  *                     조건 : 전일까지의 3년 치
    * @tester        : OpportunityLossStageAlarm_ba_ts.cls
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2021-04-19         i2max          Create
****************************************************************************************/
public with sharing class Odds_ba implements Database.Batchable<SObject> {

	public String query;
	public Boolean isNextBatch = true;
	private Date  baseDate {get;set;}
	private Date  fromDate {get;set;}
	private Date  toDate {get;set;}

	public Odds_ba() {
		this(System.today());
	}

	public Odds_ba(final Date baseDate) {
		this.baseDate = baseDate;
		this.toDate  = this.baseDate;
		this.fromDate = this.toDate.addYears(-3);       // 최대 3년치
	}

	public Database.QueryLocator start(Database.BatchableContext BC) {
		if(String.isEmpty(query)) {
			query = 'SELECT Id, Name, OwnerId, ERPCode__c, BusinessOffice__c, BusinessOffice__r.Name, IsDelete__c  \n' +
					'FROM Account  \n' +
					'WHERE RecordType.Name = \'대리점\' \n' +
					'AND IsDelete__c = FALSE\n' +
					'AND BusinessOffice__c != NULL \n' +
					'AND BusinessOffice__r.Name != \'영업지원\' ';
		}
		return Database.getQueryLocator(query);
	}

	public void execute(Database.BatchableContext BC, List<Account> scope) {

		Date baseYearMonthDate = baseDate.toStartOfMonth();
		String baseYearMonth = ((Datetime) baseDate).format('yyyyMM');
		String stageKey = '';
		Decimal count = 0;

		Set<Id> dealersIds = new Set<Id>();
		for(Account r : scope) dealersIds.add(r.Id);

		Map<String, Decimal> stageWinCountMap = new Map<String, Decimal>();

		for(AggregateResult ar : [
				SELECT Dealer__c, InterestModel__c, StageName, COUNT(Id) Cnt
				FROM Opportunity
				WHERE Dealer__c = :dealersIds
				AND StageName != '실주'
				AND CreatedDate >= :fromDate AND CloseDate <= :toDate
				GROUP BY Dealer__c, InterestModel__c, StageName
		]) {
			stageKey = (String) ar.get('Dealer__c') + '_' + (String) ar.get('InterestModel__c') + '_' + (String) ar.get('StageName');
			count = (Decimal) ar.get('Cnt');
			stageWinCountMap.put(stageKey, count);
		}

		Map<String, Decimal> stageLossCountMap = new Map<String, Decimal>();
		for(AggregateResult ar : [
				SELECT Dealer__c, InterestModel__c, LossStage__c StageName, COUNT(Id) Cnt
				FROM Opportunity
				WHERE Dealer__c = :dealersIds
				AND StageName = '실주'
				AND CreatedDate >= :fromDate AND CloseDate <= :toDate
				GROUP BY Dealer__c, InterestModel__c, LossStage__c
		]) {
			stageKey = (String) ar.get('Dealer__c') + '_' + (String) ar.get('InterestModel__c') + '_' + (String) ar.get('StageName');
			count = (Decimal) ar.get('Cnt');
			stageLossCountMap.put(stageKey, count);
		}

		List<Product2> productList = [
				SELECT Id, Name, ProductCode, isSalesAvl__c, isOrderAvl__c, isDelete__c
				FROM Product2
				WHERE Type__c = '본체'
				AND isSalesAvl__c = TRUE
				AND isDelete__c = FALSE
				ORDER BY Name ASC
		];

		Map<String, Odds__c> oddsMap = new Map<String, Odds__c>();
		String externalKey = ''; //필수 키 : 기준년월(202104)+대리점코드(0000123456)+제품코드(000000000000)
		for(Account r : scope) {
			for(Product2 p : productList) {
				////필수 키 : 기준년월(202104)+대리점코드(0000123456)+제품코드(000000000000)
				externalKey = baseYearMonth + '_' + r.Id + '_' + p.Id;
				oddsMap.put(externalKey, new Odds__c(
						ExternalKey__c = externalKey,
						BaseYearMonth__c = baseYearMonthDate,
						BusinessOffice__c = r.BusinessOffice__c,
						Dealer__c = r.Id,
						Product__c = p.Id,
						ConsultingCount__c = 0,
						ConsultingLossCount__c = 0,
						QuoteCount__c = 0,
						QuoteLossCount__c = 0,
						ContractCount__c = 0,
						ContractLossCount__c = 0,
						DeliveryCount__c = 0,
						QuoteOddsRate__c = 0,
						ContractOddsRate__c = 0,
						DeliveryOddsRate__c = 0,
						TotalCount__c = 0,
						TotalOddsRate__c = 0
				));
			}
		}

		Set<String> stageNames = new Set<String>{'상담','견적','계약','인도'};
		Decimal QuoteOddsRate       = 0;
		Decimal ContractOddsRate    = 0;
		Decimal DeliveryOddsRate    = 0;
		Decimal TotalOddsRate       = 0;
		Decimal Qrate1 = 0;
		Decimal Qrate2 = 0;
		for(String key : oddsMap.keySet()) {
			Odds__c odds = oddsMap.get(key);
			for(String stage : stageNames) {
				switch on stage {
					when '상담' {
						stageKey = odds.Dealer__c + '_' + odds.Product__c + '_' + stage;
						if(stageWinCountMap.containsKey(stageKey)) {
							odds.ConsultingCount__c = stageWinCountMap.get(stageKey);
						}
						if(stageLossCountMap.containsKey(stageKey)) {
							odds.ConsultingLossCount__c = stageLossCountMap.get(stageKey);
						}
					}
					when '견적' {
						stageKey = odds.Dealer__c + '_' + odds.Product__c + '_' + stage;
						if(stageWinCountMap.containsKey(stageKey)) {
							odds.QuoteCount__c = stageWinCountMap.get(stageKey);
						}
						if(stageLossCountMap.containsKey(stageKey)) {
							odds.QuoteLossCount__c = stageLossCountMap.get(stageKey);
						}
					}
					when '계약' {
						stageKey = odds.Dealer__c + '_' + odds.Product__c + '_' + stage;
						if(stageWinCountMap.containsKey(stageKey)) {
							odds.ContractCount__c = stageWinCountMap.get(stageKey);
						}
						if(stageLossCountMap.containsKey(stageKey)) {
							odds.ContractLossCount__c = stageLossCountMap.get(stageKey);
						}
					}
					when '인도' {
						stageKey = odds.Dealer__c + '_' + odds.Product__c + '_' + stage;
						if(stageWinCountMap.containsKey(stageKey)) {
							odds.DeliveryCount__c = stageWinCountMap.get(stageKey);
						}
						if(stageLossCountMap.containsKey(stageKey)) {
							//odds.DeliveryLossCount__c = stageLossCountMap.get(stageKey);
						}
					}
					when else {

					}
				}
			} // end stage for


			// 전체 건수
			odds.TotalCount__c = odds.ConsultingCount__c + odds.QuoteCount__c + odds.ContractCount__c + odds.DeliveryCount__c +
								odds.ConsultingLossCount__c + odds.QuoteLossCount__c + odds.ContractLossCount__c;
			// 상담->견적 승률	견적->계약 승률	계약->인도 승률	종합승률 구하기.

			// 상담→견적 승률 : 견적+견적실주+계약+계약실주+인도 / 상담+상담실주+견적+견적실주+계약+계약실주+인도
			Qrate1 = odds.QuoteCount__c + odds.QuoteLossCount__c + odds.ContractCount__c + odds.ContractLossCount__c + odds.DeliveryCount__c;
			Qrate2 = odds.TotalCount__c;
			QuoteOddsRate       = Qrate2 == 0 ? 0 : (Qrate1 / Qrate2) * 100;

			// 견적→계약 승률 : 계약+계약실주+인도 / 견적+견적실주+계약+계약실주+인도
			Qrate1 = odds.ContractCount__c + odds.ContractLossCount__c + odds.DeliveryCount__c;
			Qrate2 = odds.QuoteCount__c + odds.QuoteLossCount__c + odds.ContractCount__c + odds.ContractLossCount__c + odds.DeliveryCount__c;
			ContractOddsRate    = Qrate2 == 0 ? 0 : (Qrate1 / Qrate2) * 100;

			// 계약→인도 승률 : 인도 / 계약+계약실주+인도
			Qrate1 = odds.DeliveryCount__c;
			Qrate2 = odds.ContractCount__c + odds.ContractLossCount__c + odds.DeliveryCount__c;
			DeliveryOddsRate    = Qrate2 == 0 ? 0 : (Qrate1 / Qrate2) * 100;

			// 종합승률 : 인도/모든 판매기회
			Qrate1 = odds.DeliveryCount__c;
			Qrate2 = odds.TotalCount__c;
			TotalOddsRate       = Qrate2 == 0 ? 0 : (Qrate1 / Qrate2) * 100;

			// 상담→견적 승률 : 견적+견적실주+계약+계약실주+인도 / 상담+상담실주+견적+견적실주+계약+계약실주+인도
			odds.QuoteOddsRate__c       = QuoteOddsRate.setScale(2, System.RoundingMode.HALF_UP);
			// 견적→계약 승률 : 계약+계약실주+인도 / 견적+견적실주+계약+계약실주+인도
			odds.ContractOddsRate__c    = ContractOddsRate.setScale(2, System.RoundingMode.HALF_UP);
			// 계약→인도 승률 : 인도 / 계약+계약실주+인도
			odds.DeliveryOddsRate__c    = DeliveryOddsRate.setScale(2, System.RoundingMode.HALF_UP);
			// 종합승률 : 인도/모든 판매기회
			odds.TotalOddsRate__c       = TotalOddsRate.setScale(2, System.RoundingMode.HALF_UP);

		}

		//============================================================================
		// 일괄처리를 하지 않고 부분 성공 허용
		// allOrNothing 을 false 처리하여 건건히는 수행되 되게끔 처리함.
		// 별도 로깅 처리없이 수행함. 로그 찍어도 볼 수 없음.
		//============================================================================
		List<Database.UpsertResult> results = Database.upsert(oddsMap.values(), Odds__c.ExternalKey__c,false);

	}

	public void finish(Database.BatchableContext BC) {
		OddsForecastInit_ba ba = new OddsForecastInit_ba();
		if(Test.isRunningTest() == false) Database.executeBatch(ba, 2000);
	}

}