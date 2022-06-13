/****************************************************************************************
  * @filename      : LsMSalesProductSearchCombine
  * @projectname   : 
  * @author        : i2max
  * @date          : 2020-06-24
  * @group         : 
  * @group-content : 
  * @description   : 
  * @tester        : LsMSalesProductSearchCombine_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2020-06-24         i2max          Create
****************************************************************************************/
public with sharing class LsMSalesProductSearchCombine {

    public class InitData extends I2ComClass.InitData {
        @AuraEnabled public List<I2ComClass.Option> combineOptions {
            get {
                return I2ComDependencyUtil.getDependentPickListOptions('Product2', 'ProductType__c', 'Series__c', this.searchProduct.ProductType__c, true, true);
            }
            set;
        }

        private Product2 searchProduct {get;set;}

        public InitData(final Product2 searchProduct) {
            this.searchProduct = searchProduct;
        }
    }

    @AuraEnabled(Cacheable=true)
    public static InitData init(final Product2 searchProduct) {

        System.debug(System.LoggingLevel.INFO, 'searchProduct :' + searchProduct);

        InitData initData = new InitData(searchProduct);
        return initData;
    }

    /**
     * 콤바인 제품 리스트 조회
     *
     * @param searchProduct 검색용 제품
     *
     * @return List<Product2>
     */
    @AuraEnabled
    public static List<Product2> search(final Product2 searchProduct) {
        System.debug(System.LoggingLevel.INFO, 'searchProduct :' + searchProduct);

        final String productType = searchProduct.ProductType__c;
        final String series = searchProduct.Series__c;

        String query = 'SELECT Id, Name,' + '\n';
        query += 'ListPrice__c, DealerListPrice__c, Option1__c, Option2__c, Option3__c, Option4__c' + '\n';
        query += 'FROM Product2' + '\n';
        query += 'WHERE isSalesAvl__c = true' + '\n';
        query += 'AND ProductType__c = :productType' + '\n';
        query += ((String.isNotBlank(series)) ? 'AND Series__c = :series' : '') + '\n';
        query += 'ORDER BY Series__c' + '\n';

        System.debug(System.LoggingLevel.INFO, 'query :' + query);

        List<Product2> products = Database.query(query);

        return products;
    }

}