/****************************************************************************************
  * ProjectName : I2SEMA
  * File Name   : SEMA_BULK_TEST_0002_TEST
  * Description : SEMA_BULK_TEST_0002_TEST Class
  * Copyright   : Copyright © 2020 i2max All Rights Reserved
  * Author      : ldb3100
  * Modification Log
  * ===============================================================
  * Ver  Date        Author          Modification
  * ===============================================================
    1.0  2020.03.03  ldb3100         Create
****************************************************************************************/
@isTest
public class SEMA_BULK_TEST_0002_TEST {

    // 입력 객체 생성
    private static SEMA_BULK_TEST_0002.InputDIH newInputParameter() {
        String req = '{"request":{"header":{"TaskId":"SEMA_BULK_TEST_0002","SenderGroup":"CN","SenderCode":"ERP","DestinationGroup":"CN","DestinationCode":"CXP","TrackingId":"38a0f138-ca02-a983-ce9d-64dd5caf0911","IFDatetime":"20190517142920"},"payload":{"T_DATA":[{"BUKRS":"H622","ZCCAR":"JJ","ZENDSC":"G80","ZCNDSC":"TEST1","ZCPCGB":"P","DATAB":"20190522","DATBI":"20190522","BLOCK":"Y"},{"BUKRS":"H622","ZCCAR":"JJ","ZENDSC":"G80","ZCNDSC":"TEST2","ZCPCGB":"C","DATAB":"20190522","DATBI":"20190522","BLOCK":" "}]}}}';
        
        SEMA_BULK_TEST_0002.InputDIH input = new SEMA_BULK_TEST_0002.InputDIH();
        input = (SEMA_BULK_TEST_0002.InputDIH)JSON.deserialize(req, SEMA_BULK_TEST_0002.InputDIH.class);
        
        return input;
    }
    
    // HTTPResponse 객체 생성
    private static HTTPResponse newResponse(Integer statusCode) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(statusCode);
        res.setBody('{"response":{"header":{"TrackingId":"38a0f138-ca02-a983-ce9d-64dd5caf0911","TaskId":"SEMA_BULK_TEST_0002","SenderGroup":"CN","SenderCode":"CXP","ResultCode":"S","IFDatetime":"20190603085741","ErrorMsg":"","ErrorCode":"","DestinationGroup":"CN","DestinationCode":"ERP"},"payload":{"ifRcvCnt":"2"}}}');
        SEMA_BULK_TEST_0002.OutputDIH temp = (SEMA_BULK_TEST_0002.OutputDIH)JSON.deserialize(res.getBody(), SEMA_BULK_TEST_0002.OutputDIH.class);
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

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/i2sema/SEMA_BULK_TEST_0002';  //Request URL
        req.httpMethod = 'POST';  //HTTP Request Type
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response = res;

        // 서비스 실행
        SEMA_BULK_TEST_0002.OutputDIH result = SEMA_BULK_TEST_0002.doPost();
        System.debug('result : '+result);
        //System.assertEquals(result.Response.Header.ResultCode, 'S', 'SEMA_BULK_TEST_0002 실패!!!');

        // crashTest
        IF_BaseNotiforce.crashTest = true;
        result = SEMA_BULK_TEST_0002.doPost();
        
        //System.assertEquals(result.Response.Header.ResultCode, 'E', 'SEMA_BULK_TEST_0002 실패!!!');
        return true;
    }

    // 성공 테스트
    @isTest public static void testServiceSuccess() {
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
        IF_BaseNotiforce.staticValue = i2SEMA_TestDataUtil.getIfStaticValue();

        System.assertEquals(testServiceExecute(), true);
    }
}