/****************************************************************************************
  * @filename       : i2SEMA_ManualSend_ts
  * @projectname    : i2SEMA Core
  * @author         : i2max_byeon.jw
  * @date           : 2020-04-20 오전 9:43
  * @group          : 
  * @group-content  : 
  * @description    : i2SEMA_ManualSend Test Class
  * @tester         : i2SEMA_ManualSend.cls
  * @reference      : 
  * @copyright      : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                author              description
  * ===============================================================
    0.1     2020-04-20 오전 9:43     i2max_byeon.jw       Create
****************************************************************************************/
@IsTest
private class i2SEMA_ManualSend_ts {
    static Id accountId;
    static Id contactId;
    static Id leadId;
    static Id opportunityId;
    static Id smsTemplateId;
    static Id lmsTemplateId;
    static Id mmsTemplateId;
    static Id kakaoFriendTalkTemplateId;
    static Id kakaoNotificationTalkTemplateId;

    /**
     * @description Test Data 생성
     */
    @TestSetup static void setup(){
        // If Info 생성
        insert i2SEMA_TestDataUtil.getIfInfo('IF_SFDC_SEMA_0005');

        // Account & Contact & Lead
        i2SEMA_TestDataUtil.getContact();
        i2SEMA_TestDataUtil.getLead();
        i2SEMA_TestDataUtil.getOpportunity();

        // Template
        i2SEMA_TestDataUtil.getSMSTemplate();
        i2SEMA_TestDataUtil.getLMSTemplate();
        i2SEMA_TestDataUtil.getMMSTemplate();
        i2SEMA_TestDataUtil.getKakaoFriendTalkTemplate();
        i2SEMA_TestDataUtil.getKakaoNotificationTalkTemplate();
    }
    /**
     * @description Test Data 조회
     */
    static void getData(){
        // Record 정보 조회
        List<Contact> contacts = [SELECT Id,AccountId FROM Contact LIMIT 1];
        if( !contacts.isEmpty() ){
            accountId = contacts[0].AccountId;
            contactId = contacts[0].Id;
        }
        List<Lead> leads = [SELECT Id FROM Lead LIMIT 1];
        if( !leads.isEmpty() ){
            leadId = leads[0].Id;
        }
        List<Opportunity> opportunities = [SELECT Id FROM Opportunity LIMIT 1];
        if( !opportunities.isEmpty() ){
            opportunityId = opportunities[0].Id;
        }
        // Template 정보 조회
        List<NotificationTemplate__c> templates = [SELECT Id,Channel__c FROM NotificationTemplate__c];
        for( NotificationTemplate__c template : templates ){
            if( template.Channel__c == '0')         smsTemplateId   = template.Id;
            else if( template.Channel__c == '2')    mmsTemplateId   = template.Id;
            else if( template.Channel__c == '3')    lmsTemplateId   = template.Id;
            else if( template.Channel__c == '1008') kakaoNotificationTalkTemplateId = template.Id;
            else if( template.Channel__c == '1009') kakaoFriendTalkTemplateId       = template.Id;
        }
    }

