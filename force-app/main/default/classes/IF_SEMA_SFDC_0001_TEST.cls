/****************************************************************************************
  * File Name   : IF_SEMA_SFDC_0001_TEST
  * Description : IF_SEMA_SFDC_0001_TEST Test Class
  * Author      : ldb3100
  * Modification Log
  * ===============================================================
  * Ver  Date        Author          Modification
  * ===============================================================
    1.0  2020.03.03  ldb3100         Create
****************************************************************************************/
@isTest
public class IF_SEMA_SFDC_0001_TEST {

    // 입력 객체 생성
    private static IF_SEMA_SFDC_0001.InputDIH newInputParameter() {
        String req = '{"request":{"header":{"TaskId":"IF_SEMA_SFDC_0001","SenderGroup":"CN","SenderCode":"ERP","DestinationGroup":"CN","DestinationCode":"CXP","TrackingId":"38a0f138-ca02-a983-ce9d-64dd5caf0911","IFDatetime":"20190517142920"},"payload":{"T_DATA":[{"total_cnt":"2","total_error":"1","t_err":[{"seq":"1234","per_seq":"1234567","noti_group_id":"a0N2w000000VHb6EAG","noti_id":"a0P2w000000y1nLEAQ","success_yn":"Y","recipient_num":"01022884132","mt_report_code_ib":"1234","code_message":"Success"},{"seq":"1235","per_seq":"1234568","noti_group_id":"a0N2w000000VHb6EAG","noti_id":"a0P2w000000y2nLEAQ","success_yn":"N","recipient_num":"01012344132","mt_report_code_ib":"3333","code_message":"Fail"}]}]}}}';
        
        IF_SEMA_SFDC_0001.InputDIH input = new IF_SEMA_SFDC_0001.InputDIH();
        input = (IF_SEMA_SFDC_0001.InputDIH)JSON.deserialize(req, IF_SEMA_SFDC_0001.InputDIH.class);
        
        return input;
    }
    
    // HTTPResponse 객체 생성
    private static HTTPResponse newResponse(Integer statusCode) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(statusCode);
        res.setBody('{"response":{"header":{"TrackingId":"38a0f138-ca02-a983-ce9d-64dd5caf0911","TaskId":"IF_SEMA_SFDC_0001","SenderGroup":"CN","SenderCode":"CXP","ResultCode":"S","IFDatetime":"20190603085741","ErrorMsg":"","ErrorCode":"","DestinationGroup":"CN","DestinationCode":"ERP"},"payload":{"ifRcvCnt":"2"}}}');
        IF_SEMA_SFDC_0001.OutputDIH temp = (IF_SEMA_SFDC_0001.OutputDIH)JSON.deserialize(res.getBody(), IF_SEMA_SFDC_0001.OutputDIH.class);
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

        req.requestURI = '/services/apexrest/Notiforce/IF_SEMA_SFDC_0001';  //Request URL
        req.httpMethod = 'POST';  //HTTP Request Type
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response = res;

        // 서비스 실행
        IF_SEMA_SFDC_0001.OutputDIH result = IF_SEMA_SFDC_0001.doPost();
        System.debug('result : '+result);
        //System.assertEquals(result.Response.Header.ResultCode, 'S', 'IF_SEMA_SFDC_0001 실패!!!');

        // crashTest
        IF_BaseNotiforce.crashTest = true;
        result = IF_SEMA_SFDC_0001.doPost();
        
        //System.assertEquals(result.Response.Header.ResultCode, 'E', 'IF_SEMA_SFDC_0001 실패!!!');
        return true;
    }

    // 성공 테스트
    @isTest public static void testServiceSuccess() {
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
        IF_BaseNotiforce.staticValue = i2SEMA_TestDataUtil.getIfStaticValue();

        System.assertEquals(testServiceExecute(), true);
    }
}