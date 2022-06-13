/****************************************************************************************
  * @filename      : ModelUser
  * @projectname   : 
  * @author        : i2max
  * @date          : 2020-05-08
  * @group         : 
  * @group-content : 
  * @description   : 
  * @tester        : ModelUser_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2020-05-08         i2max          Create
    0.2     2020-05-08         i2max          community  사용자의 Account 정보 조회시 에러로
                                              without 으로 변경처리
****************************************************************************************/
public without sharing class ModelUser {

    /*
     * ================================================================
     * User 정보 Properties 구성
     * ================================================================
     */

    @AuraEnabled
    public User user {get;set;}

    public ModelUser(User user) {
        this.user = user;
    }

    /**
     * @description 현재 login한 유저의 정보를 return.
     *
     * @return User
     */
    public static User getUserData() {
        // 필요 필드 추가.
        return [
            SELECT Id, Contact.AccountId,
                   AccountId, Account.OwnerId, Account.Name, Account.ParentId, Account.Parent.OwnerId, Account.DealerDivision__c, Account.ServiceCapabilityClass__c,
                   Account.BusinessOffice__c, Account.BusinessOfficeName__c, BusinessOffice__c, Account.BusinessOffice__r.SalesGroupCode__c
            FROM User
            WHERE Id = :UserInfo.getUserId()
        ];
    }

    /**
     * @description 대리점의 대리점주 역할이 대표인 user의 Id 반환
     *
     * @param accountId 대리점의 id
     *
     * @return String (Id)
     */
    public static String getDealerUserId(String accountId) {
        List<User> userList = new List<User>();

        if(String.isNotBlank(accountId)) {
            userList = [
                    SELECT Id
                    FROM User
                    WHERE Contact.Account.Id = :accountId
                    AND Contact.DealerRole__c = '대표'
                    LIMIT 1
            ];
        }

        return (userList.size() > 0) ? userList[0].Id : null;
    }
}