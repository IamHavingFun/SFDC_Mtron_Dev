/****************************************************************************************
  * File Name   : IF_BaseLogREST_TEST
  * Description : IF_BaseLogREST_TEST Impl Class
  * Author      : ldb3100
  * Modification Log
  * ===============================================================
  * Ver  Date        Author          Modification
  * ===============================================================
    1.0  2020.03.09  ldb3100         Create                
****************************************************************************************/
@isTest
public class IF_BaseLogREST_TEST {
    // 입력 객체 생성
    private static IF_BaseLogVO newInputParameter() {
        IF_LOG__c log = new IF_LOG__c();
        String sndJsonBlob = null; 
        String rcvJsonBlob = null;
        IF_BaseLogVO vo = new IF_BaseLogVO(log, sndJsonBlob, rcvJsonBlob);
        return vo;
    }

    // HTTPResponse 객체 생성
    private static HTTPResponse newResponse(Integer statusCode) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(statusCode);
        res.setBody('');
        return res;
    }

    // StatusCode=200 Mock
    public class HttpCalloutSuccessMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = newResponse(200);
            return res;
        }
    }

    // 공통 테스트 진행
    public static Boolean testServiceExecute() {
        String result = null;

        String jsonMsg = JSON.serialize(newInputParameter());

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/IF_BaseLogREST';  //Request URL
        req.httpMethod = 'POST';  //HTTP Request Type
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response = res;
        
        //서비스 실행
        result = IF_BaseLogREST.log();
        if (result == null) {
            return false;
        }

        //System.assertEquals(result, 'success', 'IF_BaseLogREST 실패!!!');

        // crashTest
        IF_BaseLogREST.crashTest = true;
        result = IF_BaseLogREST.log();

        //System.assertEquals(result, 'fail', 'IF_BaseLogREST 실패!!!');
        return true;
    }

    // 성공 테스트
    @isTest public static void testServiceSuccess() {
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());

        System.assertEquals(testServiceExecute(), true);
    }
}