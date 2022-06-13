/****************************************************************************************
  * @filename       : i2SEMA_AutomaticNotification_tr_ts
  * @projectname    : i2SEMA Core
  * @author         : i2max_byeon.jw
  * @date           : 2020-04-22 오후 4:44
  * @group          : 
  * @group-content  : 
  * @description    : 
  * @tester         : i2SEMA_AutomaticNotification_tr_ts_Test.cls
  * @reference      : 
  * @copyright      : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                author              description
  * ===============================================================
    0.1     2020-04-22 오후 4:44     i2max_byeon.jw       Create
****************************************************************************************/

@IsTest
private class i2SEMA_AutomaticNotification_tr_ts {

    // 자동발신 테스트 레코드
    static Account account;
    static Contact contact;

    // 발송 규칙 (실시간,예약발송)
    static NotificationAutomaticSetting__c realTimeAutomaticSetting;
    static NotificationAutomaticSetting__c scheduledAutomaticSetting;


    static {
        // Custom Setting
        IF_BaseNotiforce.staticValue = i2SEMA_TestDataUtil.getIfStaticValue();
    }

    @TestSetup
    static void setup(){
        // If Info 생성
        insert i2SEMA_TestDataUtil.getIfInfo('IF_SFDC_SEMA_0005');

        i2SEMA_TestDataUtil.getContact();
        i2SEMA_TestDataUtil.getRealTimeAutomaticSetting(new Map<String,Object>());
        i2SEMA_TestDataUtil.getScheduledAutomaticSetting(new Map<String,Object>());

    }
    static void getData(){
        List<NotificationAutomaticSetting__c> settings = [SELECT Id,IsSchedule__c FROM NotificationAutomaticSetting__c];
        for( NotificationAutomaticSetting__c setting : settings ){
            if( setting.IsSchedule__c != true){
                realTimeAutomaticSetting = setting;
            }
            else if( setting.IsSchedule__c == true ){
                scheduledAutomaticSetting = setting;
            }
        }
    }

    // Case 1. 발송규칙이 유효하지 않은 경우
    @IsTest static void testCase01(){
        getData();

        // 테스트 케이스 반복 수행을 위한 Rollback
        Savepoint sp = Database.setSavepoint();

        Map<String,Object> conditionProperty = new Map<String,Object>{
            'NotificationAutomaticSetting__c'   => realTimeAutomaticSetting.Id,
            'Alias__c'                          => 'A',
            'Field__c'                          => 'Name',
            'FieldType__c'                      => 'STRING',
            'Operator__c'                       => 'Equals',
            'CompareWith__c'                    => 'other field',
            'CompareField__c'                   => 'AnnualRevenue'  // 타입이 다른 필드와 비교
        };
        List<Map<String,Object>> conditionProperties = new List<Map<String,Object>>();
        conditionProperties.add(conditionProperty);

        List<NotificationAutomaticCondition__c> conditions = i2SEMA_TestDataUtil.getNotificationAutomaticCondition(conditionProperties);
        insert conditions;

        // 레코드 생성 자동 발송테스트
        NotificationAutomaticTest__c testRecord = new NotificationAutomaticTest__c();
        insert testRecord;

        Database.rollback(sp);
    }
    // Case 2. 발송규칙에 상세 조건이 정의되지 않은 경우
    @IsTest static void testCase02(){
        getData();
        // Interface Mock
        Test.setMock(HttpCalloutMock.class , new ManualSendInterfaceMock());

        // 테스트 케이스 반복 수행을 위한 Rollback
        Savepoint sp = Database.setSavepoint();

        realTimeAutomaticSetting.LogicalExpression__c = null;
        update realTimeAutomaticSetting;

        // 레코드 생성 자동 발송테스트
        NotificationAutomaticTest__c testRecord = new NotificationAutomaticTest__c();
        insert testRecord;

        Database.rollback(sp);
    }

