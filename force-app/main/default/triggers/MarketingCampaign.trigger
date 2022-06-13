/**
 * Created by MS on 2021-02-27.
 */

trigger MarketingCampaign on MarketingCampaign__c (before insert, before update, after update) {
	new MarketingCampaign_tr().run();
}