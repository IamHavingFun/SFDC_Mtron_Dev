/****************************************************************************************
  * @filename      : i2SEMA_TestDataUtil
  * @projectname   : i2sema.dev pd
  * @author        : i2max_shlee 
  * @date          : 2020/04/09 4:35 PM
  * @group         : e.g)tab name
  * @group-content : e.g)view file  
  * @description   : 
  * @tester        : i2SEMA_TestDataUtil_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                author              description
  * ===============================================================
    0.1     2020/04/09 4:35 PM     i2max_shlee       Create
****************************************************************************************/
//Test Case Data 생성을 위한 Class 로 ID hardcoding 불가피함.
@SuppressWarnings('PMD.AvoidHardcodingId')
@IsTest
public class i2SEMA_TestDataUtil {
    public static String currencyIsoCode = 'KRW';
    public static Date d = Date.today();
    public static DateTime dt = DateTime.now();

    //Standard Object
    public static Account acc;
    public static List<Account> accs;
    public static Contact con;
    public static List<Contact> cons;
    public static Lead lead;
    public static List<Lead> leads;
    public static Campaign cam;
    public static CampaignMember camb;
    public static Opportunity opp;
    //i2SEMA Object
    public static Notification__c n;
    public static NotificationGroup__c smsNG;
    public static NotificationGroup__c lmsNG;
    public static NotificationGroup__c mmsNG;
    public static NotificationGroup__c kftNG;
    public static NotificationGroup__c kntNG;
    public static Notification__c smsNotification;
    public static Notification__c lmsNotification;
    public static Notification__c mmsNotification;
    public static Notification__c mmsManualNotification;
    public static Notification__c kftNotification;
    public static Notification__c kntNotification;
    public static NotificationAutomaticSetting__c nas;
    public static NotificationTemplate__c smsTemplate;
    public static NotificationTemplate__c lmsTemplate;
    public static NotificationTemplate__c mmsTemplate;
    public static NotificationTemplate__c kakaoFriendTemplate;
    public static NotificationTemplate__c kakaoNotificationTemplate;
    public static KakaoTalkButton__c ktb;
    public static ContentVersion cv;
    public static ContentDocumentLink cdl;
    public static NotificationAutomaticSetting__c realTimeAutomaticSetting;
    public static NotificationAutomaticSetting__c scheduledAutomaticSetting;

    /**
     * @description i2SEMA_Base 에서 참조하는 설정정보 생성
     *
     * @example i2SEMA_Base.CONFIG = i2SEMA_TestDataUtil.getI2SEMAConfigValue();
     */
    public static i2SEMA_Config__c getI2SEMAConfigValue(){
        i2SEMA_Config__c config                     = new i2SEMA_Config__c();
        config.ChatterTextLimit__c                  = 5000;
        config.ClientSideLog__c                     = true;
        config.EventExecuteLimit__c                 = 5;
        config.FileUploadCountLimit__c              = 1;
        config.FileUploadSizeLimit__c               = 102400;
        config.IFFileStatus__c                      = true;
        config.KakaoFriendTalkTextLimit__c          = 1000;
        config.KakaoNotificationTalkTextLimit__c    = 1000;
        config.LMSTextLimit__c                      = 2000;
        config.MMSTextLimit__c                      = 2000;
        config.SMSTextLimit__c                      = 80.0;
        config.ReservationMaxTime__c                = 3;
        config.ReservationMInTime__c                = 30;
        config.AccountPhone__c                      = 'Phone';
        config.ContactPhone__c                      = 'Phone';
        config.LeadPhone__c                         = 'Phone';
        config.UserPhone__c                         = 'Phone';
//        config.KakaoBizId__c                        = '@Sample';
//        config.SenderPhoneNumber__c                 = '010-1234-5678';
        return config;
    }

    /**
     * @description IF_Base 에서 참조하는 공통 Interface 설정정보 생성
     *
     * @example IF_BaseNotiforce.staticValue = i2SEMA_TestDataUtil.getIfStaticValue();
     *
     */
    public static Notiforce_IfStaticValue__c getIfStaticValue(){
        Notiforce_IfStaticValue__c isv   = new Notiforce_IfStaticValue__c();
        isv.Name                         = 'Test_Setup_Value';
        isv.hub_aes_init_vector__c       = 'Test_Setup_Value';
        isv.hub_aes_private_key__c       = 'Test_Setup_Value';
        isv.hub_auth_name__c             = 'Test_Setup_Value';
        isv.hub_auth_password__c         = 'Test_Setup_Value';
        isv.hub_url__c                   = 'Test_Setup_Value';
        isv.sfdc_aes_algorithm__c        = 'Test_Setup_Value';
        isv.sfdc_aes_private_key__c      = 'Test_Setup_Value';
        isv.sfdc_aes_init_vector__c      = 'Test_Setup_Value';
        isv.sfdc_oauth_client_id__c      = 'Test_Setup_Value';
        isv.sfdc_oauth_client_secret__c  = 'Test_Setup_Value';
        isv.sfdc_oauth_password__c       = 'Test_Setup_Value';
        isv.sfdc_oauth_username__c       = 'Test_Setup_Value';
        isv.sfdc_org_url__c              = 'Test_Setup_Value';
        isv.dsptch_num__c                = '07077057204';
        isv.kakaobizId__c                = '@아이투맥스';
        isv.ars_num__c                   = '0803003287';

        return isv;
    }
    /**
     * @description IF_Base 에서 참조하는 단위 Interface 설정정보 생성
     */
    public static Notiforce_IF_INFO__c getIfInfo(String ifId){
        Notiforce_IF_INFO__c ifInfo = new Notiforce_IF_INFO__c();
        ifInfo.IF_ID__c         = ifId;
        ifInfo.URL__c           = '/restapi/sema/'+ifId+'.json';
        ifInfo.CYCLE__c         = 'realtime';
        ifInfo.FROM__c          = 'SFDC';
        ifInfo.TO__c            = 'I2SEMA';
        ifInfo.TITLE__c         = 'I2SEMA Server 메시지 전송';
        ifInfo.FORCE_LOGGING__c = true;
        return ifInfo;
    }

    public static Account getAccount() {
        if (acc == null) {
            acc = (Account) TestDataFactory.createSObject('Account',new Map<String,Object>{
                'Name' => '이상협'
                ,'Phone' => '01022884132'
            });
        }
        return acc;
    }

    public static List<Account> getAccounts() {
        if (accs == null) {
            accs = TestDataFactory.createSObjectList('Account',10);
        }
        return accs;
    }

    public static Contact getContact() {
        if (con == null) {
            acc = getAccount();
            con = (Contact) TestDataFactory.createSObject('Contact',new Map<String,Object>{
                    'FirstName' => '상협'
                    ,'LastName' => '이'
                    ,'AccountId' => acc.Id
                    ,'Phone' => '01022884132'
            });
        }
        return con;
    }

    public static List<Contact> getContacts() {
        if (cons == null) {
            acc = getAccount();
            cons = TestDataFactory.createSObjectList('Contact',new Map<String,Object>{
                    'AccountId' => acc.Id
            },10);
        }
        return cons;
    }

    public static Lead getLead() {
        if (lead == null) {
            lead = (Lead) TestDataFactory.createSObject('Lead',new Map<String,Object>{
                    'FirstName' => '상협'
                    ,'LastName' => '이'
                    ,'Phone' => '01022884132'
            });
        }
        return lead;
    }
    public static List<Lead> getLeads() {
        if (leads == null) {
            leads = TestDataFactory.createSObjectList('Lead',10);
        }
        return leads;
    }
    public static Opportunity getOpportunity(){
        if(opp == null){
            acc = getAccount();
            opp = (Opportunity)TestDataFactory.createSObject('Opportunity',new Map<String,Object>{
                'Name'              => 'Sample Opportunity',
                'AccountId'         => acc.Id,
                'Amount'            => 20000
            });
        }
        return opp;
    }

    /*----------------------------------------------------------------------
     * 메세지 채널 템플릿
     *----------------------------------------------------------------------*/

