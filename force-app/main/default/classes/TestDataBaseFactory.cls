/****************************************************************************************
  * @filename      : TestDataBaseFactory
  * @projectname   : 
  * @author        : i2max
  * @date          : 2020-04-23
  * @group         : 
  * @group-content : 
  * @description   : 기본 테스트 데이터 생성
  *                : Account, Contact, User, Product2, Pricebook2 기본 객체 생성
  *                : 유틸 함수 제공
  *                : 그룹별로 제공되는 객체들을 생성하여 구성할 것
  * @tester        :
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2020-04-23         i2max          Create
****************************************************************************************/
@IsTest
public class TestDataBaseFactory {

    public static void init() {}

    /**
     * 기본 Account 생성 함수
     * 영업소를 기준으로 Account 생성
     *
     * @param isInsert : insert 여부
     *
     * @return Account
     */
    public static Account createBusinessAccount(final Boolean isInsert) {
        Account account = new Account();
        //============================================================================
        // 변경 필드
        //============================================================================
        account.Name = 'businessOfficeAccount';
        account.ERPCode__c = '001';
        account.RecordTypeId = TestDataUtilFactory.getRecordTypeId('Account','BusinessAccount2');
        account.ErpName__c = '테스트 영업소';
        account.CustomerType__c = '영업소';
        account.ParentId = null;
        //============================================================================
        // 변경 고려 필드
        //============================================================================
        account.Representative__c = '홍길동';
        account.BusinessRegNo__c = '1234567890';
        account.Phone = '010-0000-0000';
        account.Fax = '0222222223';
        account.Mobile__c = '01000000000';
        account.ErpAddr__c = '';
        account.ErpPriceType__c = '';
        account.IsDelete__c = false;
        account.ShippingState = 'korea';
        account.ShippingCity = 'seoul';
        account.ShippingStreet = 'Mapo Street';
        account.ShippingPostalCode = '150001';
        account.BillingState = 'test state';
        account.BillingCity = 'test city';
        account.BillingStreet = 'test street';
        account.BillingPostalCode = '123456';

        if(isInsert)    insert account;

        return account;
    }

    /**
     * 개인 Account 생성
     *
     * @param isInsert : insert 여부
     *
     * @return Account
     */
    public static Account createPersonAccount(final Boolean isInsert) {
        Account account = new Account();
        //============================================================================
        // 변경 필드
        //============================================================================
        account.LastName            = 'PersonAccount';
        //account.ERPCode__c = '001';
        account.RecordTypeId        = TestDataUtilFactory.getRecordTypeId('Account','PersonAccount');
        //account.ErpName__c = '테스트 영업소';
        account.CustomerType__c = '자영농';
        account.CustomerStatus__c   = '요구사항 확보';
        account.FarmingArea__c      = '0~1만평';
        account.FarmingForm__c      = '논';
        account.Dealer__c           = agencyAccount.Id;
        //account.ParentId = '';
        //============================================================================
        // 변경 고려 필드
        //============================================================================
        account.Representative__c   = '홍길동';
        account.BusinessRegNo__c    = '1234567890';
        account.Phone               = '010-0000-0001';
        account.Fax                 = '0222222223';
        account.Mobile__c           = '010-0000-0002';
        account.PersonMobilePhone   = '010-0000-0002';
        account.PersonBirthdate     = TestDataUtilFactory.dt.date();
        //account.ErpAddr__c = '';
        //account.ErpPriceType__c = '';
        account.IsDelete__c         = false;
        account.ShippingState       = 'korea';
        account.ShippingCity        = 'seoul';
        account.ShippingStreet      = 'Mapo Street';
        account.ShippingPostalCode  = '150001';
        account.BillingState        = 'test state';
        account.BillingCity         = 'test city';
        account.BillingStreet       = 'test street';
        account.BillingPostalCode   = '123456';

        if(isInsert)    insert account;

        return account;
    }

    // 영업소 Account
    public static Account businessOfficeAccount {get;set;}
    // 대리점 Account
    public static Account agencyAccount {get;set;}
    // 관납/농협
    public static Account governmentOrNHAccount {get;set;}
    // 관납/농협
    public static Account personAccount {get;set;}

