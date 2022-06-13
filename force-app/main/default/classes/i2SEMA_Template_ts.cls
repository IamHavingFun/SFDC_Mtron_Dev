/****************************************************************************************
  * @filename      : i2SEMA_Template_ts
  * @projectname   : i2SEMA Core
  * @author        : i2max_ys.seo
  * @date          : 2020-04-17 오후 5:23
  * @group         : e.g)tab name
  * @group-content : e.g)view file
  * @description   : Template Test Class
  * @tester        : i2SEMA_Template_ts.cls
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                    author              description
  * ===============================================================
    0.1     2020-04-17 오후 5:23     i2max_ys.seo         Create
    0.2     2020/04/28 11:31 AM     i2max_shlee          Rename i2SEMA_NotificationTemplate_ts -> i2SEMA_Template_ts
****************************************************************************************/
@IsTest
public with sharing class i2SEMA_Template_ts {
    @TestSetup
    private static void setTestData() {
        i2SEMA_TestDataUtil.smsTemplate = null; i2SEMA_TestDataUtil.getSMSTemplate();
        i2SEMA_TestDataUtil.lmsTemplate = null; i2SEMA_TestDataUtil.getLMSTemplate();
        i2SEMA_TestDataUtil.mmsTemplate = null; i2SEMA_TestDataUtil.getMMSTemplate();
        i2SEMA_TestDataUtil.kakaoFriendTemplate = null; i2SEMA_TestDataUtil.getKakaoNotificationTalkTemplate();
        i2SEMA_TestDataUtil.kakaoNotificationTemplate = null; i2SEMA_TestDataUtil.getKakaoFriendTalkTemplate();
        i2SEMA_TestDataUtil.ktb = null; i2SEMA_TestDataUtil.getKakaoTalkButton();
    }

    static testmethod void testCaseSMS(){
        Test.startTest();
        // Custom Setting
        IF_BaseNotiforce.staticValue = i2SEMA_TestDataUtil.getIfStaticValue();

        // Interface Mock
        Test.setMock(HttpCalloutMock.class , new NotificationTemplateInterfaceMock());
        i2SEMA_Template.ReferenceData referenceData = new i2SEMA_Template.ReferenceData();
        List<NotificationTemplate__c> notificationTemplates = [SELECT Id, Name, Title__c, Content__c, Channel__c, ContentLength__c, isActive__c FROM NotificationTemplate__c WHERE Channel__c = '0'];
        referenceData.template = notificationTemplates[0];
        referenceData.isSMS = true;
        i2SEMA_Template.initialize(notificationTemplates[0].Id, 'Read');
        i2SEMA_Template.saveNotificationTemplate(notificationTemplates[0].Id, referenceData);

        Test.stopTest();
    }

    static testmethod void testCaseLMS(){
        Test.startTest();
        List<NotificationTemplate__c> notificationTemplates = [SELECT Id, Name FROM NotificationTemplate__c WHERE Channel__c = '3'];
        i2SEMA_Template.initialize(notificationTemplates[0].Id, 'Read');
        Test.stopTest();
    }

    static testmethod void testCaseMMS(){
        Test.startTest();
        // Custom Setting
        IF_BaseNotiforce.staticValue = i2SEMA_TestDataUtil.getIfStaticValue();

        // Interface Mock
        Test.setMock(HttpCalloutMock.class , new NotificationTemplateInterfaceMock());
        i2SEMA_Template.ReferenceData referenceData = new i2SEMA_Template.ReferenceData();
        i2SEMA_Template.ContentVersionData contentVersionData = new i2SEMA_Template.ContentVersionData();

        List<NotificationTemplate__c> notificationTemplates = [SELECT Id, Name, Title__c, Content__c, Channel__c, ContentLength__c, isActive__c FROM NotificationTemplate__c WHERE Channel__c = '2'];
        List<ContentVersion> cvList = [SELECT Id, Title, VersionData, PathOnClient, FileExtension FROM ContentVersion LIMIT 1];
        referenceData.template = notificationTemplates[0];
        referenceData.isMMS = true;
        //ContentVersion Wrapper Class에 담기
        contentVersionData.fileName = cvList[0].Title;
        contentVersionData.versionData = EncodingUtil.base64Encode(cvList[0].VersionData);
        contentVersionData.fileExtension = cvList[0].FileExtension;
        referenceData.files.add(contentVersionData);

        //NotificationTemplate Method 실행
        i2SEMA_Template.initialize(notificationTemplates[0].Id, 'Read');
        i2SEMA_Template.saveNotificationTemplate(notificationTemplates[0].Id, referenceData);
        Test.stopTest();
    }

    static testmethod void testCaseKakaoNotificationTalk(){
        Test.startTest();
        List<NotificationTemplate__c> notificationTemplates = [SELECT Id, Name FROM NotificationTemplate__c WHERE Channel__c = '1008'];
        try{
            i2SEMA_Template.initialize(notificationTemplates[0].Id, 'Edit');
        }catch(exception e){}
        Test.stopTest();
    }

    static testmethod void testCaseKakaoFriendTalk(){
        Test.startTest();
        // Custom Setting
        IF_BaseNotiforce.staticValue = i2SEMA_TestDataUtil.getIfStaticValue();

        // Interface Mock
        Test.setMock(HttpCalloutMock.class , new NotificationTemplateInterfaceMock());

        List<NotificationTemplate__c> notificationTemplates = [SELECT Id, Name, Title__c, Content__c, Channel__c, ContentLength__c, KakaoImgLink__c, isActive__c, KakaoFriendTalkImage__c, KakaoImgUrl__c FROM NotificationTemplate__c WHERE Channel__c = '1009'];
        List<KakaoTalkButton__c> ktbList = [
                SELECT Id, NotificationTemplates__c, Name, Button_Type__c, ButtonLink1__c, ButtonLink2__c FROM KakaoTalkButton__c
                WHERE NotificationTemplates__c = :notificationTemplates[0].Id
                LIMIT 1
        ];
        i2SEMA_Template.ReferenceData referenceData = new i2SEMA_Template.ReferenceData();

        referenceData.template = notificationTemplates[0];
        referenceData.hasKaokaoFriendTalkImage = true;
        referenceData.isKakaoFriendTalk = true;
        referenceData.kakaoButtons = ktbList;
        //KakaoButton Wrapper Class에 담기

        try{
            i2SEMA_Template.initialize(notificationTemplates[0].Id, 'Edit');
        }catch(exception e){}
        i2SEMA_Template.getKakaoImgUrl(notificationTemplates[0].KakaoFriendTalkImage__c);
        i2SEMA_Template.saveNotificationTemplate(notificationTemplates[0].Id, referenceData);

        Test.stopTest();
    }

    /**
     * @description Interface Mock
     */
    private class NotificationTemplateInterfaceMock implements HttpCalloutMock {
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
     * @return {String} IF_SFDC_SEMA_0009.OutputDIH
     */
    private static String getResponseBody() {
        IF_SFDC_SEMA_0009.OutputDIH output = new IF_SFDC_SEMA_0009.OutputDIH();

        // Header
        output.response.header.ifId             = 'IF_SFDC_SEMA_0009';
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
        output.response.payload.t_data = new List<IF_SFDC_SEMA_0009.OUTPUT_T_DATA>();

        return JSON.serialize(output);
    }

}