    //NotificationTemplate__c Test SMS템플릿 레코드
    public static NotificationTemplate__c getSMSTemplate() {
        if (smsTemplate == null) {
            smsTemplate = (NotificationTemplate__c) TestDataFactory.createSObject('NotificationTemplate__c',new Map<String,Object>{
                    'Name' => 'SMS'
                    ,'Channel__c' => '0'
                    ,'Content__c' => '안녕하세요.  %%LABEL1%% 님 가입이 성공적으로 완료되었습니다.많은 이용 부탁드립니다. 감사합니다.'
                    ,'LABEL1__c' => TRUE
                    ,'IsActive__c' => TRUE
                    ,'IF_Status__c' => 'Completed'
            });
        }
        return smsTemplate;
    }
    //NotificationTemplate__c Test LMS템플릿 레코드 / 인서트 완료
    public static NotificationTemplate__c getLMSTemplate() {
        if ( lmsTemplate == null) {
            lmsTemplate = (NotificationTemplate__c) TestDataFactory.createSObject('NotificationTemplate__c',new Map<String,Object>{
                    'Name' => 'LMS'
                    ,'Title__c' => 'LMS Test'
                    ,'Channel__c' => '3'
                    ,'Content__c' => 'TEST 버전입니다. %%LABEL1%%님께서 신청하신 %%LABEL2%%코엑스 컨벤션센터에서 개최되는 %%LABEL3%%에 사전등록 신청해 주셔서 감사드립니다. 참가신청 후 개인사정으로 인하여 부득이하게 불참시에는 사전에 아이투맥스로 꼭 연락 주시기 바랍니다.'
                    ,'LABEL1__c' => TRUE
                    ,'LABEL2__c' => TRUE
                    ,'LABEL3__c' => TRUE
                    ,'IsActive__c' => TRUE
                    ,'IF_Status__c' => 'Completed'
            });
        }
        return lmsTemplate;
    }

    /*----------------------------------------------------------------------
     * 템플릿 - MMS 채널
     *----------------------------------------------------------------------*/
    //NotificationTemplate__c Test MMS템플릿 레코드 / 인서트 완료
    public static NotificationTemplate__c getMMSTemplate() {
        if( mmsTemplate == null) {
            mmsTemplate = (NotificationTemplate__c) TestDataFactory.createSObject('NotificationTemplate__c',new Map<String,Object>{ //Template NotificationTemplate__c
                    'Name' => 'MMS'
                    ,'Title__c' => 'MMS Test'
                    ,'Channel__c' => '2'
                    ,'Content__c' => 'TEST 버전입니다. %%LABEL1%%님께서 신청하신 %%LABEL2%%코엑스 컨벤션센터에서 개최되는 %%LABEL3%%에 사전등록 신청해 주셔서 감사드립니다. 참가신청 후 개인사정으로 인하여 부득이하게 불참시에는 사전에 아이투맥스로 꼭 연락 주시기 바랍니다.'
                    ,'LABEL1__c' => TRUE
                    ,'LABEL2__c' => TRUE
                    ,'LABEL3__c' => TRUE
                    ,'IsActive__c' => TRUE
                    ,'IF_Status__c' => 'Completed'
            });

            /*ContentDocumentLink cdl = (ContentDocumentLink) TestDataFactory.createSObject('ContentDocumentLink',new Map<String,Object>{
                'LinkedEntityId' => nt.Id
                ,'ContentDocumentId' => new Map
                        <String,Object>{ //ContentVersion
                        'Title' => 'test.jpg'
                        ,'VersionData' => blob.valueOf('test')
                        ,'PathOnClient' => 'test.jpg'
                        ,'ContentLocation' => 'S'
                }
            });*/

            if(cdl == null) cdl = getContentDocumentLink(mmsTemplate.Id);

        }
        return mmsTemplate;
    }

    /*----------------------------------------------------------------------
     * 템플릿 - 카카오 채널
     *----------------------------------------------------------------------*/
    //KakaoTalkButton__c Test 카카오친구톡 버튼 단독호출 불가 카카오 템플릿을 통해 호출
    public static KakaoTalkButton__c getKakaoTalkButton() {
        if (ktb == null && kakaoFriendTemplate != null) {
            ktb = (KakaoTalkButton__c) TestDataFactory.createSObject('KakaoTalkButton__c',new Map<String,Object>{
                'Name' => 'Daum'
                ,'NotificationTemplates__c' => kakaoFriendTemplate.Id
                ,'Button_Type__c' => 'WL'
                ,'ButtonLink1__c' => 'https://daum.net'
            });
        }
        return ktb;
    }

    //NotificationTemplate__c Test 카카오친구톡 템플릿 레코드 / 인서트 완료
    public static NotificationTemplate__c getKakaoFriendTalkTemplate() {
        KakaoFriendTalkImage__c kft = (KakaoFriendTalkImage__c) TestDataFactory.createSObject('KakaoFriendTalkImage__c',new Map<String,Object>{
                'ImageURL__c' => 'https://pbs.twimg.com/profile_images/1161854916500922368/eof0M5fr_400x400.jpg'
        });
        if (kakaoFriendTemplate == null) {
            kakaoFriendTemplate = (NotificationTemplate__c) TestDataFactory.createSObject('NotificationTemplate__c',new Map<String,Object>{
                    'Name' => 'Kakao Friend Talk'
                    ,'Title__c' => 'Kakao Friend Talk Test'
                    ,'Channel__c' => '1009'
                    ,'Content__c' => 'TEST 버전입니다. %%LABEL1%%님께서 신청하신 %%LABEL2%%코엑스 컨벤션센터에서 개최되는 %%LABEL3%%에 사전등록 신청해 주셔서 감사드립니다. 참가신청 후 개인사정으로 인하여 부득이하게 불참시에는 사전에 아이투맥스로 꼭 연락 주시기 바랍니다.'
                    ,'LABEL1__c' => TRUE
                    ,'LABEL2__c' => TRUE
                    ,'LABEL3__c' => TRUE
                    ,'KakaoImgUrl__c' => 'https://pbs.twimg.com/profile_images/1161854916500922368/eof0M5fr_400x400.jpg'
                    ,'KakaoImgLink__c ' => 'https://finance.daum.net/global'
                    ,'KakaoFriendTalkImage__c' => kft.Id
                    ,'IsActive__c' => TRUE
                    ,'IF_Status__c' => 'Completed'
            });
            getKakaoTalkButton();
        }
        return kakaoFriendTemplate;
    }
    //NotificationTemplate__c Test 카카오알림톡 템플릿 레코드 / 인서트 완료
    public static NotificationTemplate__c getKakaoNotificationTalkTemplate() {
        if (kakaoNotificationTemplate == null) {
            kakaoNotificationTemplate = (NotificationTemplate__c) TestDataFactory.createSObject('NotificationTemplate__c',new Map<String,Object>{
                    'Name' => 'Kakao Notification Talk'
                    ,'Title__c' => 'Kakao Notification Talk Test'
                    ,'Channel__c' => '1008'
                    ,'Content__c' => 'TEST 버전입니다. %%LABEL1%%님께서 신청하신 %%LABEL2%%코엑스 컨벤션센터에서 개최되는 %%LABEL3%%에 사전등록 신청해 주셔서 감사드립니다. 참가신청 후 개인사정으로 인하여 부득이하게 불참시에는 사전에 아이투맥스로 꼭 연락 주시기 바랍니다.'
                    ,'LABEL1__c' => TRUE
                    ,'LABEL2__c' => TRUE
                    ,'LABEL3__c' => TRUE
                    ,'IsActive__c' => TRUE
                    ,'IF_Status__c' => 'Completed'
            });
            getKakaoTalkButton();

        }
        return kakaoNotificationTemplate;
    }

    public static ContentVersion getContentVersion() {
        if (cv == null){
            cv = new ContentVersion();
            cv.Title = 'test.jpg';
            cv.VersionData = blob.valueOf('test');
            cv.PathOnClient = 'test.jpg';
            cv.ContentLocation = 'S';
            insert cv;
        }
        return cv;
    }

    public static ContentDocumentLink getContentDocumentLink(Id recordId) {
        if (cv == null) cv = getContentVersion();
        ContentVersion testCV = [SELECT Id, ContentDocumentId FROM ContentVersion where Id = :cv.Id];
        if (cdl == null){
            cdl = new ContentDocumentLink();
            cdl.LinkedEntityId = recordId;
            cdl.ContentDocumentId = testCV.ContentDocumentId;
            cdl.ShareType = 'V';
            insert cdl;
        }
        return cdl;
    }

