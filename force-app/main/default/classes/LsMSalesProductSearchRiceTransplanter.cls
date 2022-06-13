/****************************************************************************************
  * @filename      : LsMSalesProductSearchRiceTransplanter
  * @projectname   : 
  * @author        : i2max
  * @date          : 2020-06-25
  * @group         : 
  * @group-content : 
  * @description   : 
  * @tester        : LsMSalesProductSearchRiceTransplanter_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2020-06-25         i2max          Create
****************************************************************************************/
public with sharing class LsMSalesProductSearchRiceTransplanter {

    public class InitData extends I2ComClass.InitData {
        @AuraEnabled public List<I2ComClass.Option> riceTransplanterOptions {
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
     * @param searchProduct 검색용 제품
     *
     * @return 시리즈에 대한 마력/규격 디펜던시 옵션리스트를 구함
     */
    @AuraEnabled
    public static List<I2ComClass.Option> getHorsePowerStandardOptions(final Product2 searchProduct) {
        System.debug(System.LoggingLevel.INFO, 'searchProduct :' + searchProduct);
        return I2ComDependencyUtil.getDependentPickListOptions('Product2', 'Series__c', 'HorsePowerStandard__c', searchProduct.Series__c,true, true);
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
        final String horsePowerStandard = searchProduct.HorsePowerStandard__c;

        String query = 'SELECT Id, Name,' + '\n';
        query += 'ListPrice__c, Option1__c' + '\n';
        query += 'FROM Product2' + '\n';
        query += 'WHERE isSalesAvl__c = true' + '\n';
        query += 'AND ProductType__c = :productType' + '\n';
        query += ((String.isNotBlank(series)) ? 'AND Series__c = :series' : '') + '\n';
        query += ((String.isNotBlank(horsePowerStandard)) ? 'AND HorsePowerStandard__c = :horsePowerStandard' : '') + '\n';
        query += 'ORDER BY Series__c, HorsePowerStandard__c' + '\n';

        System.debug(System.LoggingLevel.INFO, 'query :' + query);

        List<Product2> products = Database.query(query);

        return products;
    }

}