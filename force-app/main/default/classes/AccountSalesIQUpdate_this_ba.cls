/****************************************************************************************
  * @filename      : AccountSalesIQUpdate_this_ba
  * @projectname   : LS
  * @author        : Park HE
  * @date          : 2020-05-14
  * @group         :
  * @group-content :
  * @description   :
  * @tester        :
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                    author          description
  * ===============================================================
    0.1     2020-05-14             Park HE         Create
****************************************************************************************/

public class AccountSalesIQUpdate_this_ba implements Database.Batchable<SObject>, Database.Stateful{

    // 외부 Argument
    public String query;
    public Boolean isNextBatch = true;

    public Database.QueryLocator start(Database.BatchableContext BC) {
        if(String.isEmpty(this.query)) {
            this.query = 'SELECT Id, SalesScoring__c, LastSalesScoring__c FROM Account WHERE CustomerType__c = \'대리점\' AND IsDelete__c = false ';
        }
        return Database.getQueryLocator(this.query);
    }

    public void execute(Database.BatchableContext BC, List<Account> accounts) {
        //scope.Id 기준으로 각 오브젝트 쿼리 + 합산

        Account scope = accounts.get(0); //batch size = 1

        List<AggregateResult> opptyAggregateResults = [
                SELECT Dealer__c, SUM(SalesIQ_1__c) SalesIQ_1__c
                FROM Opportunity
                WHERE CreatedDate = THIS_WEEK
                AND Dealer__c =: scope.Id
                GROUP BY Dealer__c];

        List<AggregateResult> contractAggregateResults = [
                SELECT Dealer__c, SUM(SalesIQ_1__c) SalesIQ_1__c
                FROM Contract__c
                WHERE ContractStartDate__c = THIS_WEEK
                AND Dealer__c =: scope.Id
                GROUP BY Dealer__c
        ];

        List<AggregateResult> leadAggregateResults = [
                SELECT Dealer__c, SUM(SalesIQ_1__c) SalesIQ_1__c
                FROM Lead
                WHERE TestDriveStartDateTime__c = THIS_WEEK AND Dealer__c =: scope.Id
                GROUP BY Dealer__c
        ];

        List<AggregateResult> caseAggregateResults = [
                SELECT AccountId, SUM(SalesIQ_1__c) SalesIQ_1__c
                FROM Case
                WHERE CreatedDate = THIS_WEEK AND AccountId = :scope.Id
                GROUP BY AccountId
        ];

        List<AggregateResult> pdiAggregateResults = [
                SELECT Contract__r.Dealer__c, SUM(SalesIQ_1__c) SalesIQ_1__c, SUM(SalesIQ_2__c) SalesIQ_2__c, SUM(SalesIQ_3__c) SalesIQ_3__c
                FROM PDI__c
                WHERE HandoverDate__c = THIS_WEEK AND Contract__r.Dealer__c =: scope.Id
                GROUP BY Contract__r.Dealer__c
        ];


        /**
         * 연체 체크는 월 1회만 처리 한다.
         * 주의 시작일과 종료일의 월이 다르면 수행.
         * 데이터 처리 기준은 전주 기준으로 처리 하고 있다.
        */
        Date startDate = Date.today().toStartOfWeek().addDays(-7);
        Date endDate = startDate.addDays(6);
        List<AggregateResult> accountAggregateResults = new List<AggregateResult>();
        if(startDate.month() != endDate.month()) {
            accountAggregateResults = [
                    SELECT Id, SUM(SalesIQ_1__c) SalesIQ_1__c
                    FROM Account
                    WHERE Id = :scope.Id
                    GROUP BY Id
            ];
        }

        Decimal opptySalesIQ = getSalesIQ(opptyAggregateResults,'oppty');
        Decimal contractSalesIQ = getSalesIQ(contractAggregateResults,'contract');
        Decimal leadSalesIQ = getSalesIQ(leadAggregateResults,'lead');
        Decimal caseSalesIQ = getSalesIQ(caseAggregateResults,'case');
        Decimal pdiSalesIQ = getSalesIQ(pdiAggregateResults,'pdi');
        Decimal assetSalesIQ = 0 ;//getSalesIQ(assetAggregateResults,'asset');
        Decimal accountSalesIQ = getSalesIQ(accountAggregateResults,'account');

        Decimal allSalesIQSum = (Decimal) opptySalesIQ + contractSalesIQ + leadSalesIQ + caseSalesIQ + pdiSalesIQ + assetSalesIQ + accountSalesIQ;

        scope.SalesScoring__c = scope.SalesScoring__c == null ? 0 : scope.SalesScoring__c;
        scope.LastSalesScoring__c = scope.SalesScoring__c == null ? 0 : scope.SalesScoring__c;

        // 2월에 초기화
        if(System.today().month() == 2 ){
            scope.LastSalesScoring__c = 0;
            scope.SalesScoring__c = allSalesIQSum;
        }
        else{
            scope.LastSalesScoring__c = scope.SalesScoring__c;
            scope.SalesScoring__c += allSalesIQSum;
        }

 //       update scope;

    }

    private static Decimal getSalesIQ(List<AggregateResult> ar, String objName){
        if(objName == 'pdi' && ar.size() == 1){
            return    (Decimal)ar.get(0).get('SalesIQ_1__c')
                    + (Decimal)ar.get(0).get('SalesIQ_2__c')
                    + (Decimal)ar.get(0).get('SalesIQ_3__c');
        }

        return ar.size() == 1 ? (Decimal)ar.get(0).get('SalesIQ_1__c') : 0;
    }

    public void finish(Database.BatchableContext param1) {
        if(this.isNextBatch) {
            Database.executeBatch(new AccountSalesRankUpdate_ba(), 1);
        }
    }
}