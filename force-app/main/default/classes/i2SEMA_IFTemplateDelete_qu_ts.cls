/****************************************************************************************
  * @filename      : i2SEMA_IFTemplateDelete_qu_ts
  * @projectname   : i2SEMA Core
  * @author        : i2max_shlee 
  * @date          : 2020/04/13 2:30 PM
  * @group         : e.g)tab name
  * @group-content : e.g)view file  
  * @description   :
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                author              description
  * ===============================================================
    0.1     2020/04/13 2:30 PM     i2max_shlee       Create
****************************************************************************************/
@isTest
public with sharing class i2SEMA_IFTemplateDelete_qu_ts {
    private static string IF_ID = 'IF_SFDC_SEMA_0010';

    @TestSetup
    static void setTestData() {
//        i2SEMA_TestDataUtil.nt = null; i2SEMA_TestDataUtil.getChatterTemplate();
        i2SEMA_TestDataUtil.getIfStaticValue();
        insert i2SEMA_TestDataUtil.getIFInfo(IF_ID);
        i2SEMA_TestDataUtil.getSMSTemplate();
        i2SEMA_TestDataUtil.getLMSTemplate();
        i2SEMA_TestDataUtil.getMMSTemplate();
        i2SEMA_TestDataUtil.getKakaoNotificationTalkTemplate();
        i2SEMA_TestDataUtil.getKakaoFriendTalkTemplate();
    }

    @isTest
    static void testCaseSMS(){
        Test.startTest();

        // Interface Mock
        Test.setMock(HttpCalloutMock.class , new ManualSendInterfaceMock());
        IF_BaseNotiforce.staticValue = i2SEMA_TestDataUtil.getIfStaticValue();

        List<NotificationTemplate__c> notificationTemplates = [SELECT Id, Name FROM NotificationTemplate__c WHERE Channel__c = '0'];
        Id jobId = System.enqueueJob(new i2SEMA_IFTemplateDelete_qu(notificationTemplates));

        Test.stopTest();
    }

    @isTest
    static void testCaseMMS(){
        Test.startTest();

        // Interface Mock
        Test.setMock(HttpCalloutMock.class , new ManualSendInterfaceMock());
        IF_BaseNotiforce.staticValue = i2SEMA_TestDataUtil.getIfStaticValue();

        List<NotificationTemplate__c> notificationTemplates = [SELECT Id, Name FROM NotificationTemplate__c WHERE Channel__c = '2'];
        Id jobId = System.enqueueJob(new i2SEMA_IFTemplateDelete_qu(notificationTemplates));

        Test.stopTest();
    }

    @isTest
    static void testCaseLMS(){
        Test.startTest();

        // Interface Mock
        Test.setMock(HttpCalloutMock.class , new ManualSendInterfaceMock());
        IF_BaseNotiforce.staticValue = i2SEMA_TestDataUtil.getIfStaticValue();

        List<NotificationTemplate__c> notificationTemplates = [SELECT Id, Name FROM NotificationTemplate__c WHERE Channel__c = '3'];
        Id jobId = System.enqueueJob(new i2SEMA_IFTemplateDelete_qu(notificationTemplates));

        Test.stopTest();
    }

    @isTest
    static void testCaseKFT(){
        Test.startTest();

        // Interface Mock
        Test.setMock(HttpCalloutMock.class , new ManualSendInterfaceMock());
        IF_BaseNotiforce.staticValue = i2SEMA_TestDataUtil.getIfStaticValue();

        List<NotificationTemplate__c> notificationTemplates = [SELECT Id, Name FROM NotificationTemplate__c WHERE Channel__c = '1009'];
        Id jobId = System.enqueueJob(new i2SEMA_IFTemplateDelete_qu(notificationTemplates));

        Test.stopTest();
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
        output.response.header.ifId             = IF_ID;
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