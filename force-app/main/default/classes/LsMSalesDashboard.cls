/**
 * Created by MS on 2020-06-29.
 */
//todo :: 같은 Account의 Partner 사용자끼리 데이터 공유하기 위해서,
// Enable Partner Super User Access 설정한 뒤에
// 'without sharing -> with sharing' +  'where 조건의 Owner 삭제' ??

public without sharing class LsMSalesDashboard {
    @AuraEnabled
    public static Map<String, Object> doGet(String sObjectName) {

        Map<String, Object> returnMap = new Map<String, Object>();

        String OwnerId = UserInfo.getUserId();
        User u = [SELECT Contact.Account.Id FROM User WHERE Id = :OwnerId];
        Id targetAccountId = u.Contact.Account.Id;

//        SalesPerformanceResData
        if (sObjectName == 'Sales') {
            Date currentDate = Date.today().addMonths(-1);
            Integer checkMonth = currentDate.month();
            SalesPerformanceResData sp = new SalesPerformanceResData();
/*
            for (AggregateResult ar : [
                    SELECT
                            AccountId__c,
                            SUM(SalesAmount__c) amount
                    FROM SalesPerformance__c
                    WHERE Division__c = '계획'
                    AND BaseYearMonth__c = THIS_YEAR
                    AND fm_Month__c <= :checkMonth
                    AND AccountId__c = :targetAccountId
                    GROUP BY AccountId__c
            ]) {
                sp.planAmt = ar.get('amount') == null ? 0 : (Decimal) ar.get('amount');
            }
            for (AggregateResult ar : [
                    SELECT
                            AccountId__c,
                            SUM(SalesAmount__c) amount
                    FROM SalesPerformance__c
                    WHERE Division__c = '실적'
                    AND BaseYearMonth__c = THIS_YEAR
                    AND fm_Month__c <= :checkMonth
                    AND AccountId__c = :targetAccountId
                    GROUP BY AccountId__c
            ]) {
                sp.performanceAmt = ar.get('amount') == null ? 0 : (Decimal) ar.get('amount');
            }
*/
            sp.targetYear = Date.today().year();
            returnMap.put('data', sp);
        } else if (sObjectName == 'Purchase') {
            Set<String> segments = new Set<String> {
                    '100~129HP',
                    '80~100hp',
                    'COMPACT',
                    'ROWCROP(수입)',
                    'SUBCOMPACT',
                    'UTILITY1',
                    'UTILITY2'
            };
/*
            Date targetDate = Date.today().addMonths(-1);
            Integer targetMonth = targetDate.month();
            SalesPerformanceResData sp = new SalesPerformanceResData();
            for (AggregateResult ar : [
                    SELECT
                            AccountId__c,
                            SUM(Qty__c) qty
                    FROM ActualSales__c
                    WHERE BaseYearMonth__c = THIS_YEAR
                    AND Division__c = '계획'
                    AND ProductType__c = '트랙터'
                    AND AccountId__c = :targetAccountId
                    AND Segment__c IN :segments
                    AND fm_Month__c <= :targetMonth
                    GROUP BY AccountId__c
            ]) {
                sp.planAmt = ar.get('qty') == null ? 0 : (Decimal) ar.get('qty');
            }
            for (AggregateResult ar : [
                    SELECT
                            AccountId__c,
                            SUM(Qty__c) qty
                    FROM ActualSales__c
                    WHERE BaseYearMonth__c = THIS_YEAR
                    AND Division__c = '실적'
                    AND ProductType__c = '트랙터'
                    AND AccountId__c = :targetAccountId
                    AND Segment__c IN :segments
                    AND fm_Month__c <= :targetMonth
                    GROUP BY AccountId__c
            ]) {
                sp.performanceAmt = ar.get('qty') == null ? 0 : (Decimal) ar.get('qty');
            }
            sp.targetYear = Date.today().year();
            returnMap.put('data', sp);
 */
        } else if (sObjectName == 'MarketInfoThis') {
            Date targetDate = Date.today().addMonths(-1);
            Integer targetMonth = targetDate.month();
            Integer currentQuarter = 1;
            if (targetMonth < 4)  currentQuarter = 4;
            else if (targetMonth < 7) currentQuarter = 1;
            else if (targetMonth < 10) currentQuarter = 2;
            else currentQuarter = 1;

            List<MarketResData> thisDatas = new List<MarketResData>();
            for (AggregateResult ar : [
                    SELECT
                            Company__c,
                            SUM(Quantity__c) qty
                    FROM MarketInfo__c
                    WHERE BaseYearMonth__c = THIS_YEAR
                    AND fm_Quarter__c <= :currentQuarter
                    AND AccountId__c = :targetAccountId
                    GROUP BY Company__c
            ]) {
                String company = (String) ar.get('Company__c');
                Decimal qty = ar.get('qty') == null ? 0 : (Decimal) ar.get('qty');
                thisDatas.add(new MarketResData(company, qty));
            }
            returnMap.put('data', thisDatas);
        } else if (sObjectName == 'MarketInfoLast') {
            Date targetDate = Date.today().addMonths(-1);
            Integer targetMonth = targetDate.month();
            Integer currentQuarter = 1;
            if (targetMonth < 4) currentQuarter = 4;
            else if (targetMonth < 7) currentQuarter = 1;
            else if (targetMonth < 10) currentQuarter = 2;
            else currentQuarter = 1;

            List<MarketResData> lastDatas = new List<MarketResData>();
            for (AggregateResult ar : [
                    SELECT
                            Company__c,
                            SUM(Quantity__c) qty
                    FROM MarketInfo__c
                    WHERE BaseYearMonth__c = LAST_YEAR
                    AND fm_Quarter__c <= :currentQuarter
                    AND AccountId__c = :targetAccountId
                    GROUP BY AccountId__c, Company__c
            ]) {
                String company = (String) ar.get('Company__c');
                Decimal qty = ar.get('qty') == null ? 0 : (Decimal) ar.get('qty');
                lastDatas.add(new MarketResData(company, qty));
            }
            returnMap.put('data', lastDatas);
        } else if (sObjectName == 'Delivery') {
            List<Delivery__c> deliveries = [
                    SELECT
                            Id,
                            BusinessOffice__r.Name,
                            Dealer__r.Name,
                            AssetId__r.Name,
                            ProductName__r.Name,
                            DateOfLoading__c,
                            CarNumber__c,
                            CarrierContact__c
                    FROM Delivery__c
                    WHERE CreatedDate = THIS_MONTH
                    AND Dealer__c = :targetAccountId
            ];
            returnMap.put('data', deliveries);
        } else if (sObjectName == 'AR') {
            ArResData arData = new ArResData();
            Date currentDate = Date.today().addMonths(-1);
            Integer checkMonth = currentDate.month();

            Map<Integer, ArResData> dataMap = new Map<Integer, ArResData>();
            /*for(AR__c r : [
                    SELECT
                            BaseYearMonth__c,
                            OverdueStatusSummary__c,
                            RepaymentKRW__c
                    FROM AR__c
                    WHERE BaseYearMonth__c >= LAST_YEAR
                    AND Division__c = '실적'
                    AND AccountId__c = :targetAccountId
                    AND fm_Month__c = :checkMonth
                    ORDER BY BaseYearMonth__c ASC
            ]) {
                if(dataMap.containsKey(r.BaseYearMonth__c.year())) {
                    arData = dataMap.get(r.BaseYearMonth__c.year());
                } else {
                    arData = new ArResData();
                }
                if(r.OverdueStatusSummary__c == '정상채권') arData.normal += (r.RepaymentKRW__c == null ? 0 : r.RepaymentKRW__c);
                if(r.OverdueStatusSummary__c == '6개월 미만') arData.sixMonthBelow += (r.RepaymentKRW__c == null ? 0 : r.RepaymentKRW__c);
                if(r.OverdueStatusSummary__c == '6~12개월') arData.sixMonthMore += (r.RepaymentKRW__c == null ? 0 : r.RepaymentKRW__c);
                if(r.OverdueStatusSummary__c == '1년 초과') arData.oneYearOver += (r.RepaymentKRW__c == null ? 0 : r.RepaymentKRW__c);

                arData.year = r.BaseYearMonth__c.year();
                arData.total = arData.normal + arData.sixMonthBelow + arData.sixMonthMore + arData.oneYearOver;
                dataMap.put(r.BaseYearMonth__c.year(), arData);
            }
*/
            returnMap.put('data', dataMap.values());
        } if (sObjectName == 'DealerStock') {
            /*Set<String> segments = new Set<String> {
                    '100~129HP',
                    '80~100hp',
                    'COMPACT',
                    'ROWCROP(수입)',
                    'SUBCOMPACT',
                    'UTILITY1',
                    'UTILITY2'
            };
            Date currentDate = Date.today().addMonths(-1);
            Integer checkMonth = currentDate.month();
            List<DealerStock__c> dealerStocks = [
                    SELECT
                            ModelName__c,
                            MachineNo__c,
                            StockInDate__c
                    FROM DealerStock__c
                    WHERE BaseYearMonth__c = THIS_YEAR
                    AND Division__c = '실적'
                    AND ProductType__c = '트랙터'
                    AND AccountId__c = :targetAccountId
                    AND fm_Month__c = :checkMonth
            ];
            return new Map<String, Object>{
                    'data' => dealerStocks
            };*/
        }
        return returnMap;
    }

    public class ArResData {
        @AuraEnabled public Integer year {get;set;}
        @AuraEnabled public Decimal total {get;set;}
        @AuraEnabled public Decimal normal {get;set;}
        @AuraEnabled public Decimal oneYearOver {get;set;}
        @AuraEnabled public Decimal sixMonthMore {get;set;}
        @AuraEnabled public Decimal sixMonthBelow {get;set;}

        public ArResData(){
            this.total = 0;
            this.normal = 0;
            this.sixMonthBelow = 0;
            this.sixMonthMore = 0;
            this.oneYearOver = 0;
        }
    }

    public class SalesPerformanceResData {
        @AuraEnabled public Integer targetYear {get;set;}
        @AuraEnabled public Decimal planAmt {get;set;}
        @AuraEnabled public Decimal performanceAmt {get;set;}
        @AuraEnabled public Decimal goalPercent {
            get {
                goalPercent = 0;
                if(planAmt != 0 && performanceAmt != 0) goalPercent = ((performanceAmt / planAmt) * 100).setScale(1, RoundingMode.HALF_UP);
                return goalPercent;
            }
            set;
        }

        public SalesPerformanceResData(){
            this.planAmt = 0;
            this.performanceAmt = 0;
        }
    }

    public class MarketResData {
        @AuraEnabled public String company {get;set;}
        @AuraEnabled public Decimal qty {get;set;}

        public MarketResData(String company, Decimal qty){
            this.company = company;
            this.qty = qty;
        }
    }

}