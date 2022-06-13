/****************************************************************************************
  * @filename       : i2SEMA_Base
  * @projectname    : i2sema
  * @author         : i2max_byeon.jw
  * @date           : 2020-04-06 오후 3:01
  * @group          : 
  * @group-content  : 
  * @description    : 
  * @tester         : i2SEMA_Base_ts.cls
  * @reference      : 
  * @copyright      : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                author              description
  * ===============================================================
    0.1     2020-04-06 오후 3:01     i2max_byeon.jw       Create
****************************************************************************************/

global virtual inherited sharing class i2SEMA_Base {

    /**
     * @description 자동화처리 가능한 필드 타입 정의
     *  - Schema SObject-SObjectField Display Type
     *  - ID,Reference (Record-Edit-Form 의 Lookup Readonly 버그), Multi-Picklist, TextArea(Long,Rich..) 지원하지 않는다
     */
    private static final Set<Schema.DisplayType> SUPPORTED_TYPES = new Set<Schema.DisplayType>{
        Schema.DisplayType.BOOLEAN,         // Check Box 타입
        Schema.DisplayType.CURRENCY,        // Currency 타입
        Schema.DisplayType.DATETIME,        // DateTime 타입
        Schema.DisplayType.DATE,            // Date 타입
        Schema.DisplayType.TIME,            // Time 타입
        Schema.DisplayType.EMAIL,           // Email 타입
        Schema.DisplayType.DOUBLE,          // Number(16,2) 타입
        Schema.DisplayType.LONG,            // Number(16,2) 타입
        Schema.DisplayType.INTEGER,         // Number(18,0) 타입
        Schema.DisplayType.PERCENT,         // Percent(16,2) 타입
        Schema.DisplayType.PHONE,           // Phone 타입
//        Schema.DisplayType.REFERENCE,       // Text(18) 타입
        Schema.DisplayType.PICKLIST,        // String(255) 타입
        Schema.DisplayType.STRING           // String(255) 타입
    };
    /**
     * @description 자동화 조건으로 설정되는 필드의 타입에 따라 조건식에 저장되는 위치
     *
     *  ex) 'Account 의 Name 필드값이 ABC 로 업데이트 될때' 라는 자동화 조건
     *   - NotificationAutomaticSetting__c 오브젝트
     *      ObjectType__c   : Account   (Schema Object Name 저장)
     *      ExecuteOn__c    : Update
     *   - NotificationAutomaticCondition__c 오브젝트
     *      Field__c        : Name      (Schema Field Name 저장)
     *      FieldType__c    : STRING    (Schema.DisplayType 저장)
     *      XX Value__c     : ABC       (XX 에 들어가는 필드값)
     */
    private static final Map<String,String> TYPE_SAVE_AS = new Map<String,String>{
        Schema.DisplayType.BOOLEAN.name()          => Schema.DisplayType.BOOLEAN.name(),       // Schema.DisplayType == BOOLEAN 필드값은 자동화조건 오브젝트의 BOOLEAN  필드에 저장
        Schema.DisplayType.CURRENCY.name()         => Schema.DisplayType.CURRENCY.name(),      // Schema.DisplayType == CURRENCY 필드값은 자동화조건 오브젝트의 CURRENCY 필드에 저장
        Schema.DisplayType.DATETIME.name()         => Schema.DisplayType.DATETIME.name(),      // Schema.DisplayType == DATETIME  필드값은 자동화조건 오브젝트의 DATETIME 필드에 저장
        Schema.DisplayType.DATE.name()             => Schema.DisplayType.DATE.name(),          // Schema.DisplayType == DATE 필드값은 자동화조건 오브젝트의 DATE 필드에 저장
        Schema.DisplayType.TIME.name()             => Schema.DisplayType.TIME.name(),          // Schema.DisplayType == TIME 필드값은 자동화조건 오브젝트의 TIME 필드에 저장
        Schema.DisplayType.EMAIL.name()            => Schema.DisplayType.EMAIL.name(),         // Schema.DisplayType == EMAIL 필드값은 자동화조건 오브젝트의 EMAIL 필드에 저장
        Schema.DisplayType.DOUBLE.name()           => Schema.DisplayType.DOUBLE.name(),        // Schema.DisplayType == DOUBLE 필드값은 자동화조건 오브젝트의 DOUBLE 필드에 저장
        Schema.DisplayType.LONG.name()             => Schema.DisplayType.LONG.name(),          // Schema.DisplayType == LONG 필드값은 자동화조건 오브젝트의 LONG 필드에 저장
        Schema.DisplayType.INTEGER.name()          => Schema.DisplayType.INTEGER.name(),       // Schema.DisplayType == INTEGER 필드값은 자동화조건 오브젝트의 INTEGER 필드에 저장
        Schema.DisplayType.PERCENT.name()          => Schema.DisplayType.PERCENT.name(),       // Schema.DisplayType == PERCENT 필드값은 자동화조건 오브젝트의 PERCENT 필드에 저장
        Schema.DisplayType.PHONE.name()            => Schema.DisplayType.PHONE.name(),         // Schema.DisplayType == PHONE 필드값은 자동화조건 오브젝트의 PHONE 필드에 저장
//        Schema.DisplayType.REFERENCE.name()        => Schema.DisplayType.REFERENCE.name(),     // Schema.DisplayType == REFERENCE 필드값은 자동화조건 오브젝트의 REFERENCE 필드에 저장
        Schema.DisplayType.PICKLIST.name()         => Schema.DisplayType.PICKLIST.name(),      // Schema.DisplayType == PICKLIST 필드값은 자동화조건 오브젝트의 PICKLIST 필드에 저장
        Schema.DisplayType.STRING.name()           => Schema.DisplayType.STRING.name()         // Schema.DisplayType == STRING 필드값은 자동화조건 오브젝트의 STRING 필드에 저장
    };

    /* Constants */
    private static final String IF_FILE_STATUS      = 'URL'; //파일 인터페이스 시 파일 전송 상태 (URL, FILE)
    private static final String PREFIX_ATTACH_URL   = '/servlet/servlet.FileDownload?file=';
    private static final String PREFIX_CONTENT_URL  = '/sfc/servlet.shepherd/version/renditionDownload?contentId={0}&versionId={1}&rendition={2}';

    public static  Organization ORGANIZATION {
        get{
            if( ORGANIZATION == null ){
                ORGANIZATION = [SELECT Id, IsSandbox FROM Organization WHERE Id=:UserInfo.getOrganizationId() LIMIT 1];
            }
            return ORGANIZATION;
        }
        private set;
    }
    /**
     * @description Custom Setting Notiforce 팩키지 I2SEMA 설정값
     */
    public static i2SEMA_Config__c CONFIG {
        get{
            if( CONFIG == null && !Test.isRunningTest()){
                CONFIG = i2SEMA_Config__c.getInstance();
            }
            else if(CONFIG == null && Test.isRunningTest()){
                CONFIG = i2SEMA_TestDataUtil.getI2SEMAConfigValue();
            }
            return CONFIG;
        }
        private set;
    }
    /**
     * @description Custom Setting 인터페이스 상수 값 (IfStaticValue) I2SEMA 설정값
     */
    public static Notiforce_IfStaticValue__c I2SEMA {
        get{
            if( I2SEMA == null && !Test.isRunningTest()){
                I2SEMA = Notiforce_IfStaticValue__c.getInstance('I2SEMA');
            }
            else if(I2SEMA == null && Test.isRunningTest()){
                I2SEMA = i2SEMA_TestDataUtil.getIfStaticValue();
            }
            return I2SEMA;
        }
        private set;
    }

    /**
     * Custom Setting I2SEMA 인터페이스 상수값 사용
     * @description 발송자 대표 전화번호 취득
     * @return {String} 발송자 대표 전화번호
     */
    public static String getSenderNumber(){
        return I2SEMA.dsptch_num__c;
    }

    /**
     * Custom Setting I2SEMA 인터페이스 상수값 사용
     * @description 카카오 알림톡/친구톡용 비즈니스 아이디 취득
     * @return {String} 카카오비즈 아이디
     */
    public static String getKakaoBizId(){
        return I2SEMA.kakaobizId__c;
    }

    /**
     * Custom Setting I2SEMA 인터페이스 상수값 사용
     * @description  수신 차단 신청 080 ARS 전화번호 취득
     * @return {String} 080 ARS 전화번호
     */
    public static String get080ARSNumber(){
        return I2SEMA.ars_num__c;
    }

    /**
     * Custom Setting CONFIG 설정값 사용
     * @description 파일 인터페이스를 Byte Stream으로 전송할지 URL로 전송할지 설정값 반환
     * @return {String} FALSE : URL , TRUE : Byte Stream
     */
    public static String getIFFileStatus(){
        return CONFIG.IFFileStatus__c==FALSE?'URL':'FILE';
    }

    /**
     * @description Attachment Id를 통해 파일 URL을 반환한다.
     * @param attachId {String} Attachment Id
     *
     * @return {String} file URL
     */
    public static String getAttachmentURL(String attachId){
        return getBaseOrgUrl()+PREFIX_ATTACH_URL+attachId;
    }

    /**
     * @description ContentDocument Id를 통해 파일 URL 을 반환한다.
     * @param attachId {String} Attachment Id
     * e.g)/sfc/servlet.shepherd/version/renditionDownload?rendition=ORIGINAL_Png&versionId=0682w000000TfyS&operationContext=CHATTER&contentId=05T2w000000UKju
     * @return {String} file URL
     */
    public static String getContentDocumentURL(String contentId, String versionId, String type){
        return getBaseOrgUrl()+String.format(PREFIX_CONTENT_URL, new String[]{contentId,versionId,type});
    }

    /**
     * @description Org domain url 정보 취득
     * @return {String} Org URL Domain
     */
    public static String getBaseOrgUrl() {
        return URL.getSalesforceBaseUrl().toExternalForm();
    }

    /**
     * @description SMS Byte Limit 획득
     * @return {Integer} SMS Byte Limit
     */
    public static Integer getSMSByteLimit(){
        return Integer.valueOf(CONFIG.SMSTextLimit__c);
    }

    /**
     * @description MMS Byte Limit 획득
     * @return {Integer} MMS Byte Limit
     */
    public static Integer getMMSByteLmit(){
        return Integer.valueOf(CONFIG.MMSTextLimit__c);
    }

    /**
     * @description LMS Byte Limit 획득
     * @return {Integer} LMS Byte Limit
     */
    public static Integer getLMSByteLimit(){
        return Integer.valueOf(CONFIG.LMSTextLimit__c);
    }

    /**
     * @description Kakao Friend Talk Byte Limit 획득
     * @return {Integer} Kakao Friend Talk Byte Limit
     */
    public static Integer getKakaoFriendTalkByteLimit(){
        return Integer.valueOf(CONFIG.KakaoFriendTalkTextLimit__c);
    }

    /**
     * @description Kakao Notification Talk Byte Limit 획득
     * @return {Integer} Kakao Notification Talk Byte Limit
     */
    public static Integer getKakaoNotificationTalkByteLimit(){
        return Integer.valueOf(CONFIG.KakaoNotificationTalkTextLimit__c);
    }

    /**
     * @description Chatter Byte Limit 획득
     * @return {Integer} Chatter Byte Limit
     */
    public static Integer getChatterByteLimit(){
        return Integer.valueOf(CONFIG.ChatterTextLimit__c);
    }

    /**
     * @description Notification 자동발신 처리건수 제한
     * @return {Integer} Event Execute Limit
     */
    public static Integer getEventExecuteLimit(){
        return Integer.valueOf(CONFIG.EventExecuteLimit__c);
    }

    /**
     * @description 예약발신 최소 Delay 획득
     * @return {Integer} 예약발신 최소 Delay (Minute)
     */
    public static Integer getReservationMinTime(){
        return Integer.valueOf(CONFIG.ReservationMInTime__c);
    }

    /**
     * @description 예약발신 최대 Delay 획득
     * @return {Integer} 예약발신 최대 Delay (Month)
     */
    public static Integer getReservationMaxTime(){
        return Integer.valueOf(CONFIG.ReservationMaxTime__c);
    }

    /**
     * @description Client 측 로그표기 여부 획득
     * @return {Boolean} 로그표기 여부
     */
    public static Boolean getClientSideLogFlag(){
        return CONFIG.ClientSideLog__c;
    }
    /**
     * @description Account Phone Field API 획득
     * @return {String}
     */
    public static String getAccountDefaultPhoneField(){
        return CONFIG.AccountPhone__c;
    }
    /**
     * @description Contact Phone Field API 획득
     * @return {String}
     */
    public static String getContactDefaultPhoneField(){
        return CONFIG.ContactPhone__c;
    }
    /**
     * @description Lead Phone Field API 획득
     * @return {String}
     */
    public static String getLeadDefaultPhoneField(){
        return CONFIG.LeadPhone__c;
    }
    /**
     * @description User Phone Field API 획득
     * @return {String}
     */
    public static String getUserDefaultPhoneField(){
        return CONFIG.UserPhone__c;
    }
    /**
     * @description 현재 Org 의 Chatter 활성화 여부 판정
     */
    public static Boolean checkChatterEnabled(){
        Map<String,Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
        return globalDescribe.containsKey('FeedItem');
    }

    /**
     * @description Component 참조정보 획득
     * @param sObjectTypes {List<String>} Label 획득을 위한 SObject 목록
     * @return {pilot_I2SEMA_Base.BaseData} 초기 참조정보
     */
    @AuraEnabled
    public static i2SEMA_ComponentResponse getComponentBaseData(){
        return getComponentBaseData(new List<String>());
    }
    @AuraEnabled
    public static i2SEMA_ComponentResponse getComponentBaseData(List<String> typeStrings){
        i2SEMA_ComponentResponse response = new i2SEMA_ComponentResponse();

        response.setData('config',i2SEMA_Base.CONFIG);
        response.setData('objectType',i2SEMA_Util.getSObjectDescribe(typeStrings));

        return response;
    }
    /**
     * @description 자동화, 지원 데이터 타입 획득
     */
    public static Set<Schema.DisplayType> getSupportedTypes(){
        return SUPPORTED_TYPES;
    }
    /**
     * @description 자동화, 데이터 타입별 저장필드 획득
     */
    public static Map<String,String> getTypeSaveAs(){
        return TYPE_SAVE_AS;
    }
}