    /*----------------------------------------------------------------------
     * Notification - 카카오 채널
     *----------------------------------------------------------------------*/
    public static Notification__c getSMSNotification() {
        acc = getAccount();
        smsTemplate = getSMSTemplate();
        smsNg  = (NotificationGroup__c) TestDataFactory.createSObject('NotificationGroup__c');
        i2SEMA_TriggerHandler.bypass('i2SEMA_Notification_tr');
        if (smsNotification == null) {
            smsNotification = (Notification__c) TestDataFactory.createSObject('Notification__c',new Map<String,Object>{
                    'NotificationGroup__c' => smsNg.Id
                    ,'NotificationTemplate__c' => smsTemplate.Id
                    ,'TargetId__c' => acc.Id
                    ,'Account__c' => acc.Id
                    ,'LABEL1__c' => acc.Name
                    ,'Channel__c' => smsTemplate.Channel__c
                    ,'Content__c' => smsTemplate.Content__c
                    ,'RawContents__c' => smsTemplate.Content__c
                    ,'Validity__c' => TRUE
            });
        }

        return smsNotification;
    }

    public static Notification__c getReservationSMSNotification() {
        acc = getAccount();
        smsTemplate = getSMSTemplate();
        smsNg  = (NotificationGroup__c) TestDataFactory.createSObject('NotificationGroup__c');
        i2SEMA_TriggerHandler.bypass('i2SEMA_Notification_tr');
        if (smsNotification == null) {
            smsNotification = (Notification__c) TestDataFactory.createSObject('Notification__c',new Map<String,Object>{
                    'NotificationGroup__c' => smsNg.Id
                    ,'NotificationTemplate__c' => smsTemplate.Id
                    ,'TargetId__c' => acc.Id
                    ,'Account__c' => acc.Id
                    ,'LABEL1__c' => acc.Name
                    ,'Channel__c' => smsTemplate.Channel__c
                    ,'Content__c' => smsTemplate.Content__c
                    ,'RawContents__c' => smsTemplate.Content__c
                    ,'IsSendingReservation__c' => TRUE
                    ,'SendingTime__c' => Datetime.now().addDays(1)
                    ,'Validity__c' => TRUE
            });
        }
        return smsNotification;
    }

    public static Notification__c getLMSNotification() {
        con = getContact();
        lmsTemplate = getlMSTemplate();
        lmsNg  = (NotificationGroup__c) TestDataFactory.createSObject('NotificationGroup__c');
        i2SEMA_TriggerHandler.bypass('i2SEMA_Notification_tr');
        if (lmsNotification == null) {
            lmsNotification = (Notification__c) TestDataFactory.createSObject('Notification__c',new Map<String,Object>{
                    'NotificationTemplate__c' => lmsTemplate.Id
                    ,'TargetId__c' => con.Id
                    ,'Contact__c' => con.Id
                    ,'NotificationGroup__c' => lmsNg.Id
                    ,'LABEL1__c' => con.FirstName
                    ,'LABEL2__c' => con.LastName
                    ,'LABEL3__c' => con.LastName
                    ,'Content__c' => lmsTemplate.Content__c
                    ,'RawContents__c' => lmsTemplate.Content__c
                    ,'Validity__c' => TRUE
            });
        }
        return lmsNotification;
    }

    public static Notification__c getMMSNotification() {
        acc = getAccount();
        mmsNg  = (NotificationGroup__c) TestDataFactory.createSObject('NotificationGroup__c');
        mmsTemplate = getMMSTemplate();
        i2SEMA_TriggerHandler.bypass('i2SEMA_Notification_tr');
        if (mmsNotification == null) {
            mmsNotification = (Notification__c) TestDataFactory.createSObject('Notification__c',new Map<String,Object>{
                    'NotificationTemplate__c' => mmsTemplate.Id
                    ,'TargetId__c' => acc.Id
                    ,'Account__c' => acc.Id
                    ,'NotificationGroup__c' => mmsNg.Id
                    ,'LABEL1__c' => acc.Name
                    ,'LABEL2__c' => acc.Name
                    ,'LABEL3__c' => acc.Name
                    ,'Content__c' => mmsTemplate.Content__c
                    ,'RawContents__c' => mmsTemplate.Content__c
                    ,'Validity__c' => TRUE
            });
        }
        return mmsNotification;
    }

    public static Notification__c getMMSManualNotification() {
        acc = getAccount();
        mmsNg  = (NotificationGroup__c) TestDataFactory.createSObject('NotificationGroup__c');
        i2SEMA_TriggerHandler.bypass('i2SEMA_Notification_tr');
        if (mmsManualNotification == null) {
            mmsManualNotification = (Notification__c) TestDataFactory.createSObject('Notification__c',new Map<String,Object>{
                    'NotificationGroup__c' => mmsNg.Id
                    ,'TargetId__c' => acc.Id
                    ,'Account__c' => acc.Id
                    ,'LABEL1__c' => acc.Name
                    ,'Validity__c' => TRUE
                    ,'Title__c' => 'MMS Test'
                    ,'Channel__c' => '2'
                    ,'Content__c' => 'TEST 버전입니다. %%LABEL1%%님께서 신청하신 %%LABEL2%%코엑스 컨벤션센터에서 개최되는 %%LABEL3%%에 사전등록 신청해 주셔서 감사드립니다. 참가신청 후 개인사정으로 인하여 부득이하게 불참시에는 사전에 아이투맥스로 꼭 연락 주시기 바랍니다.'
                    ,'RawContents__c' => 'TEST 버전입니다. %%LABEL1%%님께서 신청하신 %%LABEL2%%코엑스 컨벤션센터에서 개최되는 %%LABEL3%%에 사전등록 신청해 주셔서 감사드립니다. 참가신청 후 개인사정으로 인하여 부득이하게 불참시에는 사전에 아이투맥스로 꼭 연락 주시기 바랍니다.'
            });
        }

        if(cdl == null) cdl = getContentDocumentLink(mmsNg.Id);

        return mmsManualNotification;
    }

    public static Notification__c getMMSManualReservNoti() {
        acc = getAccount();
        mmsNg  = (NotificationGroup__c) TestDataFactory.createSObject('NotificationGroup__c');
        i2SEMA_TriggerHandler.bypass('i2SEMA_Notification_tr');
        if (mmsManualNotification == null) {
            mmsManualNotification = (Notification__c) TestDataFactory.createSObject('Notification__c',new Map<String,Object>{
                    'NotificationGroup__c' => mmsNg.Id
                    ,'TargetId__c' => acc.Id
                    ,'Account__c' => acc.Id
                    ,'LABEL1__c' => acc.Name
                    ,'Validity__c' => TRUE
                    ,'IsSendingReservation__c' => TRUE
                    ,'SendingTime__c' => Datetime.now().addDays(1)
                    ,'Title__c' => 'MMS Test'
                    ,'Channel__c' => '2'
                    ,'Content__c' => 'TEST 버전입니다. %%LABEL1%%님께서 신청하신 %%LABEL2%%코엑스 컨벤션센터에서 개최되는 %%LABEL3%%에 사전등록 신청해 주셔서 감사드립니다. 참가신청 후 개인사정으로 인하여 부득이하게 불참시에는 사전에 아이투맥스로 꼭 연락 주시기 바랍니다.'
                    ,'RawContents__c' => 'TEST 버전입니다. %%LABEL1%%님께서 신청하신 %%LABEL2%%코엑스 컨벤션센터에서 개최되는 %%LABEL3%%에 사전등록 신청해 주셔서 감사드립니다. 참가신청 후 개인사정으로 인하여 부득이하게 불참시에는 사전에 아이투맥스로 꼭 연락 주시기 바랍니다.'
            });
        }

        if(cdl == null) cdl = getContentDocumentLink(mmsNg.Id);

        return mmsManualNotification;
    }

    public static Notification__c getKftNotification() {
        lead = getLead();
        kakaoFriendTemplate = getKakaoFriendTalkTemplate();
        kftNg  = (NotificationGroup__c) TestDataFactory.createSObject('NotificationGroup__c');
        i2SEMA_TriggerHandler.bypass('i2SEMA_Notification_tr');
        if (kftNotification == null) {
            kftNotification = (Notification__c) TestDataFactory.createSObject('Notification__c',new Map<String,Object>{
                    'NotificationTemplate__c' => kakaoFriendTemplate.Id
                    ,'TargetId__c' => lead.Id
                    ,'Lead__c' => lead.Id
                    ,'NotificationGroup__c' => kftNg.Id
                    ,'LABEL1__c' => lead.FirstName
                    ,'LABEL2__c' => lead.LastName
                    ,'LABEL3__c' => lead.FirstName
                    ,'Content__c' => kakaoFriendTemplate.Content__c
                    ,'RawContents__c' => kakaoFriendTemplate.Content__c
                    ,'Validity__c' => TRUE
            });
        }
        return kftNotification;
    }

