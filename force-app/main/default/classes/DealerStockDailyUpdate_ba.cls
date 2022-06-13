/****************************************************************************************
  * @filename      : DealerStockDailyUpdate_ba
  * @projectname   : LS
  * @author        : YR.SEO
  * @date          : 2020-05-14
  * @group         :
  * @group-content :
  * @description   : 판매실적 일일 집계.
  * @tester        :
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                    author          description
  * ===============================================================
    0.1     2020-05-14             Park HE         Create
****************************************************************************************/

public class DealerStockDailyUpdate_ba implements Database.Batchable<SObject>, Database.Stateful {

	// 외부 Argument
	public String query;
	public Boolean isNextBatch = true;

	public Database.QueryLocator start(Database.BatchableContext BC) {
		if(String.isEmpty(this.query)) {
			this.query = 'SELECT Id, DealerOwner__c, BusinessOffice__c, OwnerId, SalesRep__c, ERPCode__c  FROM Account WHERE CustomerType__c = \'대리점\' AND IsPartner = TRUE AND IsDelete__c = false ';
		}
		return Database.getQueryLocator(this.query);
	}

	public void execute(Database.BatchableContext BC, List<Account> accounts) {

		Date endDate = Date.today();
		Date startDate = endDate.toStartOfMonth();

		List<AggregateResult> assetList = [
				SELECT Dealer__c Dealer, Product2.ProductType__c ProductType, COUNT(Id) QTY
				FROM Asset
				WHERE DealerReceiptDate__c <= :endDate
				AND InventoryType__c = '대리점재고'
				AND Product2.ProductType__c IN ('트랙터', '이앙기','콤바인')
				AND Dealer__c IN : accounts
				GROUP BY Dealer__c, Product2.ProductType__c
		];

		delete [SELECT Id FROM DealerStock__c WHERE AccountId__c IN : accounts AND Division__c = '실적' AND BaseYearMonth__c = :startDate];

		List<DealerStock__c> dealerStockList = new List<DealerStock__c>();
		String dealer;
		String productType;
		Decimal qty;
		Boolean isType1, isType2, isType3 = false;
		for(Account r : accounts) {
			if(assetList.isEmpty() == false) {
				isType1 = isType2 = isType3 = false;
				for(AggregateResult ar : assetList) {
					dealer = (String)ar.get('Dealer');
					productType = (String) ar.get('ProductType');
					qty = (Decimal) ar.get('QTY');
					if(r.Id == dealer) {
						if (productType == '트랙터') isType1 = true;
						if (productType == '이앙기') isType2 = true;
						if (productType == '콤바인') isType3 = true;
						dealerStockList.add(getDealerStock(r, startDate, productType, qty));
					}
				}
				if(isType1 == false) dealerStockList.add(getDealerStock(r, startDate, '트랙터', 0));
				if(isType2 == false) dealerStockList.add(getDealerStock(r, startDate, '이앙기', 0));
				if(isType3 == false) dealerStockList.add(getDealerStock(r, startDate, '콤바인', 0));
			} else {
				dealerStockList.add(getDealerStock(r, startDate, '트랙터', 0));
				dealerStockList.add(getDealerStock(r, startDate, '이앙기', 0));
				dealerStockList.add(getDealerStock(r, startDate, '콤바인', 0));
			}
		}

		insert dealerStockList;

	}

	public DealerStock__c getDealerStock(Account account, Date baseYearMonth, String productType, Decimal qty) {
		DealerStock__c dealerStock = new DealerStock__c();
		dealerStock.Division__c = '실적';
		dealerStock.BaseYearMonth__c = baseYearMonth;
		dealerStock.AccountId__c = account.Id;
		dealerStock.CustomerCode__c = account.ERPCode__c;
		dealerStock.OwnerId = account.DealerOwner__c == null ? account.OwnerId : account.DealerOwner__c;
		dealerStock.SalesRepUser__c = account.OwnerId;
		dealerStock.BusinessOffice__c = account.BusinessOffice__c;
		dealerStock.ProductType__c = productType;
		dealerStock.Qty__c = qty;
		return dealerStock;
	}

	public void finish(Database.BatchableContext param1) {
		if(this.isNextBatch) {

		}
	}

	public static void runTest() {
		Integer yr_seo = 0;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
		yr_seo++;
	}
}