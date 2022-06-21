/****************************************************************************************
  * @filename      : AccountSalesRankUpdate_ba
  * @projectname   : 
  * @author        : i2max_my.Seo 
  * @date          : 2020-08-18 오전 9:08
  * @group         : 
  * @group-content : 
  * @description   : 
  * @tester        : AccountSalesRankUpdate_ba_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author              description
  * ===============================================================
    0.1     2020-08-18 오전 9:08     i2max_my.Seo        Create
    0.2     2022-06-20               i2max               ITVOC-2021-07-0404
****************************************************************************************/
public class AccountSalesRankUpdate_ba implements Database.Batchable<SObject>, Database.Stateful {
    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([
                SELECT Id
                FROM Account
                LIMIT 1
        ]);
    }

    public void execute(Database.BatchableContext BC, List<Account> scope) {
        Map<Decimal, List<Account>> scoringMap          = new Map<Decimal, List<Account>>();
        List<Account>               targetUpdateList    = new List<Account>();
/*
        List<Account>               accounts            = [
                SELECT Id, SalesScoring__c, SalesIQRank__c
                FROM Account
                WHERE CustomerType__c = '대리점'
                AND IsDelete__c = FALSE
                ORDER BY SalesScoring__c DESC NULLS LAST
        ];
        Integer                     rank                = 0;

        // 점수별 Account List Map
        for(Account acc : accounts) {
            setSalesScoring(acc);

            if(!scoringMap.containsKey(acc.SalesScoring__c)) {
                scoringMap.put(acc.SalesScoring__c, new List<Account>{acc});
            }
            else {
                scoringMap.get(acc.SalesScoring__c).add(acc);
            }
        }

        // targetUpdateList에 실제 update 할 data Add.
        for(List<Account> accList : scoringMap.values()) {
            rank++;
            for(Account tempAcc : accList) {
                tempAcc.SalesIQRank__c = rank;

                targetUpdateList.add(tempAcc);
            }
        }
        update targetUpdateList;
 */
    }

    public void finish(Database.BatchableContext BC) {

    }

    /**
     * 해당 Account의 SalesScoring__c이 null일 경우, 0 처리.
     *
     * @param targetAccount : Account
     */
    private static void setSalesScoring(Account targetAccount) {
        if(targetAccount.SalesScoring__c == null) {
            targetAccount.SalesScoring__c = 0;
        }
    }
}