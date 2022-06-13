/****************************************************************************************
 * @filename      :
 * @projectname   :
 * @author        : Choi SeongWon
 * @date          : 2020-06-18 오후 3:24
 * @group         :
 * @group-content :
 * @description   :
 * @tester        :
 * @reference     :
 * @copyright     : Copyright © I2max. All Rights Reserved.
 * @modification Log
 * ===============================================================
 * ver     date                     author              description
 * ===============================================================
 0.1     2020-06-13 오후 2:46      Choi SeongWon         Create
 ****************************************************************************************/
public with sharing class LsMSalesNotice {

    @AuraEnabled
    public static I2ComClass.ResData getSearch(String reqData, Integer pageSize, Integer pageNumber){

            String whereClause = ' WHERE PostDate__c <= TODAY ';
            String sortFilter = ' ORDER BY LastModifiedDate DESC ';
            I2ComClass.ResData resData = I2ComHelper.gfnQuery(
                'Id, Name, PostDate__c, CreatedDate, Content__c',
                'NoticeBoard__c',
                whereClause,
                sortFilter,
                pageSize,
                pageNumber
                );
            return resData;
    }
}