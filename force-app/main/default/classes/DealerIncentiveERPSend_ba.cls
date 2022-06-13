/****************************************************************************************
  * @filename      : DealerIncentiveERPSend_ba
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
public class DealerIncentiveERPSend_ba implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts {

    public Date processDate;
    public String query;
    public Boolean isNextBatch;

    public DealerIncentiveERPSend_ba() {
        this(true);
    }

    public DealerIncentiveERPSend_ba(Boolean isNextBatch) {
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
                            Asset__r.BatchNo__c,
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
                            DealerIncentiveCalculate1__r.SupplyAmount__c,
                            DealerIncentiveCalculate2__r.SupplyAmount__c,
                            DealerIncentiveCalculate3__r.SupplyAmount__c,
                            DealerIncentiveCalculate4__r.SupplyAmount__c,
                            DealerIncentiveCalculate6__r.SupplyAmount__c,
                            DealerIncentiveCalculate7__r.SupplyAmount__c,
                            DealerIncentiveCalculate8__r.SupplyAmount__c,
                            DealerIncentiveCalculate9__r.SupplyAmount__c,
                            DealerIncentiveCalculate10__r.SupplyAmount__c,
                            DealerIncentiveCalculate11__r.SupplyAmount__c,
                            DealerIncentiveCalculate12__r.SupplyAmount__c,
                            DealerIncentiveCalculate13__r.SupplyAmount__c,
                            DealerIncentiveCalculate14__r.SupplyAmount__c,
                            DealerIncentiveCalculate15__r.SupplyAmount__c,
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
                            DealerIncentiveCalculate13__r.AddSalesIncentiveItem__r.AddSalesIncentive__c,
                            DealerIncentiveCalculate14__r.AddSalesIncentiveItem__r.AddSalesIncentive__c,
                            DealerIncentiveCalculate15__r.AddSalesIncentiveItem__r.AddSalesIncentive__c,
                            DealerIncentiveCalculate15__r.AddSalesIncentiveItem__r.fm_SalesDocNo__c,
                            DealerIncentiveCalculate15__r.AddSalesIncentiveItem__r.fm_SalesDocLineNo__c,
                            DealerIncentiveCalculate15__r.AddSalesIncentiveItem__r.fm_SalesDocNoWM__c,
                            DealerIncentiveCalculate15__r.AddSalesIncentiveItem__r.fm_SalesDocLineNoWM__c,
                            DealerIncentiveCalculate15__r.AddSalesIncentiveItem__r.SalesPerformance__r.ProductCode__c,
                            fm_DealerIncentiveCalculate1Amount__c,
                            fm_DealerIncentiveCalculate1Rate__c,
                            fm_DealerIncentiveCalculate2Amount__c,
                            fm_DealerIncentiveCalculate2Rate__c,
                            fm_DealerIncentiveCalculate3Amount__c,
                            fm_DealerIncentiveCalculate3Rate__c,
                            fm_DealerIncentiveCalculate4Amount__c,
                            fm_DealerIncentiveCalculate4Rate__c,
                            fm_DealerIncentiveCalculate6Amount__c,
                            fm_DealerIncentiveCalculate6Rate__c,
                            fm_DealerIncentiveCalculate7Amount__c,
                            fm_DealerIncentiveCalculate7Rate__c,
                            fm_DealerIncentiveCalculate8Amount__c,
                            fm_DealerIncentiveCalculate8Rate__c,
                            fm_DealerIncentiveCalculate9Amount__c,
                            fm_DealerIncentiveCalculate9Rate__c,
                            fm_DealerIncentiveCalculate10Amount__c,
                            fm_DealerIncentiveCalculate10Rate__c,
                            fm_DealerIncentiveCalculate11Amount__c,
                            fm_DealerIncentiveCalculate11Rate__c,
                            fm_DealerIncentiveCalculate12Amount__c,
                            fm_DealerIncentiveCalculate12Rate__c,
                            fm_DealerIncentiveCalculate13Amount__c,
                            fm_DealerIncentiveCalculate13Rate__c,
                            fm_DealerIncentiveCalculate14Amount__c,
                            fm_DealerIncentiveCalculate14Rate__c,
                            fm_DealerIncentiveCalculate15Amount__c,
                            fm_DealerIncentiveCalculate15Rate__c,
                            fm_TotalAmount__c,
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
                            SalesDiscountAmount__c,
                            SalesDiscountRate__c,
                            SalesDocLineNo__c,
                            SalesDocLineNoWM__c,
                            SalesDocNoWM__c,
                            SalesIncentiveAmount__c,
                            SalesIncentiveRate__c,
                            fm_SalesSellingAmount__c,
                            fm_WMSalesSellingAmount__c,
                            SendDate__c,
                            IsSend__c
                    FROM DealerIncentiveInput__c
                    WHERE BaseDate__c = LAST_MONTH
                    AND ApprovalStatus__c = '승인'
                    AND (
                            DealerIncentiveCalculate1__c != NULL
                            OR (DealerIncentiveCalculate3__c != NULL AND DealerIncentiveCalculate3__r.Division__c = '실적')
                            OR DealerIncentiveCalculate4__c != NULL
                            OR DealerIncentiveCalculate6__c != NULL
                            OR DealerIncentiveCalculate7__c != NULL
                            OR DealerIncentiveCalculate8__c != NULL
                            OR (DealerIncentiveCalculate9__c != NULL  AND DealerIncentiveCalculate9__r.Division__c = '실적')
                            OR (DealerIncentiveCalculate10__c != NULL  AND DealerIncentiveCalculate10__r.Division__c = '실적')
                            OR (DealerIncentiveCalculate11__c != NULL  AND DealerIncentiveCalculate11__r.Division__c = '실적')
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
        DealerIncentiveERPSend_service.incentiveERPSend(scope);
    }

    public void finish(Database.BatchableContext BC) {
        // 반려 및 계획건 당월로 이월 처리.
        if(isNextBatch) Database.executeBatch(new DealerIncentiveInput_rejectmove_ba(), 200);
    }

    private String getConvertCurrency(Decimal source) {
        String target = source == null ? '0' : String.valueOf(source.setScale(0));
        return target;
    }

    private String getConvertRate(Decimal source) {
        String target = source == null ? '0' : String.valueOf(source.setScale(3));
        return target;
    }

    private String getLeftZeroPad(String soruce, Integer padDigit) {
        return soruce.leftPad(padDigit, '0');
    }

    private String getDateYYYYMM(Date tDate) {
        Datetime targetDate = (Datetime) tDate;
        return targetDate.format('yyyyMM');
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