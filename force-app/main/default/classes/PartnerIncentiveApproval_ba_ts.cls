/****************************************************************************************
 * @filename      : PartnerIncentiveApproval_ba_ts
 * @projectname   :
 * @author        : SEOKHO LEE
 * @date          : 2020-07-20 오후 5:26
 * @group         :
 * @group-content :
 * @description   : 판매장려 집계표 자동 승인 배치
 * @tester        :
 * @reference     :
 * @copyright     : Copyright © I2max. All Rights Reserved.
 * @modification Log
 * ===============================================================
 * ver     date                     author              description
 * ===============================================================
 0.1     2020-07-20 오후 5:26        SEOKHO LEE          Create
 ****************************************************************************************/

@IsTest
private class PartnerIncentiveApproval_ba_ts {
	@isTest
	static void testBehavior() {
		TestDataSalesFactory.init();
		DealerIncentiveInput__c dii = new DealerIncentiveInput__c();
		dii.Asset__c = TestDataSalesFactory.baseAsset.Id;
		dii.ApprovalStatus__c = '승인';
		dii.IsSend__c = true;
		dii.BaseDate__c = Date.today().addMonths(-1);
		dii.ExternalKey__c = '1';
		insert dii;

		PartnerIncentiveApproval_ba ba = new PartnerIncentiveApproval_ba();
		Database.executeBatch(ba, 1);
	}
	@isTest
	static void testBehavior2() {
		TestDataSalesFactory.init();
		DealerIncentiveInput__c dii = new DealerIncentiveInput__c();
		dii.Asset__c = TestDataSalesFactory.baseAsset.Id;
		dii.ApprovalStatus__c = '승인';
		dii.IsSend__c = true;
		dii.BaseDate__c = Date.today().addMonths(-1);
		dii.ExternalKey__c = '2';
		insert dii;

		String query = 'SELECT\n' +
				'\t\t\t\t\t\t\tId,\n' +
				'\t\t\t\t\t\t\tName,\n' +
				'\t\t\t\t\t\t\tOwnerId,\n' +
				'\t\t\t\t\t\t\tBaseDate__c,\n' +
				'\t\t\t\t\t\t\tType__c,\n' +
				'\t\t\t\t\t\t\tAsset__r.Name,\n' +
				'\t\t\t\t\t\t\tApprovalStatus__c,\n' +
				'\t\t\t\t\t\t\tApproveDate__c,\n' +
				'\t\t\t\t\t\t\tDealer__r.OwnerId,\n' +
				'\t\t\t\t\t\t\tDealer__r.Owner.IsActive,\n' +
				'\t\t\t\t\t\t\tDealer__r.Name,\n' +
				'\t\t\t\t\t\t\tfm_TotalAmount__c,\n' +
				'\t\t\t\t\t\t\tIsPartnerApprove__c,\n' +
				'\t\t\t\t\t\t\tPartnerApprovalUser__c,\n' +
				'\t\t\t\t\t\t\tPartnerApprovalDatetime__c,\n' +
				'\t\t\t\t\t\t\tPartnerApproveSendTime__c,\n' +
				'\t\t\t\t\t\t\tDealer__r.DealerOwner__c\n' +
				'\t\t\t\t\tFROM DealerIncentiveInput__c\n' +
				'\t\t\t\t\tWHERE BaseDate__c = LAST_MONTH\n' +
				'\t\t\t\t\tAND ApprovalStatus__c = \'승인\'\n' +
				'\t\t\t\t\tAND IsSend__c = TRUE\n' +
				'\t\t\t\t\tAND IsPartnerApprove__c = FALSE';
		PartnerIncentiveApproval_ba ba = new PartnerIncentiveApproval_ba();
		ba.query = query;
		Database.executeBatch(ba, 1);
	}
}