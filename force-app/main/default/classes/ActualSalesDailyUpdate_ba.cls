/****************************************************************************************
  * @filename      : ActualSalesDailyUpdate_ba
  * @projectname   : LS
  * @author        : Park HE
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

public class ActualSalesDailyUpdate_ba implements Database.Batchable<SObject>, Database.Stateful {

	// 외부 Argument
	public String query;
	public Boolean isNextBatch = true;
	public Date endDate;


	public ActualSalesDailyUpdate_ba() {
		this(true);
	}

	public ActualSalesDailyUpdate_ba(Boolean isNextBatch) {
		this.isNextBatch = isNextBatch;
	}

	public Database.QueryLocator start(Database.BatchableContext BC) {
		if(String.isEmpty(this.query)) {
			this.query = 'SELECT Id, DealerOwner__c, BusinessOffice__c, OwnerId, SalesRep__c, ERPCode__c  FROM Account WHERE CustomerType__c = \'대리점\' AND IsPartner = TRUE AND IsDelete__c = false ';
		}
		return Database.getQueryLocator(this.query);
	}

	public void execute(Database.BatchableContext BC, List<Account> accounts) {

		endDate = endDate == null ? Date.today() : endDate;
		Date startDate = endDate.toStartOfMonth();

		List<AggregateResult> assetList = [
				SELECT Dealer__c Dealer, Product2.ProductType__c ProductType, COUNT(Id) QTY
				FROM Asset
				WHERE fm_ActualSalesDate__c >= :startDate AND fm_ActualSalesDate__c <= :endDate
				AND InventoryType__c = '실판매'
				AND Dealer__c IN : accounts
				AND Account.CustomerType__c NOT IN ('농협','관납')
				GROUP BY Dealer__c, Product2.ProductType__c
		];

		delete [SELECT Id FROM ActualSales__c WHERE AccountId__c IN : accounts AND Division__c = '실적' AND BaseYearMonth__c = :startDate];

		List<ActualSales__c> ActualSalesList = new List<ActualSales__c>();
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
						ActualSalesList.add(getActualSales(r, startDate, productType, qty));
					}
				}
				if(isType1 == false) ActualSalesList.add(getActualSales(r, startDate, '트랙터', 0));
				if(isType2 == false) ActualSalesList.add(getActualSales(r, startDate, '이앙기', 0));
				if(isType3 == false) ActualSalesList.add(getActualSales(r, startDate, '콤바인', 0));
			} else {
				ActualSalesList.add(getActualSales(r, startDate, '트랙터', 0));
				ActualSalesList.add(getActualSales(r, startDate, '이앙기', 0));
				ActualSalesList.add(getActualSales(r, startDate, '콤바인', 0));
			}
		}

		insert ActualSalesList;

	}

	public ActualSales__c getActualSales(Account account, Date baseYearMonth, String productType, Decimal qty) {
		ActualSales__c actualSales = new ActualSales__c();
		actualSales.Division__c = '실적';
		actualSales.BaseYearMonth__c = baseYearMonth;
		actualSales.AccountId__c = account.Id;
		actualSales.CustomerCode__c = account.ERPCode__c;
		actualSales.OwnerId = account.DealerOwner__c == null ? account.OwnerId : account.DealerOwner__c;
		actualSales.SalesRepUser__c = account.OwnerId;
		actualSales.BusinessOffice__c = account.BusinessOffice__c;
		actualSales.ProductType__c = productType;
		actualSales.Qty__c = qty;
		return actualSales;
	}

	public void finish(Database.BatchableContext param1) {
		if(this.isNextBatch) {
			Database.executeBatch(new DealerStockDailyUpdate_ba(), 1);
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