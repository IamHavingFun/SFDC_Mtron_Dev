/****************************************************************************************
  * @filename      : GuideActionAR6MonthOverByDealer_ba_ts
  * @projectname   : LS_PS
  * @author        : Park HE
  * @date          : 2020-07-09
  * @group         :
  * @group-content :
  * @description   :
  * @tester        :
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                    author          description
  * ===============================================================
    0.1     2020-07-09             Park HE         Create
****************************************************************************************/

@IsTest
private class GuideActionAR6MonthOverByDealer_ba_ts {
    @IsTest
    static void testBehavior() {

        Account testAgencyAccount = TestDataBaseFactory.agencyAccount.clone(false, true);
        testAgencyAccount.OverdueSixMonths__c = 10;
        insert testAgencyAccount;

        Contact testContact = TestDataBaseFactory.agencyContact.clone(false, true);
        testContact.AccountId = testAgencyAccount.Id;
        insert testContact;

        User testUser = TestDataBaseFactory.agencyUser.clone(false, true);
        testUser.ContactId = testContact.Id;
        testUser.Username = System.now().format('yyyyMMddHHmmssSSS') + TestDataBaseFactory.agencyUser.Username;
        insert testUser;

        // 데이터 증명 로직 : 필요시 주석풀고 log 볼것
        /*List<Account> accounts = Database.query('SELECT Id, Name, OwnerId, OverdueSixMonths__c, BusinessOffice__r.Name FROM Account WHERE ( fm_OverdueMoreSixMonths__c > 0 OR fm_OverdueOneYear__c > 0 ) AND CustomerType__c = \'대리점\'');
        System.debug(System.LoggingLevel.INFO, 'accounts : ' + JSON.serializePretty(accounts));
        Map<Id, Account> tmpMap = new Map<Id, Account>(accounts);
        final Set<String> accIds = new Set<String>();
        for(Id accId : tmpMap.keySet()) accIds.add((String)accId);
        Map<String, Id> taskOwnerId =  Dummy_IF_BatchUtil.getDealerOwner((Set<String>)accIds);
        System.debug(System.LoggingLevel.INFO, 'taskOwnerId : ' + taskOwnerId);*/

        Database.executeBatch(new GuideActionAR6MonthOverByDealer_ba(), 200);
    }

}