/****************************************************************************************
  * @filename      : OddsDelete_ba
  * @projectname   : 
  * @author        : i2max
  * @date          : 2021-05-06
  * @group         : 
  * @group-content : 
  * @description   : 
  * @tester        : OddsDelete_ba_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2021-05-06         i2max          Create
****************************************************************************************/
public with sharing class OddsDelete_ba implements Database.Batchable<SObject> {

    // 후행배치의 기준년월
    private Date baseYearMonth;

    @TestVisible
    private OddsDelete_ba(){}

    public OddsDelete_ba(final Date baseYearMonth) {
        this.baseYearMonth = baseYearMonth;
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([
            SELECT Id
            FROM Odds__c
            WHERE BaseYearMonth__c < :this.baseYearMonth.addYears(-1)
        ]);
    }

    public void execute(Database.BatchableContext BC, List<Odds__c> scope) {
        delete scope;
    }

    public void finish(Database.BatchableContext BC) {

    }

}