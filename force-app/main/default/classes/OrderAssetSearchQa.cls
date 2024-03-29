/****************************************************************************************
  * @filename      : OrderAssetSearchQa
  * @projectname   : LWC_I2MAX
  * @author        : i2max_my.Seo
  * @date          : 2020-03-10 오전 9:36
  * @group         :
  * @group-content :
  * @description   : 전수배 대상 조회
  * @tester        : OrderAssetSearchQa_ts.cls
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author              description
  * ===============================================================
    0.1     2020-03-10 오전 9:36     i2max_my.Seo          Create
    0.2     2022-06-20               i2max              ITVOC-2021-07-0404
****************************************************************************************/

public with sharing class OrderAssetSearchQa {

    /**
     * @description wrapper class for InitData
     */
    public class InitData extends I2ComClass.InitData {
        @AuraEnabled public List<Asset> assetList {get;private set;}
    }

    /**
     * @description init method
     *
     * @return I2ComClass.InitData
     */
    @AuraEnabled
    public static I2ComClass.InitData init(String productId) {
        InitData initData = new InitData();

        initData.assetList = [
                SELECT Id, BusinessOffice__r.Name, Dealer__r.Name, Name, ProductionDate__c, Product2.Name
                FROM Asset
                WHERE Product2Id = :productId
                ORDER BY ProductionDate__c DESC, BusinessOffice__r.Name
        ];
/*
        AND IsSendReceiveItem__c = true
        AND TransferOrder__c = null
*/
        return initData;
    }
}