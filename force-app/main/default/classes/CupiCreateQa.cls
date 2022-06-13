/**
** @filename      : cupiCreateQa
* @projectname   :
* @author        : SEOKHO LEE
* @date          : 2020-05-14 오전 8:30
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
0.1     2020-05-14 오전 8:30       SEOKHO LEE          Create
 */

public with sharing class CupiCreateQa {

    /**
     * 초기화
     * @param recordId
     * @return
     */
    @AuraEnabled
    public static WrapperData init(String recordId) {
        WrapperData wrapperData = new WrapperData();
        wrapperData.account = [
                SELECT LastName, FirstName, fm_Mobile__c, PersonContactId, CUPI__pc, IsCUPI__pc, CUPIInitialStartDate__pc
                FROM Account
                WHERE Id = :recordId ];
        return wrapperData;
    }

    /**
     * 저장
     * @param acc
     * @param cpMap
     */
    @AuraEnabled
    public static void save(WrapperData wrapperData) {
        wrapperData.cupi.ConsentedAccount__c = wrapperData.account.Id; // 동의자 계정 = AcccountId
        wrapperData.cupi.ConsentedContact__c = wrapperData.account.PersonContactId; // 동의자 연락처 = 동의자 계정에 있는 연락처 아이디
        wrapperData.cupi.Dealer__c = ModelUser.getUserData().Contact.AccountId; // 대리점 = 로그인자 대리점
        wrapperData.cupi.SalesRep__c = UserInfo.getUserId(); // 대리점 영업 담당 = 로그인자 아이디
        wrapperData.cupi.ConsentDate__c = Date.today(); // 동의일
        wrapperData.cupi.ConsentType__c = '신규'; //  신규 / 재동의 구분
        wrapperData.cupi.NextConsentScheduledDate__c = wrapperData.cupi.ConsentDate__c.addYears(2); // 재동의 예정일 + 2년
        insert wrapperData.cupi;

/*
        wrapperData.account.CUPI__pc = wrapperData.cupi.Id; //  개인정보 활용 동의
        wrapperData.account.IsCUPI__pc = wrapperData.cupi.IsCUPI__c;// 개인정보활용동의여부
        if (wrapperData.account.CUPIInitialStartDate__pc == null) wrapperData.account.CUPIInitialStartDate__pc = Date.today(); // 개인정보활용동의 최초 동의일
*/
        Account updateAccount = new Account(Id = wrapperData.account.Id);
        updateAccount.CUPI__pc = wrapperData.cupi.Id; //  개인정보 활용 동의
        updateAccount.IsCUPI__pc = wrapperData.cupi.IsCUPI__c;// 개인정보활용동의여부
        if (wrapperData.account.CUPIInitialStartDate__pc == null) updateAccount.CUPIInitialStartDate__pc = Date.today(); // 개인정보활용동의 최초 동의일

        update updateAccount;
    }

    /**
     * Wrapper Class / CUPI__c, Account
     */
    public class WrapperData {
        @AuraEnabled public Account         account{get;set;}

        @AuraEnabled public CUPI__c         cupi {
            get {
                if(this.cupi == null) {
                    this.cupi = new CUPI__c();
                    this.cupi.IsCUPI__c                 = true;
                    this.cupi.IsCUPIThirdParty__c       = true;
                    this.cupi.ReceiveSMS__c             = true;
                    this.cupi.IsReceiveEmail__c         = true;
                    this.cupi.ReceiveDM__c              = true;
                }
                return this.cupi;
            }
            set;
        }
    }
}