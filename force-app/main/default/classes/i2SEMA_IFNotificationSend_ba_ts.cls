/****************************************************************************************
  * @filename      : i2SEMA_IFNotificationSend_ba_ts
  * @projectname   : i2SEMA Core
  * @author        : i2max_shlee 
  * @date          : 2020/04/13 3:14 PM
  * @group         : e.g)tab name
  * @group-content : e.g)view file  
  * @description   :
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                author              description
  * ===============================================================
    0.1     2020/04/13 3:14 PM     i2max_shlee       Create
****************************************************************************************/
@IsTest
public with sharing class i2SEMA_IFNotificationSend_ba_ts {
    private static string IF_ID = 'IF_SFDC_SEMA_0005';

    @TestSetup static void setTestData() {
        // Interface
        insert i2SEMA_TestDataUtil.getIFInfo(IF_ID);
//        i2SEMA_TestDataUtil.getReservationSMSNotification();
        i2SEMA_TestDataUtil.getMMSManualReservNoti();
    }

    static testmethod void testCase01() {
        Test.startTest();

        try {
            // Interface Mock
            Test.setMock(HttpCalloutMock.class , new ManualSendInterfaceMock());
            IF_BaseNotiforce.staticValue = i2SEMA_TestDataUtil.getIfStaticValue();

//            i2SEMA_TestDataUtil.getReservationSMSNotification();
//            i2SEMA_TestDataUtil.getMMSManualReservNoti();
            i2SEMA_IFNotificationSend_ba batch = new i2SEMA_IFNotificationSend_ba();
            Database.executeBatch(batch, 10);
        }catch(Exception e) {
            System.debug(e.getStackTraceString());
        }

        Test.stopTest();
    }

//    @isTest
//    static void testCaseLMS(){
//        Test.startTest();
//
//        // Interface Mock
//        Test.setMock(HttpCalloutMock.class , new ManualSendInterfaceMock());
//        IF_BaseNotiforce.staticValue = i2SEMA_TestDataUtil.getIfStaticValue();
//
//        Id jobId = System.enqueueJob(new i2SEMA_IFNotificationSend_qu(i2SEMA_TestDataUtil.lmsNotification));
//
//        Test.stopTest();
//    }
//
//    @isTest
//    static void testCaseKFT(){
//        Test.startTest();
//
//        // Interface Mock
//        Test.setMock(HttpCalloutMock.class , new ManualSendInterfaceMock());
//        IF_BaseNotiforce.staticValue = i2SEMA_TestDataUtil.getIfStaticValue();
//
//        Id jobId = System.enqueueJob(new i2SEMA_IFNotificationSend_qu(i2SEMA_TestDataUtil.kftNotification));
//
//        Test.stopTest();
//    }
//
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