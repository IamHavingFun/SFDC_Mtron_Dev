/****************************************************************************************
  * @filename      : User_tr
  * @projectname   :
  * @author        : i2max
  * @date          : 2020-05-06
  * @group         :
  * @group-content :
  * @description   : 사용자 trigger class
  * @tester        : User_tr_ts.cls
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2020-05-06         i2max          Create
****************************************************************************************/
public with sharing class User_tr extends TriggerHandler {
    static Boolean bypass = false;                           // 재귀 호출 방지 boolean
    Map<Id, SObject> newSetMaps = new Map<Id, User>();    // Trigger.newMap
    Map<Id, SObject> oldSetMaps = new Map<Id, User>();    // Trigger.oldMap
    List<User> newSetData;                                // Trigger.new
    List<User> oldSetData;                                // Trigger.old
    Map<Id, RecordType> recordTypeData;                      // Record Type 데이터 Map

    // 생성자
    public User_tr(){
        newSetMaps = Trigger.newMap;    // Trigger.newMap
        oldSetMaps = Trigger.oldMap;    // Trigger.oldMap
        newSetData = Trigger.new;       // Trigger.new
        oldSetData = Trigger.old;       // Trigger.old
//        this.setMaxLoopCount(10);      // MaxLoopCount 설정
    }
    private static Map<Id, Profile> partnerProfileMap {get;set;}
    static {
        partnerProfileMap = new Map<Id, Profile>(
            [SELECT Id, Name FROM Profile WHERE Name IN ('Korea Partner Community User', '파트너 사용자')]
        );
    }

    public override void afterInsert() {
        this.setAccountDealerOwner(Trigger.new);
    }

    public override void afterUpdate() {
        this.setAccountDealerOwner(Trigger.new);
    }

    /**
     * 대리점 Account에 대리점주 지정.
     *
     * @param scope
     */
    private void setAccountDealerOwner(List<User> scope) {
        for(User r : scope)  User_tr.setAccountDealerOwnerFuture(r.Id);
    }

    @Future
    public static void setAccountDealerOwnerFuture(Id userId) {
        Map<Id, User> userContactMap = new Map<Id, User>();

        for(User r : [SELECT Id, IsActive, ProfileId, ContactId FROM User WHERE Id = :userId]) {
            // 파트너 유저 + 활성 상태
            if(r.IsActive == true && partnerProfileMap.containsKey(r.ProfileId)) {
                userContactMap.put(r.ContactId, r);
            }
        }
        Map<Id, Contact> accountDealerOwnerMap = new Map<Id, Contact>();
        for(Contact r : [
                SELECT Id, AccountId, Account.DealerOwner__c
                FROM Contact
                WHERE Id IN :userContactMap.keySet()
                AND DealerRole__c = '대표'
        ]) {
            accountDealerOwnerMap.put(r.Id, r);
        }
        List<Account> dealerOwnerUpdateAccounts = new List<Account>();
        for(Id contactId : userContactMap.keySet()) {
            if(accountDealerOwnerMap.containsKey(contactId)) {
                // 대리점의 사용자랑, 대리점 Account에 있는 대리점주랑 같은지 체크.
                if(accountDealerOwnerMap.get(contactId).Account.DealerOwner__c != userContactMap.get(contactId).Id) {
                    dealerOwnerUpdateAccounts.add(
                            new Account(
                                    Id = accountDealerOwnerMap.get(contactId).AccountId,
                                    DealerOwner__c = userContactMap.get(contactId).Id
                            )
                    );
                }
            }
        }
        if(dealerOwnerUpdateAccounts.isEmpty() == false) {
            if(Test.isRunningTest() == false) update dealerOwnerUpdateAccounts;
        }
    }
}