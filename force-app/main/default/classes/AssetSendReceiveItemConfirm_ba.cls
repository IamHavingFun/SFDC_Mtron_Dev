/****************************************************************************************
  * @filename      : AssetSendReceiveItemConfirm_ba
  * @projectname   : 
  * @author        : i2max
  * @date          : 2020-04-16
  * @group         : 
  * @group-content : 
  * @description   : Asset 데이터의 전수배 데이터 확정 일배치
  * @tester        : AssetSendReceiveItemConfirm_ba_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2020-04-16         i2max          Create
****************************************************************************************/
public with sharing class AssetSendReceiveItemConfirm_ba implements Database.Batchable<SObject> {

    private Date exeDate = System.today();
    private Date targetDate = exeDate.addDays(-60);

    public Database.QueryLocator start(Database.BatchableContext BC) {

        System.debug(System.LoggingLevel.INFO, 'targetDate : ' + targetDate);

        /*
         * ================================================================
         * 1. 입고일이 60일 이상이 된건에 대해서 확정처리
         *      : 배치 수행일자의 -60일보더 작거나 같은 입고일자가 대상건
         * ================================================================
         */
        return Database.getQueryLocator([
            SELECT  Id
            FROM    Asset
            WHERE   Dealer__c != null
            AND     Order__c = null
            AND     DealerReceiptDate__c <= :this.targetDate
        ]);
/*        AND     IsSendReceiveItem__c = false
        AND     SendReceiveSpecifiedDate__c = null*/
    }

    public void execute(Database.BatchableContext BC, List<Asset> scope) {
/*
        for(Asset asset : scope) {
            asset.IsSendReceiveItem__c = true;
            asset.SendReceiveSpecifiedDate__c = this.exeDate;
        }
*/

        update scope;

    }

    public void finish(Database.BatchableContext BC) {

    }

}