    /**
     * @description [Case 1] 초기화, Record ID 가 존재하지 않는 경우
     */
    @IsTest static void testCase01() {
        // Apex Response
        i2SEMA_ComponentResponse response = i2SEMA_ManualSend.initialize(null);
        i2SEMA_ManualSend.ReferenceData referenceData = (i2SEMA_ManualSend.ReferenceData)JSON.deserialize(JSON.serialize(response.getData('refData')),i2SEMA_ManualSend.ReferenceData.class);

        // Assert Equal
        System.assertEquals( true , referenceData != null);                             // 반환 정보는 항상 존재
        System.assertEquals( null , referenceData.recordType );                         // Record ID 가 없으므로 참조값 없음
        System.assertEquals( 1 , referenceData.receiverOptions.size() );                // Record ID 가 없으므로 수신자 선택옵션은 1건. (특정 수신자)
        System.assertEquals( false , referenceData.channelOptions.isEmpty());           // Channel 옵션은 1건 이상 존재
        System.assertEquals( true , referenceData.receiverTypeOptions.isEmpty());       // Record ID 가 없으므로 참조할수 있는 하위 수신자 없음
        System.assertEquals( null, referenceData.template );                            // Template 조회 이전 참조할수 있는 정보 없음
    }
    /**
     * @description [Case 2] 초기화, 수신자 타입의 Object ID 가 존재하는 경우
     */
    @IsTest static void testCase02() {
        // Test Data 조회
        if( i2SEMA_Util.isEmpty(accountId) ){
            getData();
        }
        // Apex Response
        i2SEMA_ComponentResponse response = i2SEMA_ManualSend.initialize(accountId);
        i2SEMA_ManualSend.ReferenceData referenceData = (i2SEMA_ManualSend.ReferenceData)JSON.deserialize(JSON.serialize(response.getData('refData')),i2SEMA_ManualSend.ReferenceData.class);

        // Assert Equal
        System.assertEquals( true , referenceData != null);                             // 반환 정보는 항상 존재
        System.assertEquals( 'Account' , referenceData.recordType );                    // 현재 레코드가 Account 타입으로 식별
        System.assertEquals( 4 , referenceData.receiverOptions.size());                 // 수신자 옵션은 4건 (현재 수신자, 하위 수신자, Look-up 수신자, 특정 수신자)
        System.assertEquals( false , referenceData.channelOptions.isEmpty());           // Channel 옵션은 1건 이상 존재
        System.assertEquals( false , referenceData.receiverTypeOptions.isEmpty());      // Account 하위 수신자 옵션으로 Contact,Lead,User 등 조회됨
        System.assertEquals( false , referenceData.referenceFieldOptions.isEmpty());    // Account Look-up 수신자 옵션으로 User 등 조회됨
        System.assertEquals( null, referenceData.template );                            // Template 조회 이전 참조할수 있는 정보 없음
    }
    /**
     * @description [Case 3] 초기화, 수신자 타입이 아닌 Object ID 가 존재하는 경우
     */
    @IsTest static void testCase03(){
        // Test Data 조회
        if( i2SEMA_Util.isEmpty(opportunityId) ){
            getData();
        }
        // Apex Response
        i2SEMA_ComponentResponse response = i2SEMA_ManualSend.initialize(opportunityId);
        i2SEMA_ManualSend.ReferenceData referenceData = (i2SEMA_ManualSend.ReferenceData)JSON.deserialize(JSON.serialize(response.getData('refData')),i2SEMA_ManualSend.ReferenceData.class);

        // Assert Equal : 하위 수신자는 Standard 에는 없으나 패키지 설치 Org 에 따라 변동됨 > Assert Equal X
        System.assertEquals( true , referenceData != null);                             // 반환 정보는 항상 존재
        System.assertEquals( 'Opportunity', referenceData.recordType );                 // 현재 레코드가 Opportunity 타입으로 식별
        System.assertEquals( 3 , referenceData.receiverOptions.size());                 // 수신자 옵션은 3건(하위 수신자, Look-up 수신자, 특정 수신자)
        System.assertEquals( false , referenceData.channelOptions.isEmpty());           // Channel 옵션은 1건 이상 존재
        System.assertEquals( false , referenceData.referenceFieldOptions.isEmpty());    // Account Look-up 수신자 옵션으로 Account, User 등 조회됨
        System.assertEquals( null, referenceData.template );                            // Template 조회 이전 참조할수 있는 정보 없음
    }
    /**
     * @description [Case 4] Template 조회 (SMS,LMS,MMS)
     */
    @IsTest static void testCase04(){
        // Test Data 조회
        if( i2SEMA_Util.isEmpty(smsTemplateId) || i2SEMA_Util.isEmpty(lmsTemplateId) || i2SEMA_Util.isEmpty(mmsTemplateId)){
            getData();
        }
        // Param
        i2SEMA_ManualSend.ReferenceData referenceData_SMS   = new i2SEMA_ManualSend.ReferenceData();
        i2SEMA_ManualSend.ReferenceData referenceData_LMS   = new i2SEMA_ManualSend.ReferenceData();
        i2SEMA_ManualSend.ReferenceData referenceData_MMS   = new i2SEMA_ManualSend.ReferenceData();
        i2SEMA_ManualSend.RequestData requestData_SMS       = new i2SEMA_ManualSend.RequestData();
        i2SEMA_ManualSend.RequestData requestData_LMS       = new i2SEMA_ManualSend.RequestData();
        i2SEMA_ManualSend.RequestData requestData_MMS       = new i2SEMA_ManualSend.RequestData();

        requestData_SMS.templateId = smsTemplateId;
        requestData_LMS.templateId = lmsTemplateId;
        requestData_MMS.templateId = mmsTemplateId;

        // Apex Response
        i2SEMA_ComponentResponse response_SMS = i2SEMA_ManualSend.getTemplateData(referenceData_SMS , requestData_SMS);
        i2SEMA_ComponentResponse response_LMS = i2SEMA_ManualSend.getTemplateData(referenceData_LMS , requestData_LMS);
        i2SEMA_ComponentResponse response_MMS = i2SEMA_ManualSend.getTemplateData(referenceData_MMS , requestData_MMS);

        referenceData_SMS   = (i2SEMA_ManualSend.ReferenceData)JSON.deserialize(JSON.serialize(response_SMS.getData('referenceData')),i2SEMA_ManualSend.ReferenceData.class);
        referenceData_LMS   = (i2SEMA_ManualSend.ReferenceData)JSON.deserialize(JSON.serialize(response_LMS.getData('referenceData')),i2SEMA_ManualSend.ReferenceData.class);
        referenceData_MMS   = (i2SEMA_ManualSend.ReferenceData)JSON.deserialize(JSON.serialize(response_MMS.getData('referenceData')),i2SEMA_ManualSend.ReferenceData.class);
        requestData_SMS     = (i2SEMA_ManualSend.RequestData)JSON.deserialize(JSON.serialize(response_SMS.getData('requestData')),i2SEMA_ManualSend.RequestData.class);
        requestData_LMS     = (i2SEMA_ManualSend.RequestData)JSON.deserialize(JSON.serialize(response_LMS.getData('requestData')),i2SEMA_ManualSend.RequestData.class);
        requestData_MMS     = (i2SEMA_ManualSend.RequestData)JSON.deserialize(JSON.serialize(response_MMS.getData('requestData')),i2SEMA_ManualSend.RequestData.class);

        // Assert Equal
        System.assertEquals( true , response_SMS != null );     // 반환 정보는 항상 존재
        System.assertEquals( true , response_LMS != null );     // 반환 정보는 항상 존재
        System.assertEquals( true , response_MMS != null );     // 반환 정보는 항상 존재

        System.assertEquals( referenceData_SMS.template.Channel__c , requestData_SMS.channel );     // 조회된 Template 의 채널정보와 Request 의 채널정보 설정값 동일
        System.assertEquals( referenceData_LMS.template.Channel__c , requestData_LMS.channel );
        System.assertEquals( referenceData_MMS.template.Channel__c , requestData_MMS.channel );

        System.assertEquals( referenceData_SMS.template.Title__c , requestData_SMS.title);          // 조회된 Template 의 제목과 Request 의 제목 설정값 동일
        System.assertEquals( referenceData_LMS.template.Title__c , requestData_LMS.title);
        System.assertEquals( referenceData_MMS.template.Title__c , requestData_MMS.title);

        System.assertEquals( referenceData_SMS.template.Content__c , requestData_SMS.content );     // 조회된 Template 의 본문과 Request 의 본문 설정값 동일
        System.assertEquals( referenceData_LMS.template.Content__c , requestData_LMS.content );
        System.assertEquals( referenceData_MMS.template.Content__c , requestData_MMS.content );
    }
    /**
     * @description [Case 5] SMS 발송, Account 화면에서 하위 Contact 에게 발송
     */
    @IsTest static void testCase05(){
        // Test Data 조회
        if( i2SEMA_Util.isEmpty(accountId) || i2SEMA_Util.isEmpty(contactId)){
            getData();
        }
        // Custom Setting
        IF_BaseNotiforce.staticValue = i2SEMA_TestDataUtil.getIfStaticValue();

        // Interface Mock
        Test.setMock(HttpCalloutMock.class , new ManualSendInterfaceMock());

        // param
        i2SEMA_ManualSend.RequestData requestData = new i2SEMA_ManualSend.RequestData(accountId);
        requestData.channel             = '0';
        requestData.receiverOption      = Label.i2SEMA_LAB_RELATED_RECORD;
        requestData.receiverType        = 'Contact';
        requestData.receiverIds         = new List<String>{contactId};
        requestData.templateId          = smsTemplateId;
        requestData.title               = null;
        requestData.content             = '안녕하세요.  %%LABEL1%% 님 가입이 성공적으로 완료되었습니다.많은 이용 부탁드립니다. 감사합니다.';
        requestData.scheduled           = false;
        requestData.type                = '2';

        i2SEMA_ManualSend.TemplateSetting label1Setting = new i2SEMA_ManualSend.TemplateSetting();
        label1Setting.label             = Label.i2SEMA_LAB_LABEL_01_VAL;
        label1Setting.sObjectType       = 'Contact';
        label1Setting.sObjectField      = 'Name';
        requestData.templateSettings.add(label1Setting);

        // Apex Response
        i2SEMA_ComponentResponse response = i2SEMA_ManualSend.saveRequest(requestData);
    }
    /**
     * @description [Case 6] LMS 발송, Opportunity 화면에서 Look-up  Account 에게 발송
     */
    @IsTest static void testCase06(){
        // Test Data 조회
        if( i2SEMA_Util.isEmpty(leadId) ){
            getData();
        }
        // Custom Setting
        IF_BaseNotiforce.staticValue = i2SEMA_TestDataUtil.getIfStaticValue();

        // Interface Mock
        Test.setMock(HttpCalloutMock.class , new ManualSendInterfaceMock());

        // Param
        i2SEMA_ManualSend.RequestData requestData = new i2SEMA_ManualSend.RequestData(opportunityId);
        requestData.channel             = '3';
        requestData.receiverOption      = Label.i2SEMA_LAB_REFERENCE_FIELD;
        requestData.referenceField      = 'AccountId';
        requestData.referenceFieldType  = 'Account';
        requestData.templateId          = lmsTemplateId;
        requestData.title               = 'LMS Test';
        requestData.content             = 'TEST 버전입니다. %%LABEL1%%님께서 신청하신 %%LABEL2%%코엑스 컨벤션센터에서 개최되는 %%LABEL3%%에 사전등록 신청해 주셔서 감사드립니다. 참가신청 후 개인사정으로 인하여 부득이하게 불참시에는 사전에 아이투맥스로 꼭 연락 주시기 바랍니다.';
        requestData.scheduled           = false;
        requestData.type                = '2';

        i2SEMA_ManualSend.TemplateSetting label1Setting = new i2SEMA_ManualSend.TemplateSetting();
        label1Setting.label             = Label.i2SEMA_LAB_LABEL_01_VAL;
        label1Setting.sObjectType       = 'Account';
        label1Setting.sObjectField      = 'Name';

        i2SEMA_ManualSend.TemplateSetting label2Setting = new i2SEMA_ManualSend.TemplateSetting();
        label2Setting.label             = Label.i2SEMA_LAB_LABEL_02_VAL;
        label2Setting.sObjectType       = 'Opportunity';
        label2Setting.sObjectField      = 'Name';

        i2SEMA_ManualSend.TemplateSetting label3Setting = new i2SEMA_ManualSend.TemplateSetting();
        label3Setting.label             = Label.i2SEMA_LAB_LABEL_03_VAL;
        label3Setting.sObjectType       = 'Opportunity';
        label3Setting.sObjectField      = 'StageName';

        requestData.templateSettings.add(label1Setting);
        requestData.templateSettings.add(label2Setting);
        requestData.templateSettings.add(label3Setting);

        // Apex Response
        i2SEMA_ComponentResponse response = i2SEMA_ManualSend.saveRequest(requestData);
    }
    /**
     * @description [Case 7] MMS 발송, 특정 Contact 에게 발송
     */
    @IsTest static void testCase07(){
        // Test Data 조회
        if( i2SEMA_Util.isEmpty(contactId) ){
            getData();
        }
        // Custom Setting
        IF_BaseNotiforce.staticValue = i2SEMA_TestDataUtil.getIfStaticValue();

        // Interface Mock
        Test.setMock(HttpCalloutMock.class , new ManualSendInterfaceMock());

        // Param
        i2SEMA_ManualSend.RequestData requestData = new i2SEMA_ManualSend.RequestData();
        requestData.channel             = '2';
        requestData.receiverOption      = Label.i2SEMA_LAB_SPECIFIC_RECORD;
        requestData.receiverType        = 'Contact';

        i2SEMA_ManualSend.Receiver receiver = new i2SEMA_ManualSend.Receiver();
        receiver.Id = contactId;
        requestData.specificReceivers.add(receiver);

        requestData.templateId          = mmsTemplateId;
        requestData.title               = 'MMS Test';
        requestData.content             = 'TEST 버전입니다. %%LABEL1%%님께서 신청하신 %%LABEL2%%코엑스 컨벤션센터에서 개최되는 %%LABEL3%%에 사전등록 신청해 주셔서 감사드립니다. 참가신청 후 개인사정으로 인하여 부득이하게 불참시에는 사전에 아이투맥스로 꼭 연락 주시기 바랍니다.';
        requestData.scheduled           = true;
        requestData.scheduledTime       = Datetime.now().addDays(1);
        requestData.type                = '2';

        i2SEMA_ManualSend.TemplateSetting label1Setting = new i2SEMA_ManualSend.TemplateSetting();
        label1Setting.label             = Label.i2SEMA_LAB_LABEL_01_VAL;
        label1Setting.sObjectType       = 'Contact';
        label1Setting.sObjectField      = 'FirstName';

        i2SEMA_ManualSend.TemplateSetting label2Setting = new i2SEMA_ManualSend.TemplateSetting();
        label2Setting.label             = Label.i2SEMA_LAB_LABEL_02_VAL;
        label2Setting.sObjectType       = 'Contact';
        label2Setting.sObjectField      = 'LastName';

        i2SEMA_ManualSend.TemplateSetting label3Setting = new i2SEMA_ManualSend.TemplateSetting();
        label3Setting.label             = Label.i2SEMA_LAB_LABEL_03_VAL;
        label3Setting.sObjectType       = 'Contact';
        label3Setting.sObjectField      = 'AccountId';

        requestData.templateSettings.add(label1Setting);
        requestData.templateSettings.add(label2Setting);
        requestData.templateSettings.add(label3Setting);

        // Apex Response
        i2SEMA_ComponentResponse response = i2SEMA_ManualSend.saveRequest(requestData);
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