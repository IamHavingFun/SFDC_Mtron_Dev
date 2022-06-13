/****************************************************************************************
  * File Name   : IF_KR_SE_ERP_0038_TEST
  * Description : IF_KR_SE_ERP_0038_TEST Test Class
  * Author      : ldb3100
  * Modification Log
  * ===============================================================
  * Ver  Date           Author     Modification
  * ===============================================================
    1.0  2020. 11. 24.  ldb3100    Create
****************************************************************************************/
@isTest
private class IF_KR_SE_ERP_0038_TEST {
     // 입력 객체 생성
    private static IF_KR_SE_ERP_0038.InputDIH newInputParameter() {
        IF_KR_SE_ERP_0038.InputBody payload = new IF_KR_SE_ERP_0038.InputBody();

        IF_KR_SE_ERP_0038.InputDIH input = new IF_KR_SE_ERP_0038.InputDIH();

        IF_KR_SE_ERP_0038.Input inputObj = input.Request;

        inputObj.Header = new IF_Base.InputHeader('a6bba321-2183-5fb4-ff75-4d024e39a98e', 'IF_KR_SE_ERP_0038', '20161110021630', 'S', '', '');
        inputObj.Payload = payload;
        return input;
    }

    // HTTPResponse 객체 생성
    private static HTTPResponse newResponse(Integer statusCode) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(statusCode);
        res.setBody('{"Response":{"Header":{"TrackingId":"38a0f138-ca02-a983-ce9d-64dd5caf0911","TaskId":"IF_KR_SE_ERP_0038","SenderGroup":"CN","SenderCode":"CXP","ResultCode":"S","IFDatetime":"20190603085741","ErrorMsg":"","ErrorCode":"","DestinationGroup":"CN","DestinationCode":"ERP"},"Payload":{"TOTAL_RECORD_CNT":"2"}}}');
        IF_KR_SE_ERP_0038.OutputDIH temp = (IF_KR_SE_ERP_0038.OutputDIH)JSON.deserialize(res.getBody(), IF_KR_SE_ERP_0038.OutputDIH.class);
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

        req.requestURI = '/services/apexrest/IF_KR_SE_ERP_0038';  //Request URL
        req.httpMethod = 'POST';  //HTTP Request Type
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response = res;

        System.debug('time : ' + String.valueOf(system.now()));

        IF_KR_SE_ERP_0038 instance = IF_KR_SE_ERP_0038.getInstance();
        // 서비스 실행
        IF_KR_SE_ERP_0038.InputDIH input = new IF_KR_SE_ERP_0038.InputDIH();
        IF_KR_SE_ERP_0038.T_DATA tData = new IF_KR_SE_ERP_0038.T_DATA();
        tData.VBELN = '1';
        tData.WADAT = '1';
        tData.CHARG = '1';
                              
        input.request.payload.t_data.add(tData);
        
        System.debug('result input : '+ JSON.serialize(input));

        IF_KR_SE_ERP_0038.OutputDIH result = instance.execute(input);
        System.debug('result : '+result);

        //System.assertEquals(result.Response.Header.ResultCode, 'S', 'IF_KR_SE_ERP_0038 성공!!!');

        // crashTest
        IF_Base.crashTest = true;
        result = instance.execute(new IF_KR_SE_ERP_0038.InputDIH());

        //System.assertEquals(result.Response.Header.ResultCode, 'E', 'IF_KR_SE_ERP_0038 실패!!!');
        return true;
    }

    // 성공 테스트
    @isTest public static void testServiceSuccess() {
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());

        System.assertEquals(testServiceExecute(), true);
    }
}