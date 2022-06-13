/****************************************************************************************
  * @filename      : i2SEMA_IFUnsubscriptionRequest_qu_ts
  * @projectname   : i2SEMA Core
  * @author        : i2max_shlee 
  * @date          : 2020/04/13 3:40 PM
  * @group         : e.g)tab name
  * @group-content : e.g)view file  
  * @description   : 
  * @tester        : i2SEMA_IFUnsubscriptionRequest_qu_ts_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                author              description
  * ===============================================================
    0.1     2020/04/13 3:40 PM     i2max_shlee       Create
****************************************************************************************/
@IsTest
public with sharing class i2SEMA_IFUnsubscriptionRequest_qu_ts {
    private static string IF_ID = 'IF_SFDC_SEMA_0011';

    @TestSetup
    private static void setTestData() {
        i2SEMA_TestDataUtil.getIfStaticValue();
        insert i2SEMA_TestDataUtil.getIFInfo(IF_ID);
    }

    @isTest
    static void testCase(){
        Test.startTest();

        // Interface Mock
        Test.setMock(HttpCalloutMock.class , new ManualSendInterfaceMock());
        IF_BaseNotiforce.staticValue = i2SEMA_TestDataUtil.getIfStaticValue();

        Id jobId = System.enqueueJob(new i2SEMA_IFUnsubscriptionRequest_qu(Datetime.now()));

        Test.stopTest();
    }

    @isTest
    static void testCase02(){
        Test.startTest();

        // Interface Mock
        Test.setMock(HttpCalloutMock.class , new ManualSendInterfaceMock());
        IF_BaseNotiforce.staticValue = i2SEMA_TestDataUtil.getIfStaticValue();

        Datetime now = Datetime.now();
        Id jobId = System.enqueueJob(new i2SEMA_IFUnsubscriptionRequest_qu(now.addDays(-1), now));

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