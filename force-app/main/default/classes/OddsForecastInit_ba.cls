/****************************************************************************************
  * @filename      : OddsForecastInit_ba
  * @projectname   : 
  * @author        : i2max
  * @date          : 2021-05-03
  * @group         : 
  * @group-content : 
  * @description   : 
  * @tester        : OddsForecastInit_ba_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2021-05-03         i2max          Create
****************************************************************************************/
public with sharing class OddsForecastInit_ba implements Database.Batchable<SObject> {

    // 적용할 기준년월
    private Date baseYearMonth {get; set;}
    // 계산할 예측 외부키 Prefix
    private String baseYearMonthForExternalKeyPrefix {get; set;}

    /**
     * 생성자
     * 기본적으로 월배치 수행월 전달의 기준년월 승률 데이터를 사용함.
     */
    public OddsForecastInit_ba() {
        this(System.today().toStartOfMonth());
    }

    public OddsForecastInit_ba(final Date baseYearMonth) {
        this.baseYearMonth = baseYearMonth;
        this.baseYearMonthForExternalKeyPrefix = ((Datetime)this.baseYearMonth).format('yyyyMM');
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([
            SELECT  BusinessOffice__c, Dealer__c, Product__c, Dealer__r.DealerOwner__c, Dealer__r.OwnerId
            FROM Odds__c
            WHERE BaseYearMonth__c = :this.baseYearMonth
        ]);
    }

    /**
     * batch size 는 무조건 1로 해서 처리한다.
     * 따라서 배열로 넘어오더라도 index 0 인 것만 처리한다.
     * @param BC
     * @param scope
     */
    public void execute(Database.BatchableContext BC, List<Odds__c> scope) {

        List<Forecast__c> forecasts = new List<Forecast__c>();
        Id ownerId;
        for(Odds__c odds : scope) {
            ownerId = odds.Dealer__r.DealerOwner__c == null ? odds.Dealer__r.OwnerId : odds.Dealer__r.DealerOwner__c;
            forecasts.add(new Forecast__c(
                OwnerId = ownerId,
                BusinessOffice__c = odds.BusinessOffice__c,
                Dealer__c = odds.Dealer__c,
                Product__c = odds.Product__c,
                BaseYearMonth__c = this.baseYearMonth,
                ExternalKey__c = this.baseYearMonthForExternalKeyPrefix + '_' + odds.Dealer__c + '_' + odds.Product__c,
                Odds__c = odds.Id,
                M0Count__c = 0,
                M1Count__c = 0,
                M2Count__c = 0,
                M3Count__c = 0,
                M4Count__c = 0,
                M5Count__c = 0,
                M6Count__c = 0
            ));
        }

        //============================================================================
        // 기존에 데이터를 수정할 경우를 대비하여 upsert 처리함.
        //============================================================================
        upsert forecasts ExternalKey__c;
    }

    public void finish(Database.BatchableContext BC) {
        OddsForecastProcess_ba ba = new OddsForecastProcess_ba();
        if(Test.isRunningTest() == false) Database.executeBatch(ba, 1);
    }

}