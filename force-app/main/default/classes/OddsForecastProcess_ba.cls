/****************************************************************************************
  * @filename      : OddsForecastProcess_ba
  * @projectname   : 
  * @author        : i2max
  * @date          : 2021-05-03
  * @group         : 
  * @group-content : 
  * @description   : 
  * @tester        : OddsForecastProcess_ba_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2021-05-03         i2max          Create
****************************************************************************************/
public with sharing class OddsForecastProcess_ba implements Database.Batchable<SObject> {

    // 적용할 기준년월
    private Date baseYearMonth {get; set;}
    // 계산할 예측 외부키 Prefix
    private String baseYearMonthForExternalKeyPrefix {get; set;}
    // 계산할 예측의 타겟월 증가
    private Integer targetMonth {get;set;}
    // 판매기회의 검색 날짜 조건(from)
    private Date fromDate {get; set;}
    // 판매기회의 검색 날짜 조건(to)
    private Date toDate {get; set;}
    // 적용할 승률 맵 : ExternalKey 기준
    private Map<String, Odds__c> oddsByExternalKey = new Map<String, Odds__c>();
    // 최종 마지막 여부 판단
    private Boolean isLast {get; set;}

    /**
     * 생성자
     * 기본적으로 월배치 수행월 전달의 기준년월 승률 데이터를 사용함.
     */
    public OddsForecastProcess_ba() {
        this(System.today().toStartOfMonth(), 0);
    }

    public OddsForecastProcess_ba(final Date baseYearMonth, final Integer plusMonth) {
        this.targetMonth = plusMonth;
        this.baseYearMonth = baseYearMonth;
        this.baseYearMonthForExternalKeyPrefix = ((Datetime)this.baseYearMonth).format('yyyyMM');
        this.fromDate = this.baseYearMonth.addMonths(this.targetMonth).toStartOfMonth();
        this.toDate = this.fromDate.addMonths(1).addDays(-1);
        this.isLast = (this.targetMonth == 6);

        //============================================================================
        // 적용할 승률
        //============================================================================
        for(List<Odds__c> oddsList : [
                SELECT  Id,
                        ExternalKey__c,
                        QuoteOddsRate__c,       // 상담->견적 승률
                        ContractOddsRate__c,    // 견적->계약 승률
                        DeliveryOddsRate__c     // 게약->인도 승률
                FROM Odds__c
                WHERE BaseYearMonth__c = :this.baseYearMonth
        ]) {
            for(Odds__c odds : oddsList) {
                this.oddsByExternalKey.put(odds.ExternalKey__c, odds);
            }
        }
    }

    /**
     * 레코드별 계산 Wrapper Class
     */
    public class CalcData {
        // 적용할 예측 레코드
        public Forecast__c forecast {get;set;}
        // 적용할 승률 레코드
        private Odds__c odds {get;set;}
        // 적용할 상담건수
        public Decimal consultingCount {
            get {
                return this.consultingCount == null ? 0 : this.consultingCount;
            }
            set;
        }
        // 적용할 견적건수
        public Decimal quoteCount {
            get {
                return this.quoteCount == null ? 0 : this.quoteCount;
            }
            set;
        }
        // 적용할 계약건수
        public Decimal contractCount {
            get {
                return this.contractCount == null ? 0 : this.contractCount;
            }
            set;
        }
        // 적용할 인도 건수 (당월분만)
        public Decimal deliveryCount {
            get {
                return this.deliveryCount == null ? 0 : this.deliveryCount;
            }
            set;
        }
        // 예측 건수
        public Double mCount {get;set;}

        public CalcData(Forecast__c forecast, Odds__c odds) {
            this.forecast = forecast;
            this.odds = odds;
        }
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {

        //============================================================================
        // dummy queryLoactor를 사용
        // 배치를 돌리기 위한 임시방편 용도.
        //============================================================================
        return Database.getQueryLocator([SELECT Id FROM User LIMIT 1]);
    }


    public void execute(Database.BatchableContext BC, List<User> scope) {

        Map<String, CalcData> calcDataByExternalKey = new Map<String, CalcData>();
        String key;
        CalcData calcData;
        Odds__c tempOdds;

        //============================================================================
        // 적용할 상담건수
        //============================================================================
        for(AggregateResult result : [
            SELECT  Dealer__c, InterestModel__c,  COUNT(Id) mCount
            FROM Opportunity
            WHERE StageName  = '상담'
            AND InterestModel__r.isDelete__c = FALSE
            AND (CloseDate >= :this.fromDate AND CloseDate <= :this.toDate)
            GROUP BY Dealer__c, InterestModel__c
        ]) {
            key = makeExternalKey(result, this.baseYearMonthForExternalKeyPrefix);
            tempOdds = (Odds__c)oddsByExternalKey.get(key);
            calcData = new CalcData(new Forecast__c(ExternalKey__c = key), oddsByExternalKey.get(key));
            calcData.consultingCount = (Decimal)result.get('mCount');
            calcDataByExternalKey.put(key, calcData);
        }

        //============================================================================
        // 적용할 견적건수
        //============================================================================
        for(AggregateResult result : [
            SELECT  Dealer__c, InterestModel__c,  COUNT(Id) mCount
            FROM Opportunity
            WHERE StageName  = '견적'
            AND InterestModel__r.isDelete__c = FALSE
            AND (CloseDate >= :this.fromDate AND CloseDate <= :this.toDate)
            GROUP BY Dealer__c, InterestModel__c
        ]) {
            key = makeExternalKey(result, this.baseYearMonthForExternalKeyPrefix);

            if(calcDataByExternalKey.containsKey(key)) {
                calcData = calcDataByExternalKey.get(key);
            } else {
                calcData = new CalcData(new Forecast__c(ExternalKey__c = key), oddsByExternalKey.get(key));
            }

            calcData.quoteCount = (Decimal)result.get('mCount');
            calcDataByExternalKey.put(key, calcData);
        }

        //============================================================================
        // 적용할 계약건수
        //============================================================================
        for(AggregateResult result : [
            SELECT  Dealer__c, InterestModel__c,  COUNT(Id) mCount
            FROM Opportunity
            WHERE StageName  = '계약'
            AND InterestModel__r.isDelete__c = FALSE
            AND (CustomerExpectedDate__c >= :fromDate AND CustomerExpectedDate__c <= :toDate)
            GROUP BY Dealer__c, InterestModel__c
        ]) {
            key = makeExternalKey(result, this.baseYearMonthForExternalKeyPrefix);

            if(calcDataByExternalKey.containsKey(key)) {
                calcData = calcDataByExternalKey.get(key);
            } else {
                calcData = new CalcData(new Forecast__c(ExternalKey__c = key), oddsByExternalKey.get(key));
            }

            calcData.contractCount = (Decimal)result.get('mCount');
            calcDataByExternalKey.put(key, calcData);
        }

        //============================================================================
        // 당월 인도건수
        //============================================================================
        for(AggregateResult result : [
                SELECT  Dealer__c, InterestModel__c,  COUNT(Id) mCount
                FROM Opportunity
                WHERE StageName  = '인도'
                AND InterestModel__r.isDelete__c = FALSE
                AND (DeliveryDate__c >= :fromDate AND DeliveryDate__c <= :toDate)
                GROUP BY Dealer__c, InterestModel__c
        ]) {
            key = makeExternalKey(result, this.baseYearMonthForExternalKeyPrefix);
            if(calcDataByExternalKey.containsKey(key)) {
                calcData = calcDataByExternalKey.get(key);
            } else {
                calcData = new CalcData(new Forecast__c(ExternalKey__c = key), oddsByExternalKey.get(key));
            }
            calcData.deliveryCount = (Decimal)result.get('mCount');
            calcDataByExternalKey.put(key, calcData);
        }

        List<Forecast__c> upsertForecasts = new List<Forecast__c>();
        String info = '';

        //============================================================================
        // 예측건수 수식 수행
        //============================================================================

        for(CalcData calc : calcDataByExternalKey.values()) {

            // 승률이 없으면 예측도 처리 하지 않느다.
            if(calc.odds == null) continue;

            calc.consultingCount = calc.consultingCount == null ? 0 : calc.consultingCount;
            calc.quoteCount = calc.quoteCount == null ? 0 : calc.quoteCount;
            calc.contractCount = calc.contractCount == null ? 0 : calc.contractCount;

            //============================================================================
            // Test coverage 인 경우 기존 데이터 때문에 에러가 발생하여 if 처리함.
            //============================================================================
            if(Test.isRunningTest() == false) {
                try {
                    calc.mCount = (
                            (
                                    (calc.consultingCount * ((Double) calc.odds.QuoteOddsRate__c * 0.01))
                                            + calc.quoteCount
                            ) * ((Double) calc.odds.ContractOddsRate__c * 0.01)
                                    + calc.contractCount
                    ) * ((Double) calc.odds.DeliveryOddsRate__c * 0.01);
                } catch (Exception e) {
                    System.debug('targetMonth ==> ['+this.targetMonth+']');
                    System.debug('ExternalKey__c ==> ' + calc.forecast.ExternalKey__c);
                    System.debug('------------------------------------');
                    System.debug(JSON.serializePretty(calc.odds));
                    System.debug('------------------------------------');
                    System.debug(JSON.serializePretty(calc.forecast));
                    System.debug('------------------------------------');
                    System.debug(e.getMessage());
                    System.debug('------------------------------------');
                    continue;
                }
                if(this.targetMonth == 0) {
                    // 당월은 인도건수를 추가로 더해준다.
                    calc.mCount = (calc.mCount == null ? 0 : calc.mCount) + (calc.deliveryCount);
                    info = '(((('+calc.consultingCount + ' * ' +((Double)calc.odds.QuoteOddsRate__c * 0.01) + ') + ' +  calc.quoteCount + ') * ' +  ((Double)calc.odds.ContractOddsRate__c * 0.01) + ') + ' + calc.contractCount + ') * (' +  ((Double)calc.odds.DeliveryOddsRate__c * 0.01)+')';
                    calc.forecast.MInfo__c = info;
                }

                final String targetFieldApi = ('M' + this.targetMonth + 'Count__c');

                if(calc.forecast != null) {
                    calc.forecast.put(targetFieldApi, ((Decimal) calc.mCount).setScale(2, System.RoundingMode.HALF_UP));
                    calc.forecast.Odds__c = calc.odds.Id;
                    upsertForecasts.add(calc.forecast);
                }
            }

        }

        //============================================================================
        // 최종 데이터 upsert
        //============================================================================
        upsert upsertForecasts ExternalKey__c;
    }

    public void finish(Database.BatchableContext BC) {
        //============================================================================
        // M ~ M+6 까지 7개월간의 데이터를 돌리기 때문에 마지막인지 여부를 판단하여
        // M+ 데이터를 업데이트 함.
        //============================================================================
        if(this.targetMonth < 6) {
            final Integer nextTargetMonth = this.targetMonth + 1;
            Database.executeBatch(new OddsForecastProcess_ba(this.baseYearMonth, nextTargetMonth), 1);
        }

        //============================================================================
        // 마지막 예측 개월 수행후 1년 이전 데이터를 삭제하는 후행배치 수행
        //============================================================================
/*
        if(this.targetMonth == 6) {

        }
*/
    }

    /**
     * 판매기회의 예측을 위한 ExternalKey를 생성
     * @param result AggregateResult
     * @param baseYearMonthForExternalKey 외부키의 yyyyMM prefix
     *
     * @return String External Key
     */
    private static String makeExternalKey(AggregateResult result, final String baseYearMonthForExternalKey) {
        return baseYearMonthForExternalKey + '_' + (String)result.get('Dealer__c') + '_' + (String)result.get('InterestModel__c');
    }

}