/****************************************************************************************
 * @filename      :
 * @projectname   :
 * @author        : Choi SeongWon
 * @date          : 2020-06-23 오후 5:23
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
 0.1     2020-06-23 오후 5:23      Choi SeongWon         Create
 ****************************************************************************************/
public with sharing class LsMSalesNoticeDetail {

    @AuraEnabled
    public static DetailData init(final String recordId) {
        DetailData detailData = new DetailData();
        detailData.noticeBoard = [
                SELECT Name, PostDate__c, OwnerId, CreatedById, CreatedDate, Content__c,CreatedBy.Name
                FROM NoticeBoard__c
                WHERE Id = :recordId
        ];
        return detailData;
    }

    public class DetailData{
        @AuraEnabled public NoticeBoard__c noticeBoard {get;set;}
    }

}