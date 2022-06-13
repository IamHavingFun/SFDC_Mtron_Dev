/****************************************************************************************
  * @filename      : PartnerProfileInfo
  * @projectname   : LS
  * @author        : i2max
  * @date          : 2020-05-08
  * @group         :
  * @group-content :
  * @description   : 파트너홈 프로필 정보
  *                     업무단에서 필요시 wrapper하여 Model Data 구성
  *                     업무별로 동일한 로직처리 방지. front-end 로직구성 단순화.
  * @tester        : PartnerProfileInfo_ts.cls
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2020-05-08         i2max          Create
****************************************************************************************/
public with sharing class PartnerProfileInfo {

    /**
     * 초기 거래 데이터
     */
    public class InitData extends I2ComClass.InitData {
        @AuraEnabled public UserProfile userProfile {get;set;}
    }


    @AuraEnabled
    public static I2ComClass.InitData init() {
        List<User> leaseUser = [
                SELECT Id FROM User
                WHERE Profile.Name = 'Korea Partner Community Lease User'
                AND IsActive = TRUE
                LIMIT 1
        ];
        System.debug('-----------');
        System.debug('leaseuser ==> ' + leaseUser.size());
        System.debug('-----------');


        InitData initData = new InitData();

        User user = [SELECT Id, Name, toLabel(BusinessOffice__c), SmallPhotoUrl, MediumPhotoUrl, FullPhotoUrl, ContactId, AccountId FROM User WHERE Id = :UserInfo.getUserId()];
        Account account = null;
        List<SalesIQ__c> salesIQs = null;
        Decimal point;
        Double iqRate;
        if(user.ContactId != null) {
            account = [SELECT Id, Name,  SalesScoring__c, SalesIQRank__c, SalesIQRate__c, fm_SalesScoringColor__c, ServiceCapabilityClass__c, ServiceCapabilityClassIcon__c FROM Account WHERE Id = :user.AccountId];
            salesIQs = [SELECT Id, Point__c FROM SalesIQ__c WHERE Division__c = '실적' AND BaseYearMonth__c = THIS_MONTH AND Dealer__c = :user.AccountId LIMIT 1];
            if(salesIQs.isEmpty() == true) {
                point = 0;
                iqRate = 0;
            } else {
                point = salesIQs[0].Point__c;
                iqRate = account.SalesIQRate__c.setScale(1);
            }
        }

        /**
         * TODO : 대리점 사장님으로 해야 할까/
         * SELECT Id, Contact.Account.ERPCode__c
                FROM User
                WHERE Contact.Account.ERPCode__c IN :erpCodeList
                AND Contact.DealerRole__c = '대표'
         */
        initData.userProfile = new UserProfile(user, account, point, iqRate);
        return initData;
    }

    public class UserProfile {
        @AuraEnabled public User user { get; set; }
        @AuraEnabled public Decimal point { get; set; }
        @AuraEnabled public Double iqRate { get; set; }
        @AuraEnabled public String smallPhotoUrl {
            get {
                return user.SmallPhotoUrl;
            }
            set;
        }
        @AuraEnabled public String mediumPhotoUrl {
            get {
                return user.MediumPhotoUrl;
            }
            set;
        }
        @AuraEnabled public String fullPhotoUrl {
            get {
                return user.FullPhotoUrl;
            }
            set;
        }
        // @TODO 해당 커뮤니티를 찾아오도록 해야 한다.
        //  무영이 시키자.
        @AuraEnabled public String serviceCapabilityClassIconUrl {
            get {
                return account != null ? account.ServiceCapabilityClassIcon__c.replace('/resource/', '/Partner/resource/') : '';
            }
            set;
        }
        @AuraEnabled public Account account { get; set; }

        public UserProfile(User user, Account account, Decimal point, Double iqRate) {
            this.user = user;
            this.account = account;
            this.point = point;
            this.iqRate = iqRate;
        }
    }
}