    public static Notification__c getKntNotification() {
        acc = getAccount();
        kakaoNotificationTemplate = getKakaoNotificationTalkTemplate();
        kntNg  = (NotificationGroup__c) TestDataFactory.createSObject('NotificationGroup__c');
        if (kntNotification == null) {
            kntNotification = (Notification__c) TestDataFactory.createSObject('Notification__c',new Map<String,Object>{
                    'NotificationTemplate__c' => kakaoNotificationTemplate.Id
                    ,'TargetId__c' => acc.Id
                    ,'Account__c' => acc.Id
                    ,'NotificationGroup__c' => kntNg.Id
                    ,'LABEL1__c' => acc.Name
                    ,'LABEL2__c' => acc.Name
                    ,'LABEL3__c' => acc.Name
                    ,'Content__c' => lmsTemplate.Content__c
                    ,'RawContents__c' => lmsTemplate.Content__c
                    ,'Validity__c' => TRUE
            });
        }
        return kntNotification;
    }

    /*----------------------------------------------------------------------
     * 자동발송 설정값 (실시간,예약발송)
     *----------------------------------------------------------------------*/
    public static NotificationAutomaticSetting__c getRealTimeAutomaticSetting(Map<String,Object> additionalProperties){
        if( realTimeAutomaticSetting == null ){
            smsTemplate = getSMSTemplate();

            Map<String,Object> properties = new Map<String,Object>{
                    'IsActive__c'               => true,
                    'IsSchedule__c'             => false,
                    'ObjectType__c'             => 'NotificationAutomaticTest__c',
                    'ExecuteOn__c'              => 'Insert',
                    'RecipientField__c'         => 'TestUserReference__c',
                    'NotificationTemplate__c'   => smsTemplate.Id,
                    'Label1FieldAPI__c'         => 'Name',
                    'LogicalExpression__c'      => 'A'
            };
            properties.putAll(additionalProperties);


            realTimeAutomaticSetting = (NotificationAutomaticSetting__c) TestDataFactory.createSObject('NotificationAutomaticSetting__c',properties);
        }
        return realTimeAutomaticSetting;
    }
    public static NotificationAutomaticSetting__c getScheduledAutomaticSetting(Map<String,Object> additionalProperties){
        if( scheduledAutomaticSetting == null ){
            smsTemplate = getSMSTemplate();

            Map<String,Object> properties = new Map<String,Object>{
                    'IsActive__c'               => true,
                    'IsSchedule__c'             => true,
                    'ScheduleBasedOn__c'        => 'Rule Triggered Time',
                    'ScheduleTime__c'           => 2,
                    'ObjectType__c'             => 'NotificationAutomaticTest__c',
                    'ExecuteOn__c'              => 'Update',
                    'RecipientField__c'         => 'TestUserReference__c',
                    'NotificationTemplate__c'   => smsTemplate.Id,
                    'Label1FieldAPI__c'         => 'Name',
                    'LogicalExpression__c'      => 'A'
            };
            properties.putAll(additionalProperties);

            scheduledAutomaticSetting = (NotificationAutomaticSetting__c) TestDataFactory.createSObject('NotificationAutomaticSetting__c',properties);
        }
        return scheduledAutomaticSetting;
    }

    // 생성하는 측에서 각 Property 전달, 결과 조건식 insert 하지 않고 반환
    public static List<NotificationAutomaticCondition__c> getNotificationAutomaticCondition(List<Map<String,Object>> additionalProperties){
        List<NotificationAutomaticCondition__c> returnConditions = new List<NotificationAutomaticCondition__c>();

        Map<String,Object> properties;
        for( Map<String,Object> additionalProperty : additionalProperties ){
            // 초기값
            properties = new Map<String,Object>{
                    'NotificationAutomaticSetting__c'   => null,
                    'Alias__c'                          => null,
                    'Field__c'                          => null,
                    'FieldType__c'                      => null,
                    'Operator__c'                       => null,
                    'CompareWith__c'                    => null,
                    'CompareField__c'                   => null
            };

            properties.putAll(additionalProperty);
            returnConditions.add((NotificationAutomaticCondition__c) TestDataFactory.createSObject('NotificationAutomaticCondition__c',properties,false));
        }

        return returnConditions;
    }

    /**
     * @description CheckBox 타입의 필드 연산조건식 획득
     *  : Schema.SObjectField > getType() == 'BOOLEAN'
     */
    public static List<NotificationAutomaticCondition__c> getBooleanCondition(NotificationAutomaticSetting__c setting){
        Map<String,Object> anyChangeProperty = new Map<String,Object>{
                'NotificationAutomaticSetting__c'   => setting.Id,
                'Alias__c'                          => 'A',
                'Field__c'                          => 'TestCheckBox__c',
                'FieldType__c'                      => 'BOOLEAN',
                'Operator__c'                       => 'Any Change',
                'CompareWith__c'                    => 'it-self'
        };
        Map<String,Object> equalProperty = new Map<String,Object>{
                'NotificationAutomaticSetting__c'   => setting.Id,
                'Alias__c'                          => 'B',
                'Field__c'                          => 'TestCheckBox__c',
                'FieldType__c'                      => 'BOOLEAN',
                'Operator__c'                       => 'Not equal to',
                'CompareWith__c'                    => 'it-self',
                'BOOLEAN__c'                        => true
        };
        Map<String,Object> notEqualProperty = new Map<String,Object>{
                'NotificationAutomaticSetting__c'   => setting.Id,
                'Alias__c'                          => 'C',
                'Field__c'                          => 'TestCheckBox__c',
                'FieldType__c'                      => 'BOOLEAN',
                'Operator__c'                       => 'Not equal to',
                'CompareWith__c'                    => 'it-self',
                'BOOLEAN__c'                        => true
        };

        List<Map<String,Object>> conditionProperties = new List<Map<String,Object>>();
        conditionProperties.add(anyChangeProperty);
        conditionProperties.add(equalProperty);
        conditionProperties.add(notEqualProperty);

        return i2SEMA_TestDataUtil.getNotificationAutomaticCondition(conditionProperties);
    }
    public static List<NotificationAutomaticCondition__c> getCurrencyCondition(NotificationAutomaticSetting__c setting){
        Map<String,Object> anyChangeProperty    = new Map<String,Object>{
                'NotificationAutomaticSetting__c'   => setting.Id,
                'Alias__c'                          => 'A',
                'Field__c'                          => 'TestCurrency__c',
                'FieldType__c'                      => Schema.DisplayType.CURRENCY.name(),
                'Operator__c'                       => 'Any Change',
                'CompareWith__c'                    => 'it-self'
        };
        Map<String,Object> equalProperty        = new Map<String,Object>{
                'NotificationAutomaticSetting__c'   => setting.Id,
                'Alias__c'                          => 'B',
                'Field__c'                          => 'TestCurrency__c',
                'FieldType__c'                      => Schema.DisplayType.CURRENCY.name(),
                'Operator__c'                       => 'Equals',
                'CompareWith__c'                    => 'it-self',
                'CURRENCY__c'                       => 10000
        };
        Map<String,Object> notEqualProperty     = new Map<String,Object>{
                'NotificationAutomaticSetting__c'   => setting.Id,
                'Alias__c'                          => 'C',
                'Field__c'                          => 'TestCurrency__c',
                'FieldType__c'                      => Schema.DisplayType.CURRENCY.name(),
                'Operator__c'                       => 'Not equal to',
                'CompareWith__c'                    => 'it-self',
                'CURRENCY__c'                       => 10000
        };
        Map<String,Object> greaterProperty      = new Map<String,Object>{
                'NotificationAutomaticSetting__c'   => setting.Id,
                'Alias__c'                          => 'D',
                'Field__c'                          => 'TestCurrency__c',
                'FieldType__c'                      => Schema.DisplayType.CURRENCY.name(),
                'Operator__c'                       => 'Greater than',
                'CompareWith__c'                    => 'it-self',
                'CURRENCY__c'                       => 10000
        };
        Map<String,Object> greaterEqualProperty = new Map<String,Object>{
                'NotificationAutomaticSetting__c'   => setting.Id,
                'Alias__c'                          => 'E',
                'Field__c'                          => 'TestCurrency__c',
                'FieldType__c'                      => Schema.DisplayType.CURRENCY.name(),
                'Operator__c'                       => 'Greater than or Equal',
                'CompareWith__c'                    => 'it-self',
                'CURRENCY__c'                       => 10000
        };
        Map<String,Object> lessProperty         = new Map<String,Object>{
                'NotificationAutomaticSetting__c'   => setting.Id,
                'Alias__c'                          => 'F',
                'Field__c'                          => 'TestCurrency__c',
                'FieldType__c'                      => Schema.DisplayType.CURRENCY.name(),
                'Operator__c'                       => 'Less than',
                'CompareWith__c'                    => 'it-self',
                'CURRENCY__c'                       => 10000
        };
        Map<String,Object> lessEqualProperty    = new Map<String,Object>{
                'NotificationAutomaticSetting__c'   => setting.Id,
                'Alias__c'                          => 'G',
                'Field__c'                          => 'TestCurrency__c',
                'FieldType__c'                      => Schema.DisplayType.CURRENCY.name(),
                'Operator__c'                       => 'Less than or Equal',
                'CompareWith__c'                    => 'it-self',
                'CURRENCY__c'                       => 10000
        };
        Map<String,Object> emptyProperty        = new Map<String,Object>{
                'NotificationAutomaticSetting__c'   => setting.Id,
                'Alias__c'                          => 'H',
                'Field__c'                          => 'TestCurrency__c',
                'FieldType__c'                      => Schema.DisplayType.CURRENCY.name(),
                'Operator__c'                       => 'Empty',
                'CompareWith__c'                    => 'it-self'
        };
        Map<String,Object> notEmptyProperty        = new Map<String,Object>{
                'NotificationAutomaticSetting__c'   => setting.Id,
                'Alias__c'                          => 'I',
                'Field__c'                          => 'TestCurrency__c',
                'FieldType__c'                      => Schema.DisplayType.CURRENCY.name(),
                'Operator__c'                       => 'Not Empty',
                'CompareWith__c'                    => 'it-self'
        };

        List<Map<String,Object>> conditionProperties = new List<Map<String,Object>>();
        conditionProperties.add(anyChangeProperty);
        conditionProperties.add(equalProperty);
        conditionProperties.add(notEqualProperty);
        conditionProperties.add(greaterProperty);
        conditionProperties.add(greaterEqualProperty);
        conditionProperties.add(lessProperty);
        conditionProperties.add(lessEqualProperty);
        conditionProperties.add(emptyProperty);
        conditionProperties.add(notEmptyProperty);

        return i2SEMA_TestDataUtil.getNotificationAutomaticCondition(conditionProperties);
    }


