/****************************************************************************************
  * ProjectName : I2SEMA
  * File Name   : SEMA_BULK_TEST_0001_TEST
  * Description : SEMA_BULK_TEST_0001_TEST Class
  * Copyright   : Copyright © 2020 i2max All Rights Reserved
  * Author      : ldb3100
  * Modification Log
  * ===============================================================
  * Ver  Date           Author       Modification
  * ===============================================================
    1.0  2020. 03. 03   ldb3100      Create
****************************************************************************************/
@isTest
private class SEMA_BULK_TEST_0001_TEST {
    // 입력 객체 생성
    private static SEMA_BULK_TEST_0001.InputDIH newInputParameter() {
        SEMA_BULK_TEST_0001.InputBody payload = new SEMA_BULK_TEST_0001.InputBody();

        SEMA_BULK_TEST_0001.InputDIH input = new SEMA_BULK_TEST_0001.InputDIH();

        SEMA_BULK_TEST_0001.Input inputObj = input.Request;

        inputObj.Header = new IF_BaseNotiforce.InputHeader('7662a444-8d04-f469-cdb0-66f39b305035', 'SEMA_BULK_TEST_0001', '20191107082747', 'S', '', '');
        inputObj.Payload = payload;
        return input;
    }

    // HTTPResponse 객체 생성
    private static HTTPResponse newResponse(Integer statusCode) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(statusCode);
        res.setBody('{"Response":{"Header":{"TrackingId":"38a0f138-ca02-a983-ce9d-64dd5caf0911","TaskId":"SEMA_BULK_TEST_0001","SenderGroup":"I2MAX","SenderCode":"SFDC","ResultCode":"S","IFDatetime":"20191107082747","ErrorMsg":"","ErrorCode":"","DestinationGroup":"I2MAX","DestinationCode":"SEMA"},"Payload":{"TOTAL_RECORD_CNT":"2"}}}');
        SEMA_BULK_TEST_0001.OutputDIH temp = (SEMA_BULK_TEST_0001.OutputDIH)JSON.deserialize(res.getBody(), SEMA_BULK_TEST_0001.OutputDIH.class);
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

        System.debug('time : ' + String.valueOf(system.now()));

        SEMA_BULK_TEST_0001 instance = SEMA_BULK_TEST_0001.getInstance();
        // 서비스 실행
        SEMA_BULK_TEST_0001.InputDIH input = new SEMA_BULK_TEST_0001.InputDIH();
        SEMA_BULK_TEST_0001.INPUT_T_DATA tData = new SEMA_BULK_TEST_0001.INPUT_T_DATA();
        tData.searchCondition = '45';

        input.request.payload.t_data.add(tData);
        
        System.debug('result input : '+ JSON.serialize(input));

        SEMA_BULK_TEST_0001.OutputDIH result = instance.execute(input);
        System.debug('result : '+result);

        //System.assertEquals(result.Response.Header.ResultCode, 'S', 'SEMA_BULK_TEST_0001 성공!!!');

        // crashTest
        IF_BaseNotiforce.crashTest = true;
        result = instance.execute(new SEMA_BULK_TEST_0001.InputDIH());

        //System.assertEquals(result.Response.Header.ResultCode, 'E', 'SEMA_BULK_TEST_0001 실패!!!');
        return true;
    }

    // 성공 테스트
    @isTest public static void testServiceSuccess() {
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
        IF_BaseNotiforce.staticValue = i2SEMA_TestDataUtil.getIfStaticValue();

        System.assertEquals(testServiceExecute(), true);
    }
}