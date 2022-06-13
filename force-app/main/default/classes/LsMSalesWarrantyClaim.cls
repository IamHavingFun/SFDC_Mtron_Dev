/****************************************************************************************
 * @filename      : LsMSalesWarrantyClaim
 * @projectname   : 
 * @author        : SEOKHO LEE
 * @date          : 2020-06-19 오후 2:07
 * @group         :
 * @group-content :
 * @description   : [모바일] LWS클레임
 * @tester        :
 * @reference     :
 * @copyright     : Copyright © I2max. All Rights Reserved.
 * @modification Log
 * ===============================================================
 * ver     date                     author              description
 * ===============================================================
 0.1     2020-06-19 오후 2:07        SEOKHO LEE          Create
 ****************************************************************************************/

public with sharing class LsMSalesWarrantyClaim {

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
    public static I2ComClass.ResData search(String reqData, Integer pageSize, Integer pageNumber) {

        System.debug(System.LoggingLevel.INFO, reqData);

        String whereClause = '';
        Map<String, String> paramMap = I2ComHelper.gfnCheckCondition(reqData);

        whereClause += 'WHERE Status__c = \'정상\' ';
        
        // 로그인 사용자의 대리점
        whereClause += (ModelUser.getUserData().AccountId != null) ?  'AND Dealer__c = ' + '\'' + ModelUser.getUserData().AccountId + '\'' : '';
        
        if(I2ComHelper.gfnHasCondition(paramMap, 'searchBox')) {
            whereClause += ' AND (Name LIKE \'%' + paramMap.get('searchBox') + '%\'' + '\n';
            whereClause += ' OR AssetId__r.Name LIKE \'%' + paramMap.get('searchBox') + '%\')' + '\n';
        }

        whereClause = I2ComHelper.gfnRefineCondition(whereClause);
        System.debug('whereClause : ' + whereClause);

        I2ComClass.ResData resData = I2ComHelper.gfnQuery(
                'Id, Name, ProductId__c, ProductId__r.Name, AssetId__c, AssetId__r.Name, AssetId__r.WtyStartDate__c, AssetId__r.WtyEndDate__c, Customer__c, LWSRegDate__c, Customer__r.LastName, Customer__r.Name, ClaimResult__c, ClaimStatus__c, CreatedDate, fm_ProductCode__c, LastModifiedDate',
                'WarrantyClaim__c',
                whereClause,
                'ORDER BY LastModifiedDate DESC',
                pageSize,
                pageNumber
        );

        System.debug(resData);
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