/****************************************************************************************
  * @filename      : marketingCampaignSalesActivityController
  * @projectname   : 
  * @author        : i2max
  * @date          : 2021-02-24
  * @description   : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * =========================================================================
  * ver     date                    author                    description
  * =========================================================================
    0.1     2021-02-24                 i2max                  Create
****************************************************************************************/
public with sharing class MarketingCampaignSalesActivityController {

    public class InitData extends I2ComClass.InitData {
        @AuraEnabled public List<Activity__c> salesActivities {get;private set;}
    }
    /**
     * init method
     * 캠페인 데이터로 영업활동 검색
     * 해당 대리점,작업시작일자
     * @return I2ComClass.InitData
     */
    @AuraEnabled
    public static I2ComClass.InitData init(String recordId) {
        InitData initData = new InitData();

        MarketingCampaign__c marketing = [
                SELECT Id, StartDate__c, Dealer__c
                FROM MarketingCampaign__c
                WHERE Id = :recordId
                limit 1
        ];
        Date lastN30Date = marketing.StartDate__c.addMonths(-1);
        initData.salesActivities = [
                SELECT Id, Account__c, Subject__c,Comments__c,Date__c
                FROM Activity__c
                WHERE Account__c = :marketing.Dealer__c
                AND Date__c < :marketing.StartDate__c
                AND Date__c >= :lastN30Date
                ORDER BY Date__c DESC
        ];
        return initData;
    }

}