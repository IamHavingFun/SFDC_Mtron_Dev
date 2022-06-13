/****************************************************************************************
  * @filename      : MarketingCampaignLastActivityController
  * @projectname   : 
  * @author        : i2max
  * @date          : 2021-02-24
  * @description   :
  * @tester        : MarketingCampaignLastActivity_ts.cls
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * =========================================================================
  * ver     date                    author                    description
  * =========================================================================
    0.1     2021-02-24                 i2max                  Create
****************************************************************************************/
public with sharing class MarketingCampaignLastActivityController {
    
    public class InitData extends I2ComClass.InitData {
        @AuraEnabled public Decimal totalPrice {get;private set;}
        @AuraEnabled public List<Campaign> campaigns {get;private set;}
    }
    /**
     * init method
     * 캠페인 데이터로 시승/프로모션 검색
     * @return I2ComClass.InitData
     */
    @AuraEnabled
    public static I2ComClass.InitData init(String recordId) {
        InitData initData = new InitData();
        MarketingCampaign__c marketing = [
                SELECT Id, EndDate__c, Dealer__c, StartDate__c
                FROM MarketingCampaign__c
                WHERE Id = :recordId
                LIMIT 1
        ];

        /*
            2021-3-11 수정.
            최근 1년 내로 날짜 수정
        */
        Date lastN365Date = System.today().addDays(-365);
        if(lastN365Date.year() < 2021) {
            // 2021 년 부터 진행 하다록 처리.
            lastN365Date = Date.newInstance(2021, 1, 1);
        }
        initData.totalPrice = 0;
        initData.campaigns = [
                SELECT Name, ActualCost__c,StartDate, EndDate
                FROM Campaign
                WHERE Id IN (
                        SELECT Campaign__c
                        FROM ShareSetting__c
                        WHERE Account__c = :marketing.Dealer__c
                        AND Campaign__c != NULL
                )
                AND EndDate < :marketing.StartDate__c
                AND EndDate > :lastN365Date
                ORDER BY StartDate DESC
        ];
        for(Campaign r : initData.campaigns) {
            initData.totalPrice += (r.ActualCost__c == null ? 0 : r.ActualCost__c);
        }

        return initData;
    }
}