    // Case 3. 레코드의 CheckBox 타입의 필드의 자동발송 조건처리
    @IsTest static void testCase03(){
        getData();
        // Interface Mock
        Test.setMock(HttpCalloutMock.class , new ManualSendInterfaceMock());

        // 자동발신 조건 설정
        realTimeAutomaticSetting.LogicalExpression__c = 'A || B || C';
        update realTimeAutomaticSetting;
        insert i2SEMA_TestDataUtil.getBooleanCondition(realTimeAutomaticSetting);

        // 발송테스트
        NotificationAutomaticTest__c testRecord = new NotificationAutomaticTest__c();
        testRecord.TestCheckBox__c = true;
        insert testRecord;
    }

    // Case 4. 레코드의 Currency 타입의 필드의 자동발송 조건처리
    @IsTest static void testCase04(){
        getData();
        // Interface Mock
        Test.setMock(HttpCalloutMock.class , new ManualSendInterfaceMock());

        // 자동발신 조건 설정
        realTimeAutomaticSetting.LogicalExpression__c = 'A || B || C || D || E || F || G || H || I';
        update realTimeAutomaticSetting;
        insert i2SEMA_TestDataUtil.getCurrencyCondition(realTimeAutomaticSetting);

        // 발송테스트
        NotificationAutomaticTest__c testRecord = new NotificationAutomaticTest__c();
        testRecord.TestCurrency__c = 15000;
        insert testRecord;
    }

    // Case 5. 레코드의 DateTime 타입의 필드의 자동발송 조건처리
    @IsTest static void testCase05(){
        getData();
        // Interface Mock
        Test.setMock(HttpCalloutMock.class , new ManualSendInterfaceMock());

        // 자동발신 조건 설정
        realTimeAutomaticSetting.LogicalExpression__c = 'A || B || C || D || E || F || G || H || I';
        update realTimeAutomaticSetting;
        insert i2SEMA_TestDataUtil.getDateTimeCondition(realTimeAutomaticSetting);

        // 발송테스트
        NotificationAutomaticTest__c testRecord = new NotificationAutomaticTest__c();
        testRecord.TestDateTime__c = Datetime.now();
        insert testRecord;
    }

    // Case 6. 레코드의 Date 타입의 필드의 자동발송 조건처리
    @IsTest static void testCase06(){
        getData();
        // Interface Mock
        Test.setMock(HttpCalloutMock.class , new ManualSendInterfaceMock());

        // 자동발신 조건 설정
        realTimeAutomaticSetting.LogicalExpression__c = 'A || B || C || D || E || F || G || H || I';
        update realTimeAutomaticSetting;
        insert i2SEMA_TestDataUtil.getDateCondition(realTimeAutomaticSetting);

        // 발송테스트
        NotificationAutomaticTest__c testRecord = new NotificationAutomaticTest__c();
        testRecord.TestDate__c = Date.today();
        insert testRecord;
    }

    // Case 7. 레코드의 Text 타입의 필드의 자동발송 조건처리
    @IsTest static void testCase07(){
        getData();
        // Interface Mock
        Test.setMock(HttpCalloutMock.class , new ManualSendInterfaceMock());

        // 자동발신 조건 설정
        realTimeAutomaticSetting.LogicalExpression__c = 'A || B || C || D || E || F || G || H || I || J || K || L || M';
        update realTimeAutomaticSetting;
        insert i2SEMA_TestDataUtil.getStringCondition(realTimeAutomaticSetting);

        // 발송테스트
        NotificationAutomaticTest__c testRecord = new NotificationAutomaticTest__c();
        testRecord.TestText__c = 'AA@salesforce.com';
        insert testRecord;
    }

    // Case 8. 레코드의 Number 타입의 필드의 자동발송 조건처리
    @IsTest static void testCase08(){
        getData();
        // Interface Mock
        Test.setMock(HttpCalloutMock.class , new ManualSendInterfaceMock());

        // 자동발신 조건 설정
        realTimeAutomaticSetting.LogicalExpression__c = 'A && B && C && D && E && F && G && H && I';
        update realTimeAutomaticSetting;
        insert i2SEMA_TestDataUtil.getDecimalCondition(realTimeAutomaticSetting);

        // 발송테스트
        NotificationAutomaticTest__c testRecord = new NotificationAutomaticTest__c();
        testRecord.TestNumber__c = 5000;
        insert testRecord;
    }

