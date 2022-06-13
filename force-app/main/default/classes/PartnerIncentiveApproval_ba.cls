/****************************************************************************************
  * @filename      : PartnerIncentiveApproval_ba
  * @projectname   :
  * @author        : i2max_my.Seo
  * @date          : 2020-08-18 오전 9:08
  * @group         :
  * @group-content :
  * @description   : 판매장려 집계표 - 파트너 자동 승인
  *
  * @tester        : PartnerIncentiveApproval_ba_ts.cls
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author              description
  * ===============================================================
    0.1     2020-08-18 오전 9:08     i2max_my.Seo           Create
****************************************************************************************/
public class PartnerIncentiveApproval_ba implements Database.Batchable<SObject>, Database.Stateful {

	public Date processDate;
	public String query;
	public Boolean isNextBatch;

	public PartnerIncentiveApproval_ba() {
		this(true);
	}

	public PartnerIncentiveApproval_ba(Boolean isNextBatch) {
		this.isNextBatch = isNextBatch;
	}

	public Database.QueryLocator start(Database.BatchableContext BC) {
		if(String.isEmpty(query)) {
			return Database.getQueryLocator([
					SELECT
							Id,
							Name,
							OwnerId,
							BaseDate__c,
							Type__c,
							Asset__r.Name,
							ApprovalStatus__c,
							ApproveDate__c,
							Dealer__r.OwnerId,
							Dealer__r.Owner.IsActive,
							Dealer__r.Name,
							fm_TotalAmount__c,
							IsPartnerApprove__c,
							PartnerApprovalUser__c,
							PartnerApprovalDatetime__c,
							PartnerApproveSendTime__c,
							Dealer__r.DealerOwner__c
					FROM DealerIncentiveInput__c
					WHERE BaseDate__c = LAST_MONTH
					AND ApprovalStatus__c = '승인'
					AND IsSend__c = TRUE
					AND IsPartnerApprove__c = FALSE
			]);
		} else {
			return Database.getQueryLocator(query);
		}

	}

	public void execute(Database.BatchableContext BC, List<DealerIncentiveInput__c> scope) {
		Datetime currentDatetime = Datetime.now();
		for (DealerIncentiveInput__c target : scope) {
			target.IsPartnerApprove__c          = true;
			target.IsPartnerIncentiveAutoApproval__c = true;
			target.PartnerApprovalUser__c       = UserInfo.getUserId();
			target.PartnerApprovalDatetime__c   = currentDatetime;
		}
		update scope;
	}

	public void finish(Database.BatchableContext BC) {
		if(isNextBatch) Database.executeBatch(new DealerIncentiveUnpaidERPSend_ba(), 20);
	}

}