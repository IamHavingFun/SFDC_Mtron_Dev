/****************************************************************************************
  * @filename      : AssetSendReceiveSpecifiedDate_ba
  * @projectname   : 
  * @author        : i2max 
  * @date          : 2020-07-08
  * @group         : 
  * @group-content : 
  * @description   : Asset 데이터의 전수배 지정 예정일 업데이트 매월 1일 배치
  * @tester        : AssetSendReceiveSpecifiedDate_ba_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author              description
  * ===============================================================
    0.1     2020-07-08               i2max                  Create
*************a***************************************************************************/
public with sharing class AssetSendReceiveSpecifiedDate_ba implements Database.Batchable<SObject> {

    private Date targetDate = System.today();
    public String query;

    public Database.QueryLocator start(Database.BatchableContext BC) {
        /*
         * ================================================================
         * 대상 : InventoryType__c = '대리점재고', 전수배지정예정일 <= 당일
         * ================================================================
         */
        /*return Database.getQueryLocator([
                SELECT  Id,
                        InventoryType__c,
                        IsSendReceiveItem__c,
                        SendReceiveSpecifiedDate__c
                FROM    Asset
                WHERE   InventoryType__c = '대리점재고'
                AND     fm_SendReceiveExpectedDate__c <= :this.targetDate
                AND     IsSendReceiveItem__c = false
        ]);*/
        if(String.isEmpty(query)) {
            query =
                    ' SELECT  Id, InventoryType__c ' +
                            ' FROM Asset' +
                            ' WHERE   InventoryType__c = \'대리점재고\'' +
                            ' AND     fm_SendReceiveExpectedDate__c <= :targetDate' +
                            ' AND     IsSendReceiveItem__c = false';
        }
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Asset> scope) {
/*

        for(Asset asset : scope) {
            asset.IsSendReceiveItem__c = true;
            asset.SendReceiveSpecifiedDate__c = this.targetDate;
        }
*/

        update scope;
    }

    public void finish(Database.BatchableContext param1) {
    }


}