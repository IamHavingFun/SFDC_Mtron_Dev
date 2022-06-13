/****************************************************************************************
  * @filename      : OrderOpportunitySearchQa
  * @projectname   : 
  * @author        : i2max_my.Seo 
  * @date          : 2020-04-16 오후 5:13
  * @group         : 
  * @group-content : 
  * @description   : 
  * @tester        : OrderOpportunitySearchQa_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author              description
  * ===============================================================
    0.1     2020-04-16 오후 5:13     i2max_my.Seo           Create
****************************************************************************************/
public with sharing class OrderOpportunitySearchQa {

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

    @AuraEnabled
    public static I2ComClass.InitData init() {
        InitData initData = new InitData();
        return initData;
    }

    @AuraEnabled
    public static I2ComClass.ResData getSearch(String reqData, Integer pageSize, Integer pageNumber){
        Set<Id> opportunityIdSet = new Set<Id>();
        List<Integer> targetIndexList = new List<Integer>();

        for(Opportunity opportunity : [
                SELECT Id
                FROM Opportunity
                WHERE Id NOT IN (
                        SELECT Opportunity__c
                        FROM Order__c
                        WHERE Opportunity__c != NULL
                        AND isOrderCancel__c = FALSE
                )
        ]) {
            opportunityIdSet.add(opportunity.Id);
        }

        String whereClause = '';
        Map<String, String> paramMap = I2ComHelper.gfnCheckCondition(reqData);

        whereClause = ' AND Contract__r.Opportunity__r.StageName IN (\'계약\') AND Contract__r.eFormsignStatus__c = \'계약체결\'  ';

        if(I2ComHelper.gfnHasCondition(paramMap, 'productType')) {
            whereClause += ' AND ProductId__r.ProductType__c = \'' + paramMap.get('productType') + '\'' + '\n';
        }
        if(I2ComHelper.gfnHasCondition(paramMap, 'series')) {
            whereClause += ' AND ProductId__r.Series__c = \'' + paramMap.get('series') + '\'' + '\n';
        }
        if(I2ComHelper.gfnHasCondition(paramMap, 'name')) {
            final String likeIdioms = '\'%' + String.escapeSingleQuotes(paramMap.get('name')) + '%\'';
            whereClause += ' AND Contract__r.Opportunity__r.Name LIKE ' + likeIdioms + '\n';
        }
        if(I2ComHelper.gfnHasCondition(paramMap, 'dealerId')) {
            // 대리점 정보가 있는 경우.
            whereClause += ' AND Contract__r.Opportunity__r.Dealer__c = \'' + paramMap.get('dealerId') + '\'' + '\n';

        }
        if(I2ComHelper.gfnHasCondition(paramMap, 'productId')) {
            // 제품 정보가 있는 경우.
            whereClause += ' AND ProductId__c = \'' + paramMap.get('productId') + '\'' + '\n';
        }

        //if(!Test.isRunningTest()) whereClause += ' AND Contract__r.Opportunity__c IN ' + JSON.serialize(opportunityIdSet).replace('[', '(').replace(']', ')').replace('"', '\'') + '\n';

        whereClause = I2ComHelper.gfnRefineCondition(whereClause);

        I2ComClass.ResData resData = I2ComHelper.gfnQuery(
                'Id, Contract__r.Opportunity__r.Name, Contract__r.Opportunity__r.AccountId, Contract__r.Opportunity__r.Account.Name, Contract__r.Opportunity__r.CloseDate, ' +
                      'Contract__r.Opportunity__r.StageName, Contract__r.Opportunity__r.Owner.Name, Contract__r.CustomerExpectedDate__c, ' +
                      'ProductId__c, ProductId__r.ProductDivision__c, ProductId__r.ProductCode, ProductId__r.HorsePowerStandard__c, ProductId__r.Name, ProductId__r.Type__c, ProductId__r.ListPrice__c, ProductId__r.DealerListPrice__c, ProductId__r.ProductDivFeeRate__c',
                'ContractLineItem__c',
                whereClause,
                null,
                pageSize,
                pageNumber
        );

        return resData;
    }

    /**
     * @description 수수료 계산 결과 리턴 하는 method.
     *
     * @param wrapperData : OrderNewQa.WrapperData
     *
     * @return OrderNewQa.WrapperData
     */
    @AuraEnabled
    public static OrderNewQa.WrapperData calculatePrice(OrderNewQa.WrapperData wrapperData) {
        return OrderService.calculatePrice(wrapperData);
    }
}