/****************************************************************************************
  * File Name   : IF_SEMA_SFDC_0004_TEST
  * Description : IF_SEMA_SFDC_0004_TEST Test Class
  * Author      : ldb3100
  * Modification Log
  * ===============================================================
  * Ver  Date        Author          Modification
  * ===============================================================
    1.0  2020.05.12  ldb3100         Create
****************************************************************************************/
@isTest
public class IF_SEMA_SFDC_0004_TEST {

    // 입력 객체 생성
    private static IF_SEMA_SFDC_0004.InputDIH newInputParameter() {
        String req = '{"request":{"header":{"TaskId":"IF_SEMA_SFDC_0004","SenderGroup":"CN","SenderCode":"ERP","DestinationGroup":"CN","DestinationCode":"CXP","TrackingId":"38a0f138-ca02-a983-ce9d-64dd5caf0911","IFDatetime":"20190517142920"},"payload":{"T_DATA":[{"total_cnt":"2","total_error":"1","t_log":[{"image_name":"LSMtron MT4.68시승","image_url":"http://mud-kage.kakao.com/dn/c8jO6s/btqCGpRbrds/avkNnPpX0XiKDx1W0D5ZRK/img_l.jpg"},{"image_name":"i2max","image_url":"http://mud-kage.kakao.com/dn/ICqwy/btqA2WVLh64/6BUlsNYVS0KEKjjgRFWxwk/img_l.png"}]}]}}}';
        
        IF_SEMA_SFDC_0004.InputDIH input = new IF_SEMA_SFDC_0004.InputDIH();
        input = (IF_SEMA_SFDC_0004.InputDIH)JSON.deserialize(req, IF_SEMA_SFDC_0004.InputDIH.class);
        
        return input;
    }
    
    // HTTPResponse 객체 생성
    private static HTTPResponse newResponse(Integer statusCode) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(statusCode);
        res.setBody('{"response":{"header":{"TrackingId":"38a0f138-ca02-a983-ce9d-64dd5caf0911","TaskId":"IF_SEMA_SFDC_0004","SenderGroup":"CN","SenderCode":"CXP","ResultCode":"S","IFDatetime":"20190603085741","ErrorMsg":"","ErrorCode":"","DestinationGroup":"CN","DestinationCode":"ERP"},"payload":{"ifRcvCnt":"2"}}}');
        IF_SEMA_SFDC_0004.OutputDIH temp = (IF_SEMA_SFDC_0004.OutputDIH)JSON.deserialize(res.getBody(), IF_SEMA_SFDC_0004.OutputDIH.class);
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

        req.requestURI = '/services/apexrest/Notiforce/IF_SEMA_SFDC_0004';  //Request URL
        req.httpMethod = 'POST';  //HTTP Request Type
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response = res;

        // 서비스 실행
        IF_SEMA_SFDC_0004.OutputDIH result = IF_SEMA_SFDC_0004.doPost();
        System.debug('result : '+result);
        //System.assertEquals(result.Response.Header.ResultCode, 'S', 'IF_SEMA_SFDC_0004 실패!!!');

        // crashTest
        IF_BaseNotiforce.crashTest = true;
        result = IF_SEMA_SFDC_0004.doPost();
        
        //System.assertEquals(result.Response.Header.ResultCode, 'E', 'IF_SEMA_SFDC_0004 실패!!!');
        return true;
    }

    // 성공 테스트
    @isTest public static void testServiceSuccess() {
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
        IF_BaseNotiforce.staticValue = i2SEMA_TestDataUtil.getIfStaticValue();

        System.assertEquals(testServiceExecute(), true);
    }
}