    public static List<NotificationAutomaticCondition__c> getDecimalCondition(NotificationAutomaticSetting__c setting){
        Map<String,Object> anyChangeProperty    = new Map<String,Object>{
                'NotificationAutomaticSetting__c'   => setting.Id,
                'Alias__c'                          => 'A',
                'Field__c'                          => 'TestNumber__c',
                'FieldType__c'                      => Schema.DisplayType.DOUBLE.name(),
                'Operator__c'                       => 'Any Change',
                'CompareWith__c'                    => 'it-self'
        };
        Map<String,Object> equalProperty        = new Map<String,Object>{
                'NotificationAutomaticSetting__c'   => setting.Id,
                'Alias__c'                          => 'B',
                'Field__c'                          => 'TestNumber__c',
                'FieldType__c'                      => Schema.DisplayType.DOUBLE.name(),
                'Operator__c'                       => 'Equals',
                'CompareWith__c'                    => 'it-self',
                'DOUBLE__c'                         => 10000
        };
        Map<String,Object> notEqualProperty     = new Map<String,Object>{
                'NotificationAutomaticSetting__c'   => setting.Id,
                'Alias__c'                          => 'C',
                'Field__c'                          => 'TestNumber__c',
                'FieldType__c'                      => Schema.DisplayType.DOUBLE.name(),
                'Operator__c'                       => 'Not equal to',
                'CompareWith__c'                    => 'it-self',
                'DOUBLE__c'                         => 10000
        };
        Map<String,Object> greaterProperty      = new Map<String,Object>{
                'NotificationAutomaticSetting__c'   => setting.Id,
                'Alias__c'                          => 'D',
                'Field__c'                          => 'TestNumber__c',
                'FieldType__c'                      => Schema.DisplayType.DOUBLE.name(),
                'Operator__c'                       => 'Greater than',
                'CompareWith__c'                    => 'it-self',
                'DOUBLE__c'                         => 10000
        };
        Map<String,Object> greaterEqualProperty = new Map<String,Object>{
                'NotificationAutomaticSetting__c'   => setting.Id,
                'Alias__c'                          => 'E',
                'Field__c'                          => 'TestNumber__c',
                'FieldType__c'                      => Schema.DisplayType.DOUBLE.name(),
                'Operator__c'                       => 'Greater than or Equal',
                'CompareWith__c'                    => 'it-self',
                'DOUBLE__c'                         => 10000
        };
        Map<String,Object> lessProperty         = new Map<String,Object>{
                'NotificationAutomaticSetting__c'   => setting.Id,
                'Alias__c'                          => 'F',
                'Field__c'                          => 'TestNumber__c',
                'FieldType__c'                      => Schema.DisplayType.DOUBLE.name(),
                'Operator__c'                       => 'Less than',
                'CompareWith__c'                    => 'it-self',
                'DOUBLE__c'                         => 10000
        };
        Map<String,Object> lessEqualProperty    = new Map<String,Object>{
                'NotificationAutomaticSetting__c'   => setting.Id,
                'Alias__c'                          => 'G',
                'Field__c'                          => 'TestNumber__c',
                'FieldType__c'                      => Schema.DisplayType.DOUBLE.name(),
                'Operator__c'                       => 'Less than or Equal',
                'CompareWith__c'                    => 'it-self',
                'DOUBLE__c'                         => 10000
        };
        Map<String,Object> emptyProperty        = new Map<String,Object>{
                'NotificationAutomaticSetting__c'   => setting.Id,
                'Alias__c'                          => 'H',
                'Field__c'                          => 'TestNumber__c',
                'FieldType__c'                      => Schema.DisplayType.DOUBLE.name(),
                'Operator__c'                       => 'Empty',
                'CompareWith__c'                    => 'it-self'
        };
        Map<String,Object> notEmptyProperty        = new Map<String,Object>{
                'NotificationAutomaticSetting__c'   => setting.Id,
                'Alias__c'                          => 'I',
                'Field__c'                          => 'TestNumber__c',
                'FieldType__c'                      => Schema.DisplayType.DOUBLE.name(),
                'Operator__c'                       => 'Not Empty',
                'CompareWith__c'                    => 'it-self'
        };

        List<Map<String,Object>> conditionProperties = new List<Map<String,Object>>();
        conditionProperties.add(anyChangeProperty);
        conditionProperties.add(equalProperty);
        conditionProperties.add(notEqualProperty);
        conditionProperties.add(greaterProperty);
        conditionProperties.add(greaterEqualProperty);
        conditionProperties.add(lessProperty);
        conditionProperties.add(lessEqualProperty);
        conditionProperties.add(emptyProperty);
        conditionProperties.add(notEmptyProperty);

        return i2SEMA_TestDataUtil.getNotificationAutomaticCondition(conditionProperties);
    }

