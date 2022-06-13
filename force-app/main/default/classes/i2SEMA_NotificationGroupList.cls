/****************************************************************************************
  * @filename       : i2SEMA_NotificationGroupList
  * @projectname    : i2SEMA Core
  * @author         : i2max_byeon.jw
  * @date           : 2020-05-06 오전 10:40
  * @group          : 
  * @group-content  : 
  * @description    : 
  * @tester         : i2SEMA_NotificationGroupList_Test.cls
  * @reference      : 
  * @copyright      : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                author              description
  * ===============================================================
    0.1     2020-05-06 오전 10:40     i2max_byeon.jw       Create
****************************************************************************************/

public without sharing class i2SEMA_NotificationGroupList {

    /**
     * @description Notification Group 목록 조회
     *
     * @param targetId {String} Group Target ID
     * @param pageNumber {Integer} 페이지 번호
     * @param dataSize {Integer} 페이지 당 데이터 건수
     *
     * @return {List<NotificationGroup__c>} 조회된 Notification Group
     */
    @AuraEnabled
    public static i2SEMA_ComponentResponse getNotificationGroups(String recordId, Integer pageNumber, Integer dataSize){
        Integer totalCount = [SELECT COUNT() FROM NotificationGroup__c WHERE TargetId__c =:recordId];

        // 페이지 별 Notification Group
        String selectStatement  = ' SELECT Id, Name, ru_NumberOfTotalNotification__c, ru_NumberOfTotalRequests__c, ru_NumberOfTotalComplete__c, IF_RequestedDate__c, ru_NumberOfTotalPending__c, ru_NumberOfTotalFail__c ';
        String fromStatement    = ' FROM NotificationGroup__c ';
        String whereStatement   = ' WHERE TargetId__c =:recordId AND TargetId__c != NULL';
        String orderStatement   = ' ORDER BY CreatedDate DESC ';
        String limitStatement   = ' LIMIT ' + dataSize;

        String offsetStatement  = '';
        if( pageNumber > 1 ){
            offsetStatement     = ' OFFSET ' + (pageNumber -1 ) * dataSize;
        }
        String queryString      = selectStatement + fromStatement + whereStatement + orderStatement + limitStatement + offsetStatement;


        i2SEMA_ComponentResponse response = new i2SEMA_ComponentResponse();
        response.setData( 'searchResult' , new SearchResult( totalCount , (List<NotificationGroup__c>)Database.query(queryString) ));
        return response;
    }

    public class SearchResult {
        @AuraEnabled public Integer                                 totalCount              {get;set;}
        @AuraEnabled public List<NotificationGroup__c>   notificationGroups      {get;set;}

        public SearchResult(Integer totalCount, List<NotificationGroup__c> notificationGroups){
            this.totalCount         = totalCount;
            this.notificationGroups = notificationGroups;
        }
    }
}