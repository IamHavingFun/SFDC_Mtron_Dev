/**
 * Created by ms on 2020-03-31.
 */

public with sharing class Account_tr extends TriggerHandler{
    static Boolean bypass = false;                           // 재귀 호출 방지 boolean
    Map<Id, sObject> newSetMaps = new Map<Id, Account>();    // Trigger.newMap
    Map<Id, sObject> oldSetMaps = new Map<Id, Account>();    // Trigger.oldMap
    List<Account> newSetData;                                // Trigger.new
    List<Account> oldSetData;                                // Trigger.old
    Map<Id, RecordType> recordTypeData;                      // Record Type 데이터 Map

    // 생성자
    public Account_tr(){
        newSetMaps = Trigger.newMap;    // Trigger.newMap
        oldSetMaps = Trigger.oldMap;    // Trigger.oldMap
        newSetData = Trigger.new;       // Trigger.new
        oldSetData = Trigger.old;       // Trigger.old
        recordTypeData = new Map<Id, RecordType>([
                SELECT  id, Name, DeveloperName
                FROM    RecordType
                WHERE   SobjectType = 'Account'
                AND IsActive = TRUE
        ]);  // Record Type 데이터 SOQL

//        this.setMaxLoopCount(10);      // MaxLoopCount 설정
    }

    //-------------------------------------------------------
    // override methods
    //-------------------------------------------------------
    public override void beforeInsert() {
        this.SetDealerOwner(Trigger.new, Trigger.oldMap);
    }

    public override void beforeUpdate() {
        this.SetDealerOwner(Trigger.new, Trigger.oldMap);
    }



    /**
     * Account 에 대리점주를 지정
     * - 대리점의 대리점주는 = User에서 처리.
     * - 개인 영농법인, 농협, 관납은 수식으로 Dealer__c 의 대리점주 값을 가져와서 처리.
         * 0121m000000ANtkAAG	관납/농협	    BusinessAccount1    - Y
         * 0121m000000AOdWAAW	개인/영농법인	PersonAccount       - Y
         * 0121m000000Ai5TAAS	영업소	        BusinessAccount2    - N
         * 0121m000000BFZwAAO	대리점	        BusinessAccount3    - Y
         * 0121m000000PJe1AAG	기타 고객	    OtherAccount        - Y
     * @param scope
     * @param oldMap
     */
    private void SetDealerOwner(List<Account> scope, Map<Id, SObject> oldMap) {
        Set<Id> dealerAccountIds = new Set<Id>();

        // 대상 레코드 타입.
        Set<Id> targetRecordTypeIds = new Set<Id>();
        for(RecordType r : [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND IsActive = TRUE AND DeveloperName = 'BusinessAccount3']) {
            targetRecordTypeIds.add(r.Id);
        }
        for(Account r : scope) {
            if(targetRecordTypeIds.contains(r.RecordTypeId) && oldMap != null) {
                Account oldAccount = (Account) oldMap.get(r.Id);
                if(r.DealerOwner__c != oldAccount.DealerOwner__c) {
                    dealerAccountIds.add(r.Id);
                }
            }
        }

        // 대리점 주 처리 대상이 있는것만 처리.
        Map<String, Id> dealerOwnerMap = new Map<String, Id>();
        for (User u : [
                SELECT Id, Contact.AccountId
                FROM User
                WHERE Contact.AccountId IN :dealerAccountIds
                AND Contact.DealerRole__c = '대표'
                AND IsActive = TRUE
        ]) {
            dealerOwnerMap.put(u.Contact.AccountId, u.Id);
        }

        for (Account r : scope) if(dealerOwnerMap.containsKey(r.Id)) r.DealerOwner__c = dealerOwnerMap.get(r.Id);
    }
}