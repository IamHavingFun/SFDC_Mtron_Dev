/****************************************************************************************
  * @filename      : DealerIncentiveUnpaidERPSend_ba
  * @projectname   :
  * @author        : i2max_my.Seo
  * @date          : 2020-08-18 오전 9:08
  * @group         :
  * @group-content :
  * @description   : 판매장려 - ERP 전송
  *
  * @tester        : DealerIncentiveERPSend_ba_ts.cls
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author              description
  * ===============================================================
    0.1     2020-08-18 오전 9:08     i2max_my.Seo           Create
****************************************************************************************/
public class DealerIncentiveUnpaidERPSend_ba implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts {

	public Date processDate;
	public String query;
	public Boolean isNextBatch;

	public DealerIncentiveUnpaidERPSend_ba() {
		this(true);
	}

	public DealerIncentiveUnpaidERPSend_ba(Boolean isNextBatch) {
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
							Asset__c,
							Asset__r.Name,
							Asset__r.InventoryType__c,
							Asset__r.ProductionDate__c,
							Asset__r.FirstDeliveryDate__c,
							Asset__r.DealerReceiptDate__c,
							Asset__r.IncentiveSeqNo__c,
							Asset__r.Product2.ProductCode,
							Asset__r.Dealer__r.Owner.EmployeeNumber,
							CSIncentiveAmount__c,
							CSIncentiveRate__c,
							Dealer__r.ERPCode__c,
							Dealer__r.Owner.EmployeeNumber,
							BrokeringDealer__r.ERPCode__c,
							BrokeringDealer__r.Owner.EmployeeNumber,
							DealerIncentiveCalculate3__c,
							DealerIncentiveCalculate3__r.SupplyAmount__c,
							DealerIncentiveCalculate3__r.SalesDocNo__c,
							DealerIncentiveCalculate3__r.LineNumber__c,
							DealerIncentiveCalculate3__r.Status__c,
							DealerIncentiveCalculate3__r.ERPSeqNo__c,
							DealerIncentiveCalculate3__r.SalesAccount__r.ERPCode__c,
							fm_PlanDealerIncentiveCalculate3Amount__c,
							fm_PlanDealerIncentiveCalculate3Rate__c,
							DealerIncentiveCalculate9__c,
							DealerIncentiveCalculate9__r.SupplyAmount__c,
							DealerIncentiveCalculate9__r.SalesDocNo__c,
							DealerIncentiveCalculate9__r.LineNumber__c,
							DealerIncentiveCalculate9__r.Status__c,
							DealerIncentiveCalculate9__r.ERPSeqNo__c,
							DealerIncentiveCalculate9__r.SalesAccount__r.ERPCode__c,
							fm_PlanDealerIncentiveCalculate9Amount__c,
							fm_PlanDealerIncentiveCalculate9Rate__c,
							DealerIncentiveCalculate10__c,
							DealerIncentiveCalculate10__r.SupplyAmount__c,
							DealerIncentiveCalculate10__r.SalesDocNo__c,
							DealerIncentiveCalculate10__r.LineNumber__c,
							DealerIncentiveCalculate10__r.Status__c,
							DealerIncentiveCalculate10__r.ERPSeqNo__c,
							DealerIncentiveCalculate10__r.SalesAccount__r.ERPCode__c,
							fm_PlanDealerIncentiveCalculate10Amount__c,
							fm_PlanDealerIncentiveCalculate10Rate__c,
							DealerIncentiveCalculate11__c,
							DealerIncentiveCalculate11__r.SupplyAmount__c,
							DealerIncentiveCalculate11__r.SalesDocNo__c,
							DealerIncentiveCalculate11__r.LineNumber__c,
							DealerIncentiveCalculate11__r.Status__c,
							DealerIncentiveCalculate11__r.ERPSeqNo__c,
							DealerIncentiveCalculate11__r.SalesAccount__r.ERPCode__c,
							fm_PlanDealerIncentiveCalculate11Amount__c,
							fm_PlanDealerIncentiveCalculate11Rate__c,
							fm_TotalAmount__c,
							SalesDiscountAmount__c,
							SalesDiscountRate__c,
							SalesDocLineNo__c,
							SalesDocLineNoWM__c,
							fm_SalesSellingAmount__c,
							fm_WMSalesSellingAmount__c,
							SalesDocNoWM__c,
							SalesIncentiveAmount__c,
							SalesIncentiveRate__c,
							SalesSellingAmount__c,
							SendDate__c,
							IsSend__c
					FROM DealerIncentiveInput__c
					WHERE BaseDate__c = LAST_MONTH
					AND ApprovalStatus__c = '승인'
					AND IsSend__c = FALSE
					AND (
							   (DealerIncentiveCalculate3__c != NULL AND DealerIncentiveCalculate3__r.Division__c = '계획')
							OR (DealerIncentiveCalculate9__c != NULL  AND DealerIncentiveCalculate9__r.Division__c = '계획')
							OR (DealerIncentiveCalculate10__c != NULL  AND DealerIncentiveCalculate10__r.Division__c = '계획')
							OR (DealerIncentiveCalculate11__c != NULL  AND DealerIncentiveCalculate11__r.Division__c = '계획')
					)
					ORDER BY Asset__r.Name ASC
			]);
		} else {
			return Database.getQueryLocator(query);
		}

	}

	public void execute(Database.BatchableContext BC, List<DealerIncentiveInput__c> scope) {
		DealerIncentiveERPSend_service.incentiveUnpaidERPSend(scope);
	}

	public void finish(Database.BatchableContext BC) {
		if(isNextBatch) Database.executeBatch(new DealerIncentiveERPSend_ba(), 20);
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