    static {
        if(businessOfficeAccount == null) {
            businessOfficeAccount = createBusinessAccount(true);
        }

        if(agencyAccount == null) {
            agencyAccount                       = businessOfficeAccount.clone(false, true);
            agencyAccount.Name                  = 'agencyAccount';
            agencyAccount.ERPCode__c            = '011';
            agencyAccount.RecordTypeId          = TestDataUtilFactory.getRecordTypeId('Account','BusinessAccount3');
            agencyAccount.ErpName__c            = '테스트 대리점';
            agencyAccount.CustomerType__c       = '대리점';
            agencyAccount.Representative__c     = '강감찬';
            agencyAccount.BusinessRegNo__c      = '1234567892';
            agencyAccount.Area__c               = '이천';
            agencyAccount.ParentId              = businessOfficeAccount.Id;

            insert agencyAccount;
        }

        if(governmentOrNHAccount == null) {
            governmentOrNHAccount                   = businessOfficeAccount.clone(false, true);
            governmentOrNHAccount.Name              = 'governmentOrNHAccount';
            governmentOrNHAccount.ERPCode__c        = '0000000001';
            governmentOrNHAccount.RecordTypeId      = TestDataUtilFactory.getRecordTypeId('Account','BusinessAccount1');
            governmentOrNHAccount.ErpName__c        = '테스트 관납/농협';
            governmentOrNHAccount.CustomerType__c   = '관납';
            governmentOrNHAccount.Representative__c = '홍길순';
            governmentOrNHAccount.BusinessRegNo__c  = '1234567891';
            governmentOrNHAccount.ParentId          = businessOfficeAccount.Id;

            insert governmentOrNHAccount;
        }

        if(personAccount == null) {
            personAccount = createPersonAccount(true);
        }
    }

    /**
     * Contact 생성
     * 대리점 Account 기본의 대리점 영업사원
     *
     * @param isInsert : insert 여부
     *
     * @return Contact
     */
    public static Contact createContact(final Boolean isInsert) {
        Contact contact = new Contact();
        //============================================================================
        // 변경 필드
        //============================================================================
        contact.AccountId = agencyAccount.Id;
        contact.LastName = 'testContact';
        //============================================================================
        // 변경 고려 필드
        //============================================================================
        contact.Email = 'test@test.com';
        contact.MobilePhone ='01011101112';
        contact.DealerRole__c ='대표';

        if(isInsert)    insert contact;

        return contact;
    }

    // 대리점 영업사원 Contact
    public static Contact agencyContact {get;set;}
    static {
        if(agencyContact == null) {
            agencyContact = createContact(true);
        }
    }

    /**
     * 사용자 생성
     * 영업소 영업 사용자 기본
     *
     * @param isInsert : insert 여부
     *
     * @return User
     */
    public static User createUser(final Boolean isInsert) {
        User user = new User();
        //============================================================================
        // 변경 필드
        //============================================================================
        user.Username          = TestDataUtilFactory.dt.format('yyyyMMddhhmmsssSSS') + '@test.com';
        user.ProfileId         = TestDataUtilFactory.getProfileId('국내영업 사용자');
        user.ContactId         = null;
        //============================================================================
        // 변경 고려 필드
        //============================================================================
        user.IsActive          = true;
        user.TimeZoneSidKey    = 'Asia/Seoul';
        user.Email             = 'agencyUser1@test.com';
        user.EmailEncodingKey  = 'ks_c_5601-1987';
        user.LanguageLocaleKey = 'ko';
        user.LastName          = '한국 영업';
        user.Alias             = '한국 영업';
        user.LocaleSidKey      = 'ko_KR';
        user.DealerPasswd__c   = 'test';

        if(isInsert) insert user;

        return user;
    }

    // 영업소 영업 사용자
    public static User businessOfficeUser {get;set;}
    // 대리점 파트너 사용자
    public static User agencyUser {get;set;}
    // 프로그램 수행 사용자
    public static User runUser {get;set;}

    static {

        if(businessOfficeUser == null) {
            businessOfficeUser = createUser(true);
        }

        if(agencyUser == null) {
            agencyUser = businessOfficeUser.clone(false, true);
            agencyUser.Username          = 'agencyPartnerUser1@test.com';
            agencyUser.ProfileId         = TestDataUtilFactory.getProfileId('파트너 사용자');
            agencyUser.ContactId         = agencyContact.Id;
            agencyUser.DealerPasswd__c   = '1111';

            insert agencyUser;
        }

        if(runUser == null) {
            runUser = new User(Id = UserInfo.getUserId());
        }
    }

    static Group testGroup = new Group(Name='SeRap', Type='Queue');
    static QueueSobject  testQueue;
    static {
        insert testGroup;
        testQueue = new QueueSobject(QueueId = testGroup.Id, SobjectType = 'Case');
    }

    /**
     * Case 생성.
     *
     * @param isInsert : insert 여부.
     *
     * @return Case
     */
    public static Case createCase(final Boolean isInsert) {
        Case insertCase = new Case();

        insertCase.DealerFeedback__c      = '불만족';
        insertCase.Status                 = '접수';

        if(isInsert) insert insertCase;

        return insertCase;
    }

    // 본체 이앙기 제품
    public static Case baseCase {get;set;}

    static {
        if(baseCase == null) {
            baseCase = createCase(true);
        }
    }
}