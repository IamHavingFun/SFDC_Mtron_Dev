/****************************************************************************************
  * @filename      : i2SEMA_ReservationCancel_ts
  * @projectname   : i2sema_Dev1
  * @author        : i2max_ys.seo 
  * @date          : 2020-04-20 오후 1:19
  * @group         : e.g)tab name
  * @group-content : e.g)view file  
  * @description   : 
  * @tester        : i2SEMA_ReservationCancel_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                author              description
  * ===============================================================
    0.1     2020-04-20 오후 1:19     i2max_ys.seo       Create
****************************************************************************************/
@IsTest
public with sharing class i2SEMA_ReservationCancel_ts {
    private static string IF_ID = 'IF_SFDC_SEMA_0006';
    /**
     * @description Test Data 생성
     */
    @TestSetup
    static void setup(){
        insert i2SEMA_TestDataUtil.getIFInfo(IF_ID);

        i2SEMA_TestDataUtil.getSMSNotification();
    }

    /**
     * @description notification 재시도 initialize 실행
     */
    static testmethod void testCase01(){
        Test.startTest();

        // Interface Mock
        Test.setMock(HttpCalloutMock.class , new ManualSendInterfaceMock());
        IF_BaseNotiforce.staticValue = i2SEMA_TestDataUtil.getIfStaticValue();


        i2SEMA_TestDataUtil.getSMSNotification();
        i2SEMA_TestDataUtil.smsNotification.msg_status__c = 'Requested';
        update i2SEMA_TestDataUtil.smsNotification;

        i2SEMA_ReservationCancel.initialize(i2SEMA_TestDataUtil.smsNotification.Id);

        Test.stopTest();
    }

    /**
     * @description notificationGroup 재시도 initialize 실행
     */
    static testmethod void testCase02(){
        Test.startTest();

        // Interface Mock
        Test.setMock(HttpCalloutMock.class , new ManualSendInterfaceMock());
        IF_BaseNotiforce.staticValue = i2SEMA_TestDataUtil.getIfStaticValue();

        i2SEMA_TestDataUtil.getSMSNotification();
        i2SEMA_TestDataUtil.smsNotification.msg_status__c = 'Requested';
        update i2SEMA_TestDataUtil.smsNotification;
        i2SEMA_TestDataUtil.smsNg.IF_Status__c = 'Requested';
        update i2SEMA_TestDataUtil.smsNg;

        try{
            i2SEMA_ReservationCancel.initialize(i2SEMA_TestDataUtil.smsNg.Id);
        }catch(Exception e) {
            System.debug('e :'+e.getStackTraceString());
        }
        Test.stopTest();
    }

    /**
     * @description Error no recordId 재시도 initialize 실행
     */
    static testmethod void testCase03(){
        Test.startTest();

        // Interface Mock
        Test.setMock(HttpCalloutMock.class , new ManualSendInterfaceMock());
        IF_BaseNotiforce.staticValue = i2SEMA_TestDataUtil.getIfStaticValue();

        try{
            i2SEMA_ReservationCancel.initialize(null);
        }catch(Exception e) {
            System.debug('e :'+e.getStackTraceString());
        }
        Test.stopTest();
    }

    /**
     * @description Error no notification or notificationGroup 재시도 initialize 실행
     */
    static testmethod void testCase04(){
        Test.startTest();

        // Interface Mock
        Test.setMock(HttpCalloutMock.class , new ManualSendInterfaceMock());
        IF_BaseNotiforce.staticValue = i2SEMA_TestDataUtil.getIfStaticValue();

        try{
            i2SEMA_TestDataUtil.getSMSNotification();
            i2SEMA_ReservationCancel.initialize(i2SEMA_TestDataUtil.acc.Id);
        }catch(Exception e) {
            System.debug('e :'+e.getStackTraceString());
        }
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