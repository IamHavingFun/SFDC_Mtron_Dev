/****************************************************************************************
  * @filename      : NoticeBoardViewAdd
  * @author        : i2max_my.Seo 
  * @date          : 2020-09-09 오후 1:27
  * @group         : 
  * @group-content : 
  * @description   : 
  * @tester        : NoticeBoardViewAdd_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                     author              description
  * ===============================================================
    0.1     2020-09-09 오후 1:27     i2max_my.Seo           Create
****************************************************************************************/
public without sharing class NoticeBoardViewAdd {
    /**
     * @description init method
     *
     * @return Boolean
     */
    @AuraEnabled
    public static Boolean init(String recordId) {
        Boolean isInsert = false;
        Id currentUserId = UserInfo.getUserId();

        if([SELECT Id FROM NoticeBoardViewUser__c WHERE ViewUser__c = :currentUserId AND NoticeBoard__c = :recordId].size() == 0) {
            insert new NoticeBoardViewUser__c(ViewUser__c = currentUserId, NoticeBoard__c = recordId);
            isInsert = true;
        }

        return isInsert;
    }
}