    // Case 9. 레코드의 Time 타입의 필드의 자동발송 조건처리
    @IsTest static void testCase09(){
        getData();
        // Interface Mock
        Test.setMock(HttpCalloutMock.class , new ManualSendInterfaceMock());

        // 자동발신 조건 설정
        realTimeAutomaticSetting.LogicalExpression__c = 'A && B && C && D && E && F && G && H && I';
        update realTimeAutomaticSetting;
        insert i2SEMA_TestDataUtil.getTimeCondition(realTimeAutomaticSetting);

        // 발송테스트
        NotificationAutomaticTest__c testRecord = new NotificationAutomaticTest__c();
        testRecord.TestTime__c = Datetime.now().time().addMinutes(-30);
        insert testRecord;
    }

    // Case 10. 레코드의 String 타입의 필드간 비교 발송처리
    @IsTest static void testCase10(){
        getData();
        // Interface Mock
        Test.setMock(HttpCalloutMock.class , new ManualSendInterfaceMock());

        // 자동발신 조건 설정
        realTimeAutomaticSetting.LogicalExpression__c = 'A && B';
        update realTimeAutomaticSetting;
        insert i2SEMA_TestDataUtil.getStringFieldCompareCondition(realTimeAutomaticSetting);

        // 발송테스트
        NotificationAutomaticTest__c testRecord = new NotificationAutomaticTest__c();
        testRecord.TestText__c  = 'AA@Salesforce.com';
        testRecord.TestEmail__c = 'AA@Salesforce.com';
        insert testRecord;
    }

    // Case 11. 레코드의 Reference 타입의 필드의 자동발송 조건처리
//    @IsTest static void testCase11(){
//        getData();
//        // Interface Mock
//        Test.setMock(HttpCalloutMock.class , new ManualSendInterfaceMock());
//
//        // 자동발신 조건 설정
//        realTimeAutomaticSetting.LogicalExpression__c = 'A && B && C && D && E ';
//        update realTimeAutomaticSetting;
//        insert i2SEMA_TestDataUtil.getReferenceCondition(realTimeAutomaticSetting);
//
//        // 발송테스트
//        NotificationAutomaticTest__c testRecord = new NotificationAutomaticTest__c();
//        testRecord.TestUserReference__c = UserInfo.getUserId();
//        insert testRecord;
//    }

    // Case 12. 스케쥴 발송조건의 경우
    @IsTest static void testCase12(){
        getData();

        // Interface Mock
        Test.setMock(HttpCalloutMock.class , new ManualSendInterfaceMock());

        // 자동발신 조건 설정
        scheduledAutomaticSetting.LogicalExpression__c = 'A || B || C || D || E ';
        update realTimeAutomaticSetting;
        insert i2SEMA_TestDataUtil.getStringFieldCompareCondition(scheduledAutomaticSetting);

        // 발송테스트
        NotificationAutomaticTest__c testRecord = new NotificationAutomaticTest__c();
        testRecord.TestText__c  = 'AA@Salesforce.com';
        testRecord.TestEmail__c = 'AA@Salesforce.com';
        insert testRecord;
    }

    /**
     * @description Interface Mock
     */
    private class ManualSendInterfaceMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request){
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type','application/json');
            response.setStatusCode(200);
            response.setBody(getResponseBody());
            return response;
        }
    }
    /**
     * @description Interface Response 생성
     * @return {String} IF_SFDC_SEMA_0005.OutputDIH
     */
    private static String getResponseBody() {
        IF_SFDC_SEMA_0005.OutputDIH output = new IF_SFDC_SEMA_0005.OutputDIH();

        // Header
        output.response.header.ifId             = 'IF_SFDC_SEMA_0005';
        output.response.header.ifSenderGp       = 'I2MAX';
        output.response.header.ifSender         = 'SEMA';
        output.response.header.ifReceiverGp     = 'I2MAX';
        output.response.header.ifReceiver       = 'SFDC';
        output.response.header.ifTrackingId     = '';
        output.response.header.ifDateTime       = '';
        output.response.header.ifResult         = '';
        output.response.header.ifFailMsg        = '';
        output.response.header.ifFailCode       = '';

        // Payload
        output.response.payload.t_data = new List<IF_SFDC_SEMA_0005.OUTPUT_T_DATA>();

        return JSON.serialize(output);
    }
}