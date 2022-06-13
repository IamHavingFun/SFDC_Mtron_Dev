/****************************************************************************************
  * @filename      : lsMSalesDesignChange
  * @projectname   : LS
  * @author        : Park JW
  * @date          : 2020-06-29 오전 9:01
  * @group         : 
  * @group-content : 
  * @description   : 
  * @tester        : 
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                      author          description
  * ===============================================================
    0.1     2020-06-29 오전 9:01           Park JW         Create
****************************************************************************************/

public with sharing class lsMSalesDesignChange {
    public class InitData extends I2ComClass.InitData {
    }

    @AuraEnabled
    public static I2ComClass.InitData init() {
        InitData initData = new InitData();
        return initData;
    }

    /**
     * 검색
     *
     * @param reqData
     * @param pageSize
     * @param pageNumber
     *
     * @return
     */
    @AuraEnabled
    public static I2ComClass.ResData search(String reqData, Integer pageSize, Integer pageNumber){

        System.debug(System.LoggingLevel.INFO, reqData);

        String whereClause = 'WHERE SetDealerPublic__c = \'공개\' ';
        Map<String, String> paramMap = I2ComHelper.gfnCheckCondition(reqData);

        if(I2ComHelper.gfnHasCondition(paramMap, 'productName')) {
            whereClause += ' AND  Id IN (SELECT ProductChangeId__c FROM ProductChangeModel__c WHERE ProductId__r.Name Like \'%' + paramMap.get('productName') + '%\'' + ')\n';
        }

        whereClause = I2ComHelper.gfnRefineCondition(whereClause);
        System.debug('whereClause : ' + whereClause);

        I2ComClass.ResData resData = I2ComHelper.gfnQuery(
                'Id, Name, PECN_NAME__c, PREGISTRATION_DATE__c ',
                'ProductChange__c',
                whereClause,
                'ORDER BY PREGISTRATION_DATE__c DESC',
                pageSize,
                pageNumber
        );

        return resData;
    }

    /**
     * search가 아닌 다른 메소드명 호출 테스트
     * client controller 와 Name이 동일하면 안됨
     *
     * @param reqData
     * @param pageSize
     * @param pageNumber
     *
     * @return
     */
    @AuraEnabled
    public static I2ComClass.ResData getSearch(String reqData, Integer pageSize, Integer pageNumber){
        return search(reqData, pageSize, pageNumber);
    }
}