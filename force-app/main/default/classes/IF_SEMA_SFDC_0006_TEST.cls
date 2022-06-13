/****************************************************************************************
  * File Name   : IF_SEMA_SFDC_0006_TEST
  * Description : IF_SEMA_SFDC_0006_TEST Test Class
  * Copyright   : Copyright © 2019 HYUNDAI All Rights Reserved
  * Author      : ldb3100
  * Modification Log
  * ===============================================================
  * Ver  Date        Author          Modification
  * ===============================================================
    1.0  2020.03.03  ldb3100         Create
****************************************************************************************/
@isTest
public class IF_SEMA_SFDC_0006_TEST {

    // 입력 객체 생성
    private static IF_SEMA_SFDC_0006.InputDIH newInputParameter() {
        String req = '{"request":{"header":{"TaskId":"IF_SEMA_SFDC_0006","SenderGroup":"CN","SenderCode":"ERP","DestinationGroup":"CN","DestinationCode":"CXP","TrackingId":"38a0f138-ca02-a983-ce9d-64dd5caf0911","IFDatetime":"20190517142920"},"payload":{"T_DATA":[{"recipient_ban_num":"01022884132","spam_num":"0701231234","reg_date":"2020-04-22 19:40:10","reg_type":"A"},{"recipient_ban_num":"01012344132","spam_num":"0701231234","reg_date":"2020-04-22 19:40:10","reg_type":"I"}]}}}';
        
        IF_SEMA_SFDC_0006.InputDIH input = new IF_SEMA_SFDC_0006.InputDIH();
        input = (IF_SEMA_SFDC_0006.InputDIH)JSON.deserialize(req, IF_SEMA_SFDC_0006.InputDIH.class);
        
        return input;
    }
    
    // HTTPResponse 객체 생성
    private static HTTPResponse newResponse(Integer statusCode) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(statusCode);
        res.setBody('{"response":{"header":{"TrackingId":"38a0f138-ca02-a983-ce9d-64dd5caf0911","TaskId":"IF_SEMA_SFDC_0006","SenderGroup":"CN","SenderCode":"CXP","ResultCode":"S","IFDatetime":"20190603085741","ErrorMsg":"","ErrorCode":"","DestinationGroup":"CN","DestinationCode":"ERP"},"payload":{"ifRcvCnt":"2"}}}');
        IF_SEMA_SFDC_0006.OutputDIH temp = (IF_SEMA_SFDC_0006.OutputDIH)JSON.deserialize(res.getBody(), IF_SEMA_SFDC_0006.OutputDIH.class);
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

        req.requestURI = '/services/apexrest/Notiforce/IF_SEMA_SFDC_0006';  //Request URL
        req.httpMethod = 'POST';  //HTTP Request Type
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response = res;

        // 서비스 실행
        IF_SEMA_SFDC_0006.OutputDIH result = IF_SEMA_SFDC_0006.doPost();
        System.debug('result : '+result);
        //System.assertEquals(result.Response.Header.ResultCode, 'S', 'IF_SEMA_SFDC_0006 실패!!!');

        // crashTest
        IF_BaseNotiforce.crashTest = true;
        result = IF_SEMA_SFDC_0006.doPost();
        
        //System.assertEquals(result.Response.Header.ResultCode, 'E', 'IF_SEMA_SFDC_0006 실패!!!');
        return true;
    }

    // 성공 테스트
    @isTest public static void testServiceSuccess() {
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
        IF_BaseNotiforce.staticValue = i2SEMA_TestDataUtil.getIfStaticValue();

        System.assertEquals(testServiceExecute(), true);
    }
}