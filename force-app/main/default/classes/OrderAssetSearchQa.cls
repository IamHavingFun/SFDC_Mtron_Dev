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
                SELECT Id, BusinessOfficeName__c, BusinessOffice__r.Name, Dealer__r.Name, Name, ProductionDate__c, Product2.Name
                FROM Asset
                WHERE IsSendReceiveItem__c = true
                AND Product2Id = :productId
                AND TransferOrder__c = null
                ORDER BY ProductionDate__c DESC, BusinessOffice__r.Name
        ];

        return initData;
    }
}