/****************************************************************************************
  * @filename      : Dummy_IF_KR_ERP_SE_0014_3_ba
  * @projectname   : 
  * @author        : i2max
  * @date          : 2021-04-27
  * @group         : 
  * @group-content : 
  * @description   : 0원 채권 만들기.
  *                  채권기준년월을 기준으로 전달 채권중 대상건을
  *                : 채권제로가 되게끔 강제 채권제로 레코드를 생성
  * @tester        : Dummy_IF_KR_ERP_SE_0014_3_ba_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2021-04-27         i2max          Create
****************************************************************************************/
public class Dummy_IF_KR_ERP_SE_0014_3_ba implements Database.Batchable<SObject> {

    public Boolean isNextBatch = true;

    // 채권 기준년월 baseYearMonth(0014 배치 수행시 세팅됨)
    private Date baseYearMonth;
    private String externaIdYearMonth;

    // 배치수행 이전월의 1일을 채권기준년월 로 기본 세팅함.
    public Dummy_IF_KR_ERP_SE_0014_3_ba() {
        this(System.today().addMonths(-1).toStartOfMonth());
    }

    public Dummy_IF_KR_ERP_SE_0014_3_ba(final Date baseYearMonth) {
        this.baseYearMonth = baseYearMonth;
        this.externaIdYearMonth = ((Datetime)this.baseYearMonth).format('yyyyMM');
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {

        Set<String> billingDocNosForBaseYearMonth = new Set<String>();

        //============================================================================
        // 채권기준년월 기준의 채권 데이터에서 제외되는 채권번호 리스트를 구함
        //============================================================================
        for(AR__c arForBaseYearMonth : [
            SELECT BillingDocNo__c
            FROM AR__c
            WHERE Division__c = '실적'
            AND BaseYearMonth__c = :this.baseYearMonth
            AND BillingDocNo__c != NULL
            AND IsForceZero__c = FALSE
        ]) {
            billingDocNosForBaseYearMonth.add(arForBaseYearMonth.BillingDocNo__c);
        }

        //============================================================================
        // 배치수행시 채권기준년월을 생성자 파라미터로 넘기고 이전달의 채권레코드를 기준으로
        // 채권기준년월 제외대상인 채권번호 리스트를 제외하고
        // 채권기준년월보다 한달 전의 채권데이터가 target Scope가 됨.
        //============================================================================
        return Database.getQueryLocator([
            SELECT  Id,
                    ExternalId__c,
                    Division__c,
                    ArAmt__c,
                    ArAmtKRW__c,
                    RepaymentKRW__c,
                    NoteCollectMoneyKRW__c,
                    CurrencyIsoCode,
                    PlanDate__c,
                    BookkeepingDate__c,
                    SGrp__c,
                    SaleTeam__c,
                    CustomerName__c,
                    CustomerCode__c,
                    GlName__c,
                    BillingDocNo__c,
                    CoCd__c,
                    DistributionChannel__c,
                    FiscalYear__c,
                    BaseYearMonth__c,
                    BusinessOffice__c,
                    AccountId__c,
                    SalesRep__c,
                    Area__c,
                    AssetId__c,
                    Order__c,
                    SalesOrderNumber__c,
                    Asset__c,
                    OwnerId
            FROM AR__c
            WHERE Division__c = '실적'
            AND BaseYearMonth__c = :baseYearMonth.addMonths(-1).toStartOfMonth()
            AND BillingDocNo__c NOT IN :billingDocNosForBaseYearMonth
            AND IsForceZero__c = FALSE
        ]);
    }

    public void execute(Database.BatchableContext BC, List<AR__c> targetScope) {

        List<AR__c> targetListForZero = new List<AR__c>();
        AR__c cloneAR;

        for(AR__c tAr : targetScope) {
            //============================================================================
            // deepClone 으로 데이터를 복제함.
            //============================================================================
            cloneAR = tAr.clone(false, true);
            //============================================================================
            // 복제데이터의 해당값을 세팅함
            //============================================================================
            // 강제채권제로 채권잔액
            cloneAR.RepaymentKRW__c = 0;
            // 강제채권제로 레코드 여부
            cloneAR.IsForceZero__c = true;
            // 강제채권제로 레코드 채권기준년월
            cloneAR.BaseYearMonth__c = this.baseYearMonth;
            // 강제채권제로 레코드 ExternalId
            cloneAR.ExternalId__c = '실적_'+this.externaIdYearMonth + '_' + cloneAR.BillingDocNo__c;
            //============================================================================
            // 해당값을 세팅한 복제값을 담음
            //============================================================================
            targetListForZero.add(cloneAR);
        }

        if(targetListForZero.size() > 0)    upsert targetListForZero AR__c.ExternalId__c;

    }

    public void finish(Database.BatchableContext BC) {
        if(this.isNextBatch)    Database.executeBatch(new Dummy_IF_KR_ERP_SE_0015_ba(), 200);
    }

}