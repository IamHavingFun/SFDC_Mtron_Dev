/****************************************************************************************
  * @filename      : OrderAssetDisplayQa
  * @projectname   : 
  * @author        : i2max_my.Seo 
  * @date          : 2020-04-20 오후 2:07
  * @group         : 
  * @group-content : 
  * @description   : 
  * @tester        : OrderAssetDisplayQa_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author              description
  * ===============================================================
    0.1     2020-04-20 오후 2:07     i2max_my.Seo           Create
****************************************************************************************/
public with sharing class OrderAssetDisplayQa {
    
    /**
     * @description wrapper class for InitData
     */
    public class InitData extends I2ComClass.InitData {
        @AuraEnabled public List<I2ComClass.Option> productTypeList {
            get{
                if(this.productTypeList == null) {
                    this.productTypeList = I2ComUtil.makePickListOptions('Product2', 'ProductType__c', false, true);
                }
                return this.productTypeList;
            }
            private set;
        }
        @AuraEnabled public List<I2ComClass.Option> seriesList {
            get{
                if(this.seriesList == null) {
                    this.seriesList = I2ComUtil.makePickListOptions('Product2', 'Series__c', false, true);
                }
                return this.seriesList;
            }
            private set;
        }
    }

    /**
     * @description init method
     *
     * @return I2ComClass.InitData
     */
    @AuraEnabled
    public static I2ComClass.InitData init() {
        InitData initData = new InitData();
        return initData;
    }

    @AuraEnabled
    public static I2ComClass.ResData getSearch(String reqData, Integer pageSize, Integer pageNumber){
        String whereClause = '';
        Map<String, String> paramMap = I2ComHelper.gfnCheckCondition(reqData);

        whereClause = ' AND InventoryType__c IN (\'공장재고(QI)\', \'공장재고(가용)\') ' + '\n';

        if(I2ComHelper.gfnHasCondition(paramMap, 'productType')) {
            whereClause += ' AND Product2.ProductType__c = \'' + paramMap.get('productType') + '\'' + '\n';
        }
        if(I2ComHelper.gfnHasCondition(paramMap, 'series')) {
            whereClause += ' AND Product2.Series__c = \'' + paramMap.get('series') + '\'' + '\n';
        }
        if(I2ComHelper.gfnHasCondition(paramMap, 'name')) {
            final String likeIdioms = '\'%' + String.escapeSingleQuotes(paramMap.get('name')) + '%\'';
            whereClause += ' AND Product2.Name LIKE ' + likeIdioms + '\n';
        }

        whereClause = I2ComHelper.gfnRefineCondition(whereClause);

        I2ComClass.ResData resData = I2ComHelper.gfnQuery(
                'InventoryType__c, Product2.Name, Count(Id) ',
                'Asset',
                whereClause,
                'GROUP BY InventoryType__c, Product2.Name ',
                pageSize,
                pageNumber
        );

        return resData;
    }
}