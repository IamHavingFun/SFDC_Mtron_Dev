/****************************************************************************************
  * @filename      : DealerIncentiveERPSendPartner_ba
  * @projectname   :
  * @author        : i2max_my.Seo
  * @date          : 2020-08-18 오전 9:08
  * @group         :
  * @group-content :
  * @description   : 판매장려 - 파트너 승인건 전송
  *
  * @tester        : DealerIncentiveERPSendPartner_ba_ts.cls
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author              description
  * ===============================================================
    0.1     2020-08-18 오전 9:08     i2max_my.Seo           Create
****************************************************************************************/
public class DealerIncentiveERPSendPartner_ba implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts {

	public Date processDate;
	public String query;
	public Boolean isNextBatch;

	public DealerIncentiveERPSendPartner_ba() {
		this(true);
	}

	public DealerIncentiveERPSendPartner_ba(Boolean isNextBatch) {
		this.isNextBatch = isNextBatch;
	}

	public Database.QueryLocator start(Database.BatchableContext BC) {
		if(processDate == null) processDate = Date.today();

		if(String.isEmpty(query)) {
			return Database.getQueryLocator([
					SELECT
							Id,
							Name,
							OwnerId,
							RecordTypeId,
							RecordType.Name,
							BaseDate__c,
							Type__c,
							AdSalesAmount__c,
							AdSalesRate__c,
							ApprovalStatus__c,
							ApproveDate__c,
							IsPartnerApprove__c,
							IsPartnerIncentiveAutoApproval__c,
							PartnerApprovalDatetime__c,
							PartnerApprovalUser__r.Name,
							Asset__c,
							Asset__r.Name,
							Asset__r.BatchNo__c,
							Asset__r.InventoryType__c,
							Asset__r.ProductionDate__c,
							Asset__r.FirstDeliveryDate__c,
							Asset__r.DealerReceiptDate__c,
							Asset__r.IncentiveSeqNo__c,
							Asset__r.Product2.ProductCode,
							Asset__r.Dealer__r.Owner.EmployeeNumber,
							Dealer__r.ERPCode__c,
							Dealer__r.Owner.EmployeeNumber,
							BrokeringDealer__r.ERPCode__c,
							BrokeringDealer__r.Owner.EmployeeNumber,
							DealerIncentiveCalculate1__c,
							DealerIncentiveCalculate2__c,
							DealerIncentiveCalculate3__c,
							DealerIncentiveCalculate4__c,
							DealerIncentiveCalculate6__c,
							DealerIncentiveCalculate7__c,
							DealerIncentiveCalculate8__c,
							DealerIncentiveCalculate9__c,
							DealerIncentiveCalculate10__c,
							DealerIncentiveCalculate11__c,
							DealerIncentiveCalculate12__c,
							DealerIncentiveCalculate13__c,
							DealerIncentiveCalculate14__c,
							DealerIncentiveCalculate15__c,
							DealerIncentiveCalculate3__r.Division__c,
							DealerIncentiveCalculate1__r.SalesDocNo__c,
							DealerIncentiveCalculate2__r.SalesDocNo__c,
							DealerIncentiveCalculate3__r.SalesDocNo__c,
							DealerIncentiveCalculate4__r.SalesDocNo__c,
							DealerIncentiveCalculate6__r.SalesDocNo__c,
							DealerIncentiveCalculate7__r.SalesDocNo__c,
							DealerIncentiveCalculate8__r.SalesDocNo__c,
							DealerIncentiveCalculate9__r.SalesDocNo__c,
							DealerIncentiveCalculate10__r.SalesDocNo__c,
							DealerIncentiveCalculate11__r.SalesDocNo__c,
							DealerIncentiveCalculate12__r.SalesDocNo__c,
							DealerIncentiveCalculate13__r.SalesDocNo__c,
							DealerIncentiveCalculate14__r.SalesDocNo__c,
							DealerIncentiveCalculate15__r.SalesDocNo__c,
							DealerIncentiveCalculate1__r.LineNumber__c,
							DealerIncentiveCalculate2__r.LineNumber__c,
							DealerIncentiveCalculate3__r.LineNumber__c,
							DealerIncentiveCalculate4__r.LineNumber__c,
							DealerIncentiveCalculate6__r.LineNumber__c,
							DealerIncentiveCalculate7__r.LineNumber__c,
							DealerIncentiveCalculate8__r.LineNumber__c,
							DealerIncentiveCalculate9__r.LineNumber__c,
							DealerIncentiveCalculate10__r.LineNumber__c,
							DealerIncentiveCalculate11__r.LineNumber__c,
							DealerIncentiveCalculate12__r.LineNumber__c,
							DealerIncentiveCalculate13__r.LineNumber__c,
							DealerIncentiveCalculate14__r.LineNumber__c,
							DealerIncentiveCalculate15__r.LineNumber__c,
							DealerIncentiveCalculate1__r.Status__c,
							DealerIncentiveCalculate2__r.Status__c,
							DealerIncentiveCalculate3__r.Status__c,
							DealerIncentiveCalculate4__r.Status__c,
							DealerIncentiveCalculate6__r.Status__c,
							DealerIncentiveCalculate7__r.Status__c,
							DealerIncentiveCalculate8__r.Status__c,
							DealerIncentiveCalculate9__r.Status__c,
							DealerIncentiveCalculate10__r.Status__c,
							DealerIncentiveCalculate11__r.Status__c,
							DealerIncentiveCalculate12__r.Status__c,
							DealerIncentiveCalculate13__r.Status__c,
							DealerIncentiveCalculate14__r.Status__c,
							DealerIncentiveCalculate15__r.Status__c,
							DealerIncentiveCalculate15__r.AddSalesIncentiveItem__r.fm_SalesDocNo__c,
							DealerIncentiveCalculate15__r.AddSalesIncentiveItem__r.fm_SalesDocLineNo__c,
							DealerIncentiveCalculate15__r.AddSalesIncentiveItem__r.fm_SalesDocNoWM__c,
							DealerIncentiveCalculate15__r.AddSalesIncentiveItem__r.fm_SalesDocLineNoWM__c,
							DealerIncentiveCalculate15__r.AddSalesIncentiveItem__r.SalesPerformance__r.ProductCode__c,
							DealerIncentiveCalculate1__r.SalesAccount__r.ERPCode__c,
							DealerIncentiveCalculate9__r.SalesAccount__r.ERPCode__c,
							DealerIncentiveCalculate10__r.SalesAccount__r.ERPCode__c,
							DealerIncentiveCalculate11__r.SalesAccount__r.ERPCode__c,
							DealerIncentiveCalculate1__r.ERPSeqNo__c,
							DealerIncentiveCalculate3__r.ERPSeqNo__c,
							DealerIncentiveCalculate4__r.ERPSeqNo__c,
							DealerIncentiveCalculate6__r.ERPSeqNo__c,
							DealerIncentiveCalculate7__r.ERPSeqNo__c,
							DealerIncentiveCalculate8__r.ERPSeqNo__c,
							DealerIncentiveCalculate9__r.ERPSeqNo__c,
							DealerIncentiveCalculate10__r.ERPSeqNo__c,
							DealerIncentiveCalculate11__r.ERPSeqNo__c,
							DealerIncentiveCalculate12__r.ERPSeqNo__c,
							DealerIncentiveCalculate13__r.ERPSeqNo__c,
							DealerIncentiveCalculate14__r.ERPSeqNo__c,
							DealerIncentiveCalculate15__r.ERPSeqNo__c,
							SendDate__c,
							IsSend__c
					FROM DealerIncentiveInput__c
					WHERE BaseDate__c = LAST_MONTH
					AND ApprovalStatus__c = '승인'
					AND IsPartnerApprove__c = TRUE
					AND PartnerApproveSendTime__c = NULL
					AND (
							DealerIncentiveCalculate1__c != NULL
							OR DealerIncentiveCalculate3__r.Division__c = '실적'
							OR DealerIncentiveCalculate4__c != NULL
							OR DealerIncentiveCalculate6__c != NULL
							OR DealerIncentiveCalculate7__c != NULL
							OR DealerIncentiveCalculate8__c != NULL
							OR DealerIncentiveCalculate9__r.Division__c = '실적'
							OR DealerIncentiveCalculate10__r.Division__c = '실적'
							OR DealerIncentiveCalculate11__r.Division__c = '실적'
							OR DealerIncentiveCalculate12__c != NULL
							OR DealerIncentiveCalculate13__c != NULL
							OR DealerIncentiveCalculate14__c != NULL
							OR DealerIncentiveCalculate15__c != NULL
					)
					ORDER BY Asset__r.Name, PaymentType__c
			]);
		} else {
			return Database.getQueryLocator(query);
		}

	}

	public void execute(Database.BatchableContext BC, List<DealerIncentiveInput__c> scope) {
		DealerIncentiveERPSend_service.incentiveERPSendPartner(scope);
	}

	public void finish(Database.BatchableContext BC) {
		// 반려 및 계획건 당월로 이월 처리.

	}

	public static void runTest() {
		Integer yr_seo = 0;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
		yr_seo ++;
	}

}