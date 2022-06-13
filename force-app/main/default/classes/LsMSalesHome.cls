/****************************************************************************************
 * @filename      : LsMSalesHome
 * @projectname   :
 * @author        : SEOKHO LEE
 * @date          : 2020-06-30 오전 11:01
 * @group         :
 * @group-content :
 * @description   : [모바일] 홈
 * @tester        :
 * @reference     :
 * @copyright     : Copyright © I2max. All Rights Reserved.
 * @modification Log
 * ===============================================================
 * ver     date                     author              description
 * ===============================================================
 0.1     2020-06-30 오전 11:01        SEOKHO LEE          Create
 ****************************************************************************************/

public with sharing class LsMSalesHome {

    /**
     * init
     *
     * @return
     */
    @AuraEnabled
    public static User init() {
        User user = [
                SELECT Id, AccountId, Name, LastName, Contact.Account.Name
                FROM User
                WHERE Id = :UserInfo.getUserId()
        ];
        return user;
    }

    /**
     * getGuideCount
     *
     * @return
     */
    @AuraEnabled
    public static Integer getGuideCount() {
        Integer count = Database.countQuery('SELECT COUNT() FROM Task WHERE Type__c = \'Guide\' AND Status = \'Open\' AND IsClosed = false AND OwnerId = \''+UserInfo.getUserId()+'\' ');
        return count;
    }

}