    public static List<NotificationAutomaticCondition__c> getDateTimeCondition(NotificationAutomaticSetting__c setting){
        Map<String,Object> anyChangeProperty    = new Map<String,Object>{
                'NotificationAutomaticSetting__c'   => setting.Id,
                'Alias__c'                          => 'A',
                'Field__c'                          => 'TestDateTime__c',
                'FieldType__c'                      => Schema.DisplayType.DATETIME.name(),
                'Operator__c'                       => 'Any Change',
                'CompareWith__c'                    => 'it-self'
        };
        Map<String,Object> equalProperty        = new Map<String,Object>{
                'NotificationAutomaticSetting__c'   => setting.Id,
                'Alias__c'                          => 'B',
                'Field__c'                          => 'TestDateTime__c',
                'FieldType__c'                      => Schema.DisplayType.DATETIME.name(),
                'Operator__c'                       => 'Equals',
                'CompareWith__c'                    => 'it-self',
                'DATETIME__c'                       => Datetime.now()
        };
        Map<String,Object> notEqualProperty     = new Map<String,Object>{
                'NotificationAutomaticSetting__c'   => setting.Id,
                'Alias__c'                          => 'C',
                'Field__c'                          => 'TestDateTime__c',
                'FieldType__c'                      => Schema.DisplayType.DATETIME.name(),
                'Operator__c'                       => 'Not equal to',
                'CompareWith__c'                    => 'it-self',
                'DATETIME__c'                       => Datetime.now()
        };
        Map<String,Object> greaterProperty      = new Map<String,Object>{
                'NotificationAutomaticSetting__c'   => setting.Id,
                'Alias__c'                          => 'D',
                'Field__c'                          => 'TestDateTime__c',
                'FieldType__c'                      => Schema.DisplayType.DATETIME.name(),
                'Operator__c'                       => 'Greater than',
                'CompareWith__c'                    => 'it-self',
                'DATETIME__c'                       => Datetime.now()
        };
        Map<String,Object> greaterEqualProperty = new Map<String,Object>{
                'NotificationAutomaticSetting__c'   => setting.Id,
                'Alias__c'                          => 'E',
                'Field__c'                          => 'TestDateTime__c',
                'FieldType__c'                      => Schema.DisplayType.DATETIME.name(),
                'Operator__c'                       => 'Greater than or Equal',
                'CompareWith__c'                    => 'it-self',
                'DATETIME__c'                       => Datetime.now()
        };
        Map<String,Object> lessProperty         = new Map<String,Object>{
                'NotificationAutomaticSetting__c'   => setting.Id,
                'Alias__c'                          => 'F',
                'Field__c'                          => 'TestDateTime__c',
                'FieldType__c'                      => Schema.DisplayType.DATETIME.name(),
                'Operator__c'                       => 'Less than',
                'CompareWith__c'                    => 'it-self',
                'DATETIME__c'                       => Datetime.now()
        };
        Map<String,Object> lessEqualProperty    = new Map<String,Object>{
                'NotificationAutomaticSetting__c'   => setting.Id,
                'Alias__c'                          => 'G',
                'Field__c'                          => 'TestDateTime__c',
                'FieldType__c'                      => Schema.DisplayType.DATETIME.name(),
                'Operator__c'                       => 'Less than or Equal',
                'CompareWith__c'                    => 'it-self',
                'DATETIME__c'                       => Datetime.now()
        };
        Map<String,Object> emptyProperty        = new Map<String,Object>{
                'NotificationAutomaticSetting__c'   => setting.Id,
                'Alias__c'                          => 'H',
                'Field__c'                          => 'TestDateTime__c',
                'FieldType__c'                      => Schema.DisplayType.DATETIME.name(),
                'Operator__c'                       => 'Empty',
                'CompareWith__c'                    => 'it-self'
        };
        Map<String,Object> notEmptyProperty        = new Map<String,Object>{
                'NotificationAutomaticSetting__c'   => setting.Id,
                'Alias__c'                          => 'I',
                'Field__c'                          => 'TestDateTime__c',
                'FieldType__c'                      => Schema.DisplayType.DATETIME.name(),
                'Operator__c'                       => 'Not Empty',
                'CompareWith__c'                    => 'it-self'
        };

        List<Map<String,Object>> conditionProperties = new List<Map<String,Object>>();
        conditionProperties.add(anyChangeProperty);
        conditionProperties.add(equalProperty);
        conditionProperties.add(notEqualProperty);
        conditionProperties.add(greaterProperty);
        conditionProperties.add(greaterEqualProperty);
        conditionProperties.add(lessProperty);
        conditionProperties.add(lessEqualProperty);
        conditionProperties.add(emptyProperty);
        conditionProperties.add(notEmptyProperty);

        return i2SEMA_TestDataUtil.getNotificationAutomaticCondition(conditionProperties);
    }

    public static List<NotificationAutomaticCondition__c> getDateCondition(NotificationAutomaticSetting__c setting){
        Map<String,Object> anyChangeProperty    = new Map<String,Object>{
                'NotificationAutomaticSetting__c'   => setting.Id,
                'Alias__c'                          => 'A',
                'Field__c'                          => 'TestDate__c',
                'FieldType__c'                      => Schema.DisplayType.DATE.name(),
                'Operator__c'                       => 'Any Change',
                'CompareWith__c'                    => 'it-self'
        };
        Map<String,Object> equalProperty        = new Map<String,Object>{
                'NotificationAutomaticSetting__c'   => setting.Id,
                'Alias__c'                          => 'B',
                'Field__c'                          => 'TestDate__c',
                'FieldType__c'                      => Schema.DisplayType.DATE.name(),
                'Operator__c'                       => 'Equals',
                'CompareWith__c'                    => 'it-self',
                'DATE__c'                           => Datetime.now().date()
        };
        Map<String,Object> notEqualProperty     = new Map<String,Object>{
                'NotificationAutomaticSetting__c'   => setting.Id,
                'Alias__c'                          => 'C',
                'Field__c'                          => 'TestDate__c',
                'FieldType__c'                      => Schema.DisplayType.DATE.name(),
                'Operator__c'                       => 'Not equal to',
                'CompareWith__c'                    => 'it-self',
                'DATE__c'                           => Datetime.now().date()
        };
        Map<String,Object> greaterProperty      = new Map<String,Object>{
                'NotificationAutomaticSetting__c'   => setting.Id,
                'Alias__c'                          => 'D',
                'Field__c'                          => 'TestDate__c',
                'FieldType__c'                      => Schema.DisplayType.DATE.name(),
                'Operator__c'                       => 'Greater than',
                'CompareWith__c'                    => 'it-self',
                'DATE__c'                           => Datetime.now().date()
        };
        Map<String,Object> greaterEqualProperty = new Map<String,Object>{
                'NotificationAutomaticSetting__c'   => setting.Id,
                'Alias__c'                          => 'E',
                'Field__c'                          => 'TestDate__c',
                'FieldType__c'                      => Schema.DisplayType.DATE.name(),
                'Operator__c'                       => 'Greater than or Equal',
                'CompareWith__c'                    => 'it-self',
                'DATE__c'                           => Datetime.now().date()
        };
        Map<String,Object> lessProperty         = new Map<String,Object>{
                'NotificationAutomaticSetting__c'   => setting.Id,
                'Alias__c'                          => 'F',
                'Field__c'                          => 'TestDate__c',
                'FieldType__c'                      => Schema.DisplayType.DATE.name(),
                'Operator__c'                       => 'Less than',
                'CompareWith__c'                    => 'it-self',
                'DATE__c'                           => Datetime.now().date()
        };
        Map<String,Object> lessEqualProperty    = new Map<String,Object>{
                'NotificationAutomaticSetting__c'   => setting.Id,
                'Alias__c'                          => 'G',
                'Field__c'                          => 'TestDate__c',
                'FieldType__c'                      => Schema.DisplayType.DATE.name(),
                'Operator__c'                       => 'Less than or Equal',
                'CompareWith__c'                    => 'it-self',
                'DATE__c'                           => Datetime.now().date()
        };
        Map<String,Object> emptyProperty        = new Map<String,Object>{
                'NotificationAutomaticSetting__c'   => setting.Id,
                'Alias__c'                          => 'H',
                'Field__c'                          => 'TestDate__c',
                'FieldType__c'                      => Schema.DisplayType.DATE.name(),
                'Operator__c'                       => 'Empty',
                'CompareWith__c'                    => 'it-self'
        };
        Map<String,Object> notEmptyProperty        = new Map<String,Object>{
                'NotificationAutomaticSetting__c'   => setting.Id,
                'Alias__c'                          => 'I',
                'Field__c'                          => 'TestDate__c',
                'FieldType__c'                      => Schema.DisplayType.DATE.name(),
                'Operator__c'                       => 'Not Empty',
                'CompareWith__c'                    => 'it-self'
        };

        List<Map<String,Object>> conditionProperties = new List<Map<String,Object>>();
        conditionProperties.add(anyChangeProperty);
        conditionProperties.add(equalProperty);
        conditionProperties.add(notEqualProperty);
        conditionProperties.add(greaterProperty);
        conditionProperties.add(greaterEqualProperty);
        conditionProperties.add(lessProperty);
        conditionProperties.add(lessEqualProperty);
        conditionProperties.add(emptyProperty);
        conditionProperties.add(notEmptyProperty);

        return i2SEMA_TestDataUtil.getNotificationAutomaticCondition(conditionProperties);
    }

    public static List<NotificationAutomaticCondition__c> getTimeCondition(NotificationAutomaticSetting__c setting){
        Map<String,Object> anyChangeProperty    = new Map<String,Object>{
                'NotificationAutomaticSetting__c'   => setting.Id,
                'Alias__c'                          => 'A',
                'Field__c'                          => 'TestTime__c',
                'FieldType__c'                      => Schema.DisplayType.TIME.name(),
                'Operator__c'                       => 'Any Change',
                'CompareWith__c'                    => 'it-self'
        };
        Map<String,Object> equalProperty        = new Map<String,Object>{
                'NotificationAutomaticSetting__c'   => setting.Id,
                'Alias__c'                          => 'B',
                'Field__c'                          => 'TestTime__c',
                'FieldType__c'                      => Schema.DisplayType.TIME.name(),
                'Operator__c'                       => 'Equals',
                'CompareWith__c'                    => 'it-self',
                'TIME__c'                           => Datetime.now().time()
        };
        Map<String,Object> notEqualProperty     = new Map<String,Object>{
                'NotificationAutomaticSetting__c'   => setting.Id,
                'Alias__c'                          => 'C',
                'Field__c'                          => 'TestTime__c',
                'FieldType__c'                      => Schema.DisplayType.TIME.name(),
                'Operator__c'                       => 'Not equal to',
                'CompareWith__c'                    => 'it-self',
                'TIME__c'                           => Datetime.now().time()
        };
        Map<String,Object> greaterProperty      = new Map<String,Object>{
                'NotificationAutomaticSetting__c'   => setting.Id,
                'Alias__c'                          => 'D',
                'Field__c'                          => 'TestTime__c',
                'FieldType__c'                      => Schema.DisplayType.TIME.name(),
                'Operator__c'                       => 'Greater than',
                'CompareWith__c'                    => 'it-self',
                'TIME__c'                           => Datetime.now().time()
        };
        Map<String,Object> greaterEqualProperty = new Map<String,Object>{
                'NotificationAutomaticSetting__c'   => setting.Id,
                'Alias__c'                          => 'E',
                'Field__c'                          => 'TestTime__c',
                'FieldType__c'                      => Schema.DisplayType.TIME.name(),
                'Operator__c'                       => 'Greater than or Equal',
                'CompareWith__c'                    => 'it-self',
                'TIME__c'                           => Datetime.now().time()
        };
        Map<String,Object> lessProperty         = new Map<String,Object>{
                'NotificationAutomaticSetting__c'   => setting.Id,
                'Alias__c'                          => 'F',
                'Field__c'                          => 'TestTime__c',
                'FieldType__c'                      => Schema.DisplayType.TIME.name(),
                'Operator__c'                       => 'Less than',
                'CompareWith__c'                    => 'it-self',
                'TIME__c'                           => Datetime.now().time()
        };
        Map<String,Object> lessEqualProperty    = new Map<String,Object>{
                'NotificationAutomaticSetting__c'   => setting.Id,
                'Alias__c'                          => 'G',
                'Field__c'                          => 'TestTime__c',
                'FieldType__c'                      => Schema.DisplayType.TIME.name(),
                'Operator__c'                       => 'Less than or Equal',
                'CompareWith__c'                    => 'it-self',
                'TIME__c'                           => Datetime.now().time()
        };
        Map<String,Object> emptyProperty        = new Map<String,Object>{
                'NotificationAutomaticSetting__c'   => setting.Id,
                'Alias__c'                          => 'H',
                'Field__c'                          => 'TestTime__c',
                'FieldType__c'                      => Schema.DisplayType.TIME.name(),
                'Operator__c'                       => 'Empty',
                'CompareWith__c'                    => 'it-self'
        };
        Map<String,Object> notEmptyProperty        = new Map<String,Object>{
                'NotificationAutomaticSetting__c'   => setting.Id,
                'Alias__c'                          => 'I',
                'Field__c'                          => 'TestTime__c',
                'FieldType__c'                      => Schema.DisplayType.TIME.name(),
                'Operator__c'                       => 'Not Empty',
                'CompareWith__c'                    => 'it-self'
        };

        List<Map<String,Object>> conditionProperties = new List<Map<String,Object>>();
        conditionProperties.add(anyChangeProperty);
        conditionProperties.add(equalProperty);
        conditionProperties.add(notEqualProperty);
        conditionProperties.add(greaterProperty);
        conditionProperties.add(greaterEqualProperty);
        conditionProperties.add(lessProperty);
        conditionProperties.add(lessEqualProperty);
        conditionProperties.add(emptyProperty);
        conditionProperties.add(notEmptyProperty);

        return i2SEMA_TestDataUtil.getNotificationAutomaticCondition(conditionProperties);
    }

    public static List<NotificationAutomaticCondition__c> getReferenceCondition(NotificationAutomaticSetting__c setting){
        Map<String,Object> anyChangeProperty    = new Map<String,Object>{
                'NotificationAutomaticSetting__c'   => setting.Id,
                'Alias__c'                          => 'A',
                'Field__c'                          => 'TestUserReference__c',
                'FieldType__c'                      => Schema.DisplayType.REFERENCE.name(),
                'Operator__c'                       => 'Any Change',
                'CompareWith__c'                    => 'it-self'
        };
        Map<String,Object> equalProperty        = new Map<String,Object>{
                'NotificationAutomaticSetting__c'   => setting.Id,
                'Alias__c'                          => 'B',
                'Field__c'                          => 'TestUserReference__c',
                'FieldType__c'                      => Schema.DisplayType.REFERENCE.name(),
                'Operator__c'                       => 'Equals',
                'CompareWith__c'                    => 'it-self',
                'REFERENCE__c'                      => UserInfo.getUserId()
        };
        Map<String,Object> notEqualProperty     = new Map<String,Object>{
                'NotificationAutomaticSetting__c'   => setting.Id,
                'Alias__c'                          => 'C',
                'Field__c'                          => 'TestUserReference__c',
                'FieldType__c'                      => Schema.DisplayType.REFERENCE.name(),
                'Operator__c'                       => 'Not equal to',
                'CompareWith__c'                    => 'it-self',
                'REFERENCE__c'                      => UserInfo.getUserId()
        };
        Map<String,Object> emptyProperty        = new Map<String,Object>{
                'NotificationAutomaticSetting__c'   => setting.Id,
                'Alias__c'                          => 'D',
                'Field__c'                          => 'TestUserReference__c',
                'FieldType__c'                      => Schema.DisplayType.REFERENCE.name(),
                'Operator__c'                       => 'Empty',
                'CompareWith__c'                    => 'it-self'
        };
        Map<String,Object> notEmptyProperty        = new Map<String,Object>{
                'NotificationAutomaticSetting__c'   => setting.Id,
                'Alias__c'                          => 'E',
                'Field__c'                          => 'TestUserReference__c',
                'FieldType__c'                      => Schema.DisplayType.REFERENCE.name(),
                'Operator__c'                       => 'Not Empty',
                'CompareWith__c'                    => 'it-self'
        };

        List<Map<String,Object>> conditionProperties = new List<Map<String,Object>>();
        conditionProperties.add(anyChangeProperty);
        conditionProperties.add(equalProperty);
        conditionProperties.add(notEqualProperty);
        conditionProperties.add(emptyProperty);
        conditionProperties.add(notEmptyProperty);

        return i2SEMA_TestDataUtil.getNotificationAutomaticCondition(conditionProperties);
    }

    public static List<NotificationAutomaticCondition__c> getStringCondition(NotificationAutomaticSetting__c setting){
        Map<String,Object> anyChangeProperty    = new Map<String,Object>{
                'NotificationAutomaticSetting__c'   => setting.Id,
                'Alias__c'                          => 'A',
                'Field__c'                          => 'TestText__c',
                'FieldType__c'                      => Schema.DisplayType.STRING.name(),
                'Operator__c'                       => 'Any Change',
                'CompareWith__c'                    => 'it-self'
        };
        Map<String,Object> equalProperty        = new Map<String,Object>{
                'NotificationAutomaticSetting__c'   => setting.Id,
                'Alias__c'                          => 'B',
                'Field__c'                          => 'TestText__c',
                'FieldType__c'                      => Schema.DisplayType.STRING.name(),
                'Operator__c'                       => 'Equals',
                'CompareWith__c'                    => 'it-self',
                'STRING__c'                         => 'AA'
        };
        Map<String,Object> notEqualProperty     = new Map<String,Object>{
                'NotificationAutomaticSetting__c'   => setting.Id,
                'Alias__c'                          => 'C',
                'Field__c'                          => 'TestText__c',
                'FieldType__c'                      => Schema.DisplayType.STRING.name(),
                'Operator__c'                       => 'Not equal to',
                'CompareWith__c'                    => 'it-self',
                'STRING__c'                         => 'AA'
        };
        Map<String,Object> greaterProperty      = new Map<String,Object>{
                'NotificationAutomaticSetting__c'   => setting.Id,
                'Alias__c'                          => 'D',
                'Field__c'                          => 'TestText__c',
                'FieldType__c'                      => Schema.DisplayType.STRING.name(),
                'Operator__c'                       => 'Greater than',
                'CompareWith__c'                    => 'it-self',
                'STRING__c'                         => 'AA'
        };
        Map<String,Object> greaterEqualProperty = new Map<String,Object>{
                'NotificationAutomaticSetting__c'   => setting.Id,
                'Alias__c'                          => 'E',
                'Field__c'                          => 'TestText__c',
                'FieldType__c'                      => Schema.DisplayType.STRING.name(),
                'Operator__c'                       => 'Greater than or Equal',
                'CompareWith__c'                    => 'it-self',
                'STRING__c'                         => 'AA'
        };
        Map<String,Object> lessProperty         = new Map<String,Object>{
                'NotificationAutomaticSetting__c'   => setting.Id,
                'Alias__c'                          => 'F',
                'Field__c'                          => 'TestText__c',
                'FieldType__c'                      => Schema.DisplayType.STRING.name(),
                'Operator__c'                       => 'Less than',
                'CompareWith__c'                    => 'it-self',
                'STRING__c'                         => 'AA'
        };
        Map<String,Object> lessEqualProperty    = new Map<String,Object>{
                'NotificationAutomaticSetting__c'   => setting.Id,
                'Alias__c'                          => 'G',
                'Field__c'                          => 'TestText__c',
                'FieldType__c'                      => Schema.DisplayType.STRING.name(),
                'Operator__c'                       => 'Less than or Equal',
                'CompareWith__c'                    => 'it-self',
                'STRING__c'                         => 'AA'
        };
        Map<String,Object> emptyProperty        = new Map<String,Object>{
                'NotificationAutomaticSetting__c'   => setting.Id,
                'Alias__c'                          => 'H',
                'Field__c'                          => 'TestText__c',
                'FieldType__c'                      => Schema.DisplayType.STRING.name(),
                'Operator__c'                       => 'Empty',
                'CompareWith__c'                    => 'it-self'
        };
        Map<String,Object> notEmptyProperty        = new Map<String,Object>{
                'NotificationAutomaticSetting__c'   => setting.Id,
                'Alias__c'                          => 'I',
                'Field__c'                          => 'TestText__c',
                'FieldType__c'                      => Schema.DisplayType.STRING.name(),
                'Operator__c'                       => 'Not Empty',
                'CompareWith__c'                    => 'it-self'
        };
        Map<String,Object> containsProperty        = new Map<String,Object>{
                'NotificationAutomaticSetting__c'   => setting.Id,
                'Alias__c'                          => 'J',
                'Field__c'                          => 'TestText__c',
                'FieldType__c'                      => Schema.DisplayType.STRING.name(),
                'Operator__c'                       => 'Contains',
                'CompareWith__c'                    => 'it-self'
        };
        Map<String,Object> notContainsProperty        = new Map<String,Object>{
                'NotificationAutomaticSetting__c'   => setting.Id,
                'Alias__c'                          => 'K',
                'Field__c'                          => 'TestText__c',
                'FieldType__c'                      => Schema.DisplayType.STRING.name(),
                'Operator__c'                       => 'Does not contain',
                'CompareWith__c'                    => 'it-self'
        };
        Map<String,Object> startWithProperty        = new Map<String,Object>{
                'NotificationAutomaticSetting__c'   => setting.Id,
                'Alias__c'                          => 'L',
                'Field__c'                          => 'TestText__c',
                'FieldType__c'                      => Schema.DisplayType.STRING.name(),
                'Operator__c'                       => 'Start with',
                'CompareWith__c'                    => 'it-self'
        };
        Map<String,Object> endWithProperty        = new Map<String,Object>{
                'NotificationAutomaticSetting__c'   => setting.Id,
                'Alias__c'                          => 'M',
                'Field__c'                          => 'TestText__c',
                'FieldType__c'                      => Schema.DisplayType.STRING.name(),
                'Operator__c'                       => 'End with',
                'CompareWith__c'                    => 'it-self'
        };

        List<Map<String,Object>> conditionProperties = new List<Map<String,Object>>();
        conditionProperties.add(anyChangeProperty);
        conditionProperties.add(equalProperty);
        conditionProperties.add(notEqualProperty);
        conditionProperties.add(greaterProperty);
        conditionProperties.add(greaterEqualProperty);
        conditionProperties.add(lessProperty);
        conditionProperties.add(lessEqualProperty);
        conditionProperties.add(emptyProperty);
        conditionProperties.add(notEmptyProperty);
        conditionProperties.add(containsProperty);
        conditionProperties.add(notContainsProperty);
        conditionProperties.add(startWithProperty);
        conditionProperties.add(endWithProperty);

        return i2SEMA_TestDataUtil.getNotificationAutomaticCondition(conditionProperties);
    }

    public static List<NotificationAutomaticCondition__c> getStringFieldCompareCondition(NotificationAutomaticSetting__c setting){
        Map<String,Object> equalProperty        = new Map<String,Object>{
                'NotificationAutomaticSetting__c'   => setting.Id,
                'Alias__c'                          => 'A',
                'Field__c'                          => 'TestText__c',
                'FieldType__c'                      => Schema.DisplayType.STRING.name(),
                'Operator__c'                       => 'Equals',
                'CompareWith__c'                    => 'other field',
                'CompareField__c'                   => 'TestText__c'
        };
        Map<String,Object> notEqualProperty     = new Map<String,Object>{
                'NotificationAutomaticSetting__c'   => setting.Id,
                'Alias__c'                          => 'B',
                'Field__c'                          => 'TestText__c',
                'FieldType__c'                      => Schema.DisplayType.STRING.name(),
                'Operator__c'                       => 'Not equal to',
                'CompareWith__c'                    => 'other field',
                'CompareField__c'                   => 'TestText__c'
        };

        List<Map<String,Object>> conditionProperties = new List<Map<String,Object>>();
        conditionProperties.add(equalProperty);
        conditionProperties.add(notEqualProperty);

        return i2SEMA_TestDataUtil.getNotificationAutomaticCondition(conditionProperties);
    }

    public static NotificationAutomaticTest__c getAutomaticTestRecord(Map<String,Object> additionalProperty){
        if( con == null ){
            getContact();
        }

        Map<String,Object> properties = new Map<String,Object>{
                'TestAccountReference__c'   => acc.Id,
                'TestContactReference__c'   => con.Id,
                'TestUserReference__c'      => UserInfo.getUserId(),

                'TestCheckBox__c'           => true,
                'TestCurrency__c'           => 10000,
                'TestNumber__c'             => 5000,
                'TestDateTime__c'           => Datetime.now(),
                'TestDate__c'               => Date.today(),
                'TestTime__c'               => Datetime.now().time(),
                'TestEmail__c'              => 'AA@Salesforce.com',
                'TestText__c'               => 'Test'
        };

        properties.putAll(additionalProperty);

        // Insert 하지 않고 반환
        return (NotificationAutomaticTest__c) TestDataFactory.createSObject('NotificationAutomaticTest__c',properties,false);
    }
}