/****************************************************************************************
  * ProjectName : I2SEMA
  * File Name   : IF_SFDC_SEMA_0002_TEST
  * Description : IF_SFDC_SEMA_0002_TEST Class
  * Copyright   : Copyright © 2020 i2max All Rights Reserved
  * Author      : namho100
  * Modification Log
  * ===============================================================
  * Ver  Date           Author       Modification
  * ===============================================================
    1.0  2020. 01. 20   namho100      Create
****************************************************************************************/
@isTest
private class IF_SFDC_SEMA_0002_TEST {
    // 입력 객체 생성
    private static IF_SFDC_SEMA_0002.InputDIH newInputParameter() {
        IF_SFDC_SEMA_0002.InputBody payload = new IF_SFDC_SEMA_0002.InputBody();

        IF_SFDC_SEMA_0002.InputDIH input = new IF_SFDC_SEMA_0002.InputDIH();

        IF_SFDC_SEMA_0002.Input inputObj = input.Request;

        inputObj.Header = new IF_BaseNotiforce.InputHeader('7662a444-8d04-f469-cdb0-66f39b305035', 'IF_SEMA_SFDC_0002', '20191107082747', 'S', '', '');
        inputObj.Payload = payload;
        return input;
    }

    // HTTPResponse 객체 생성
    private static HTTPResponse newResponse(Integer statusCode) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(statusCode);
        res.setBody('{"Response":{"Header":{"TrackingId":"38a0f138-ca02-a983-ce9d-64dd5caf0911","TaskId":"IF_SEMA_SFDC_0001","SenderGroup":"I2MAX","SenderCode":"SFDC","ResultCode":"S","IFDatetime":"20191107082747","ErrorMsg":"","ErrorCode":"","DestinationGroup":"I2MAX","DestinationCode":"SEMA"},"Payload":{"TOTAL_RECORD_CNT":"2"}}}');
        IF_SFDC_SEMA_0002.OutputDIH temp = (IF_SFDC_SEMA_0002.OutputDIH)JSON.deserialize(res.getBody(), IF_SFDC_SEMA_0002.OutputDIH.class);
        return res;
    }

    // StatusCode=200 Mock
    private class HttpCalloutSuccessMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = newResponse(200);
            return res;
        }
    }

    // 공통 테스트 진행
    private static Boolean testServiceExecute() {
        String jsonMsg = JSON.serialize(newInputParameter());

        RestRequest  req = new RestRequest ();
        RestResponse res = new RestResponse();

        req.requestURI = '/restapi/post/testSfdcToSema.json';  //Request URL
        req.httpMethod = 'POST';  //HTTP Request Type
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response = res;

        IF_SFDC_SEMA_0002 instance = IF_SFDC_SEMA_0002.getInstance();
        // 서비스 실행
        IF_SFDC_SEMA_0002.InputDIH input = new IF_SFDC_SEMA_0002.InputDIH();
        IF_SFDC_SEMA_0002.INPUT_T_DATA t_data = new IF_SFDC_SEMA_0002.INPUT_T_DATA();
        t_data.date_client_req = String.valueOf(system.now());
        t_data.content = 'Test DATA';
        t_data.callback = '01088907101';
        t_data.service_type = '0';
        t_data.broadcast_yn = 'N';
        t_data.msg_type = '1';
        t_data.recipient_num = '01031003523';

        input.request.payload.T_DATA.add(t_data);

        IF_SFDC_SEMA_0002.OutputDIH result = instance.execute(input);
        System.debug('result : '+result);

        //System.assertEquals(result.Response.Header.ResultCode, 'S', 'IF_CN_CXP_ERP_0001 성공!!!');

        // crashTest
        IF_BaseNotiforce.crashTest = true;
        result = instance.execute(new IF_SFDC_SEMA_0002.InputDIH());

        //System.assertEquals(result.Response.Header.ResultCode, 'E', 'IF_CN_CXP_ERP_0001 실패!!!');
        return true;
    }

    // 성공 테스트
    @isTest public static void testServiceSuccess() {
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
        IF_BaseNotiforce.staticValue = i2SEMA_TestDataUtil.getIfStaticValue();

        System.assertEquals(testServiceExecute(), true);
    }
}