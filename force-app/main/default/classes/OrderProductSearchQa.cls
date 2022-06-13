/****************************************************************************************
  * @filename      : OrderProductSearchQa
  * @projectname   : 
  * @author        : i2max_my.Seo 
  * @date          : 2020-04-16 오후 1:13
  * @group         : 
  * @group-content : 
  * @description   : 
  * @tester        : OrderProductSearchQa_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author              description
  * ===============================================================
    0.1     2020-04-16 오후 1:13     i2max_my.Seo           Create
****************************************************************************************/
public with sharing class OrderProductSearchQa {

    /**
     * @description wrapper class for InitData
     */
    public class InitData extends I2ComClass.InitData {
        @AuraEnabled public List<I2ComClass.Option> seriesList {get;set;}
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

    /**
     * @description search method
     *
     * @param reqData       Map
     * @param pageSize      Integer
     * @param pageNumber    Integer
     *
     * @return I2ComClass.ResData
     */
    @AuraEnabled
    public static I2ComClass.ResData getSearch(String reqData, Integer pageSize, Integer pageNumber){
        String whereClause = '';
        Map<String, String> paramMap = I2ComHelper.gfnCheckCondition(reqData);

        whereClause = ' AND Type__c = \'본체\' AND isOrderAvl__c = true ' + '\n';

        if(I2ComHelper.gfnHasCondition(paramMap, 'productType')) {
            whereClause += ' AND ProductType__c = \'' + paramMap.get('productType') + '\'' + '\n';
        }
        if(I2ComHelper.gfnHasCondition(paramMap, 'series')) {
            whereClause += ' AND Series__c = \'' + paramMap.get('series') + '\'' + '\n';
        }
        if(I2ComHelper.gfnHasCondition(paramMap, 'name')) {
            final String likeIdioms = '\'%' + String.escapeSingleQuotes(paramMap.get('name')) + '%\'';
            whereClause += ' AND Name LIKE ' + likeIdioms + '\n';
        }
        if(I2ComHelper.gfnHasCondition(paramMap, 'dealerId')) {
            // 대리점 정보가 있는 경우.
        }
        if(I2ComHelper.gfnHasCondition(paramMap, 'productId')) {
            // 제품 정보가 있는 경우.
        }

        whereClause = I2ComHelper.gfnRefineCondition(whereClause);

        I2ComClass.ResData resData = I2ComHelper.gfnQuery(
                'DealerListPrice__c, ListPrice__c, ProductCode, ProductDivision__c, HorsePowerStandard__c, Name, Type__c, GovListPrice__c, NhListPrice__c, GovFeeRate__c, NhFeeAmt__c, Series__c, ProductDivFeeRate__c ',
                'Product2',
                whereClause,
                'ORDER BY Name',
                pageSize,
                pageNumber
        );

        return resData;
    }

    /**
     * 수수료 계산 결과 리턴 하는 method.
     *
     * @param wrapperData : OrderNewQa.WrapperData
     *
     * @return OrderNewQa.WrapperData
     */
    @AuraEnabled
    public static OrderNewQa.WrapperData calculatePrice(OrderNewQa.WrapperData wrapperData) {
        return OrderService.calculatePrice(wrapperData);
    }

    /**
     * 농협/관납 수수료 계산 결과 리턴 method.
     *
     * @param wrapperData : OrderNewQa.WrapperData
     * @param isGov       : 관납 여부
     *
     * @return OrderNewQa.WrapperData
     */
    @AuraEnabled
    public static OrderNewQa.WrapperData calculatePriceForNhGov(OrderNewQa.WrapperData wrapperData) {
        return OrderService.calculateResultPriceForNhGov(wrapperData);
    }

    @AuraEnabled
    public static List<I2ComClass.Option> getProductSeriesList(String productType) {
        return OrderService.getProductSeriesList(productType);
    }
}