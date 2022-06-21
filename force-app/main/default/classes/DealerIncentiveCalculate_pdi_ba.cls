/****************************************************************************************
  * @filename      : DealerIncentiveCalculate_pdi_ba
  * @projectname   :
  * @author        : i2max_my.Seo
  * @date          : 2020-08-18 오전 9:08
  * @group         :
  * @group-content :
  * @description   : 판매장려 산출 - PDI 대상
        PDI 등록  대리점 ALL 전략  PDI 등록  10% (지급수수료:대리점용역)
                    실속  PDI 등록
                    경제  PDI 등록  6%
                    도입  PDI 등록  4%


        (지급수수료:CS위탁)"
                    도입  PDI 등록  5%
                    실속  PDI 등록
                    이앙기 PDI 등록
                    콤바인 PDI 등록
                    경제  PDI 등록
                    MINI    PDI 등록  10만원
        농협사후봉사  농협      개별 Record   PDI 등록  정액  "6310318
        (지급수수료:CS위탁)"
        중개영업지원  농협      개별 Record   PDI 등록  정액  "6310318
        (지급수수료:CS위탁)"

  *
  * @tester        : DealerIncentiveCalculate_pdi_ba_ts.cls
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author              description
  * ===============================================================
    0.1     2020-08-18 오전 9:08     i2max_my.Seo           Create
****************************************************************************************/
public class DealerIncentiveCalculate_pdi_ba implements Database.Batchable<SObject>, Database.Stateful {

    public Date processDate;
    public String query;
    public Boolean isNextBatch;

    public DealerIncentiveCalculate_pdi_ba() {
        this(true);
    }

    public DealerIncentiveCalculate_pdi_ba(Boolean isNextBatch) {
        this.isNextBatch = isNextBatch;
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        if(processDate == null) processDate = Date.today().addDays(-1);

        if(String.isEmpty(query)) {
            return Database.getQueryLocator([
                    SELECT Id, Name, BatchNo__c,
                            DealerReceiptDate__c,
                            SalesDate__c,
                            PDI__r.HandoverDate__c,
                            Account.CustomerType__c,
                            Account.BrokeringDealer__c,
                            Account.BrokeringDealer__r.ERPCode__c,
                            Account.ERPCode__c,
                            Dealer__c,
                            Dealer__r.ERPCode__c,
                            Dealer__r.DealerDivision__c,
                            Product2.ProductDivision__c,
                            Product2.NhFeeAmt__c,
                            Product2.BorkerFeeAmount__c,
                            Order__r.SalesDocNo__c,
                            Order__r.ErpPOSNR__c,
                            Order__r.PriceDecisionDate__c,
                            Order__r.ru_SellingPrice__c,
                    (
                            SELECT Id
                            FROM Delivery__r
                            WHERE DAY_ONLY(DateOfLoading__c) > 2022-01-31
                            LIMIT 1
                    )
                    FROM Asset
                    WHERE SalesDate__c = YESTERDAY
                    AND InventoryType__c = '실판매'
            ]);
        } else {
            return Database.getQueryLocator(query);
        }

    }

    public void execute(Database.BatchableContext BC, List<Asset> scope) {
        List<Asset> customScope = new List<Asset>();
        Date checkReceiptDate = Date.newInstance(2021,12,31);
        for(Asset r : scope) {
            if(r.DealerReceiptDate__c > checkReceiptDate) {
                customScope.add(r);
            } else {
                // 보관재고 이관 건 에 대한 처리.
                if(r.Delivery__r != null && r.Delivery__r.isEmpty() == false) {
                    customScope.add(r);
                }
            }
            System.debug('기대번호 : '+ r.Name);
        }
        DealerIncentiveCalculate_com_ba.DealerIncentiveCalculate_pdi_ba(customScope, processDate);
    }

    public void finish(Database.BatchableContext BC) {
        if(isNextBatch) Database.executeBatch(new DealerIncentiveCalculate_salesiq_ba(), 1);
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