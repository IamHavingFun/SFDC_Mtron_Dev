/****************************************************************************************
  * @filename      : TestDataBizFactory
  * @projectname   :
  * @author        : i2max_my.Seo
  * @date          : 2020-07-17 오후 2:10
  * @group         :
  * @group-content :
  * @description   : 
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author            description
  * ===============================================================
    0.1     2020-07-17 오후 2:10     i2max_my.Seo         Create
****************************************************************************************/
@IsTest
public class TestDataBizFactory {
    public static void init() {}

    /**
     * AR__c Test Data
     *
     * @param isInsert : Boolean
     *
     * @return AR__c
     */
    public static AR__c createAR(final Boolean isInsert) {
        AR__c ar = new AR__c();

        ar.CustomerCode__c      = '0000000001';
        ar.Division__c          = '실적';
        ar.ExternalId__c        = '202201_1234567890';
        ar.BaseYearMonth__c     = Date.today();

        if(isInsert) insert ar;

        return ar;
    }

    public static AR__c baseAR {get;set;}

    static {
        baseAR = createAR(true);
    }

    /**
     * ActualSales__c Test Data
     *
     * @param isInsert : Boolean
     *
     * @return ActualSales__c
     */
    public static ActualSales__c createActualSales(final Boolean isInsert) {
        ActualSales__c actualSales = new ActualSales__c();

        actualSales.CustomerCode__c      = '0000000001';
        actualSales.Division__c          = '실적';

        if(isInsert) insert actualSales;

        return actualSales;
    }

    public static ActualSales__c baseActualSales {get;set;}

    static {
        baseActualSales = createActualSales(true);
    }

    /**
     * CollectMoney__c Test Data
     *
     * @param isInsert : Boolean
     *
     * @return CollectMoney__c
     */
    public static CollectMoney__c createCollectMoney(final Boolean isInsert) {
        CollectMoney__c collectMoney = new CollectMoney__c();

        collectMoney.CustomerCode__c      = '0000000001';
        collectMoney.Division__c          = '실적';

        if(isInsert) insert collectMoney;

        return collectMoney;
    }

    public static CollectMoney__c baseCollectMoney {get;set;}

    static {
        baseCollectMoney = createCollectMoney(true);
    }

    /**
     * ContentVersion Test Data
     *
     * @param isInsert : Boolean
     *
     * @return ContentVersion
     */
    public static ContentVersion createContentVersion(final Boolean isInsert) {
        ContentVersion cv = new ContentVersion();

        cv.Title = 'test.jpg';
        cv.VersionData = Blob.valueOf('test');
        cv.PathOnClient = 'test.jpg';
        cv.ContentLocation = 'S';


        if(isInsert) insert cv;

        return cv;
    }

    public static ContentVersion baseCV {get;set;}

    static {
        baseCV = createContentVersion(true);
    }

    /**
     * DealerStock__c Test Data
     *
     * @param isInsert : Boolean
     *
     * @return DealerStock__c
     */
    public static DealerStock__c createDealerStock(final Boolean isInsert) {
        DealerStock__c dealerStock = new DealerStock__c();

        dealerStock.CustomerCode__c      = '0000000001';
        dealerStock.Division__c          = '실적';

        if(isInsert) insert dealerStock;

        return dealerStock;
    }

    public static DealerStock__c baseDealerStock {get;set;}

    static {
        baseDealerStock = createDealerStock(true);
    }

    /**
     * @param isInsert Boolean
     *
     * @return
     */
    public static Delivery__c createDelivery(final Boolean isInsert) {
        Delivery__c delivery = new Delivery__c();

        delivery.ProductCode__c = 'testProduct';
        delivery.Externalkey__c = '공장출고//////123';

        if(isInsert) insert delivery;

        return delivery;
    }

    public static Delivery__c baseDelivery {get;set;}

    static {
        baseDelivery = createDelivery(true);
    }

    /**
     * SalesPerformance__c Test Data
     *
     * @param isInsert : Boolean
     *
     * @return SalesPerformance__c
     */
    public static SalesPerformance__c createSalesPerformance(final Boolean isInsert) {
        SalesPerformance__c salesPerformance = new SalesPerformance__c();

        salesPerformance.CustomerCode__c      = '0000000001';
        salesPerformance.Division__c          = '실적';

        if(isInsert) insert salesPerformance;

        return salesPerformance;
    }

    public static SalesPerformance__c baseSalesPerformance {get;set;}

    static {
        baseSalesPerformance = createSalesPerformance(true);
    }

    /**
     * DealerArea__c Test Data
     *
     * @param isInsert : Boolean
     *
     * @return DealerArea__c
     */
    public static DealerArea__c createDealerArea(final Boolean isInsert) {
        DealerArea__c dealerArea = new DealerArea__c();

        dealerArea.Name         = '이천';
        dealerArea.Area__c      = '이천';
        dealerArea.Dealer__c    = TestDataBaseFactory.agencyAccount.Id;
        dealerArea.AreaRepYN__c = 'Y';

        if(isInsert) insert dealerArea;

        return dealerArea;
    }

    public static DealerArea__c baseDealerArea {get;set;}

    static {
        baseDealerArea = createDealerArea(true);
    }
    /**
     * MarketInfo__c Test Data
     *
     * @param isInsert : Boolean
     *
     * @return MarketInfo__c
     */
    public static MarketInfo__c createMarketInfo(final Boolean isInsert) {
        MarketInfo__c marketInfo = new MarketInfo__c();

        marketInfo.ErpCode__c   = '011';
        marketInfo.Division__c  = '계획';
        marketInfo.Area__c      = '이천';

        if(isInsert) insert marketInfo;

        return marketInfo;
    }

    public static MarketInfo__c baseMarketInfo {get;set;}

    static {
        baseMarketInfo = createMarketInfo(true);
    }

    /**
     * PDI__c Test Data
     *
     * @param isInsert : Boolean
     *
     * @return PDI__c
     */
    public static PDI__c createPDI(final Boolean isInsert) {
        PDI__c pdi = new PDI__c();

        if(isInsert) insert pdi;

        return pdi;
    }

    public static PDI__c basePDI {get;set;}

    static {
        basePDI = createPDI(true);
    }
}