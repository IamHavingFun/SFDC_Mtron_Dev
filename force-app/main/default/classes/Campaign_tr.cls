/****************************************************************************************
  * @filename      : Campaign_tr
  * @projectname   : 
  * @author        : i2max_my.Seo 
  * @date          : 2020-08-11 오전 6:16
  * @group         : 
  * @group-content : 
  * @description   : 
  * @tester        : Campaign_tr_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author              description
  * ===============================================================
    0.1     2020-08-11 오전 6:16     i2max_my.Seo           Create
****************************************************************************************/
public without sharing class Campaign_tr extends TriggerHandler {

    public override void beforeUpdate() {
        this.setCampaignStatus(Trigger.new);
    }
    public override void afterUpdate() {
        this.updateOpportunity(Trigger.new);
    }

    private void setCampaignStatus(List<Campaign> newList) {
        for(Campaign c : newList) {
            if(c.TotalNumber__c != null && c.AssignNumber__c != null && (c.TotalNumber__c - c.AssignNumber__c == 0)) {
                c.IsActive  = false;
                c.Status    = '프로모션 완료';
            }
        }
    }

    private void updateOpportunity(List<Campaign> newList) {
        Set<Id> campaignIds = new Set<Id>();
        List<Opportunity> updateOpptyList = new List<Opportunity>();

        // 대상건.
        for(Campaign c : newList) {
            if(c.TotalNumber__c != null && c.AssignNumber__c != null && (c.TotalNumber__c - c.AssignNumber__c == 0)) {
                campaignIds.add(c.Id);
            }
        }

        // update 대상건.
        for(Campaign c : [SELECT Id, (
                SELECT Id, StageName, LossReason__c
                FROM Opportunities
                WHERE StageName = '상담'
                OR StageName = '견적'
        ) FROM Campaign WHERE Id IN :campaignIds]) {
            for(Opportunity o : c.Opportunities) {
                o.StageName     = '실주';
                o.LossReason__c = '프로모션 종료';

                updateOpptyList.add(o);
            }
        }

        update updateOpptyList;
    }
}