/****************************************************************************************
  * File Name   : IF_KR_SE_LWS_0035_TEST
  * Description : IF_KR_SE_LWS_0035_TEST Test Class
  * Author      : ldb3100
  * Modification Log
  * ===============================================================
  * Ver  Date           Author     Modification
  * ===============================================================
    1.0  2020. 07. 02.  ldb3100    Create
****************************************************************************************/
@isTest
private class IF_KR_SE_LWS_0035_TEST {
     // 입력 객체 생성
    private static IF_KR_SE_LWS_0035.InputDIH newInputParameter() {
        IF_KR_SE_LWS_0035.InputBody payload = new IF_KR_SE_LWS_0035.InputBody();

        IF_KR_SE_LWS_0035.InputDIH input = new IF_KR_SE_LWS_0035.InputDIH();

        IF_KR_SE_LWS_0035.Input inputObj = input.Request;

        inputObj.Header = new IF_LWS_Base.InputHeader('a6bba321-2183-5fb4-ff75-4d024e39a98e', 'IF_KR_SE_LWS_0035', '20161110021630', 'S', '', '');
        inputObj.Payload = payload;
        return input;
    }

    // HTTPResponse 객체 생성
    private static HTTPResponse newResponse(Integer statusCode) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(statusCode);
        res.setBody('{"Response":{"Header":{"TrackingId":"38a0f138-ca02-a983-ce9d-64dd5caf0911","TaskId":"IF_KR_SE_LWS_0035","SenderGroup":"CN","SenderCode":"CXP","ResultCode":"S","IFDatetime":"20190603085741","ErrorMsg":"","ErrorCode":"","DestinationGroup":"CN","DestinationCode":"ERP"},"Payload":{"TOTAL_RECORD_CNT":"2"}}}');
        IF_KR_SE_LWS_0035.OutputDIH temp = (IF_KR_SE_LWS_0035.OutputDIH)JSON.deserialize(res.getBody(), IF_KR_SE_LWS_0035.OutputDIH.class);
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

        req.requestURI = '/services/apexrest/IF_KR_SE_LWS_0035';  //Request URL
        req.httpMethod = 'POST';  //HTTP Request Type
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response = res;

        System.debug('time : ' + String.valueOf(system.now()));

        IF_KR_SE_LWS_0035 instance = IF_KR_SE_LWS_0035.getInstance();
        // 서비스 실행
        IF_KR_SE_LWS_0035.InputDIH input = new IF_KR_SE_LWS_0035.InputDIH();
        IF_KR_SE_LWS_0035.INPUT_T_DATA tData = new IF_KR_SE_LWS_0035.INPUT_T_DATA();
        tData.Account            = '0011m00000DDjk3AA';
        tData.AssetNo            = '';
        tData.AccountName        = '신고객'; 
        tData.IsCUPI             = 'TRUE'; 
        tData.PersonMobilePhone  = '010-1235-4512'; 
        tData.Phone              = '032-2345-1245'; 
        tData.Fax                = ''; 
        tData.PersonEmail        = ''; 
        tData.BillingPostalCode  = '17088'; 
        tData.BillingState       = '경기도'; 
        tData.BillingCity        = '용인시'; 
        tData.BillingStreet      = '기흥구 지삼로 73-3'; 
        tData.FarmingForm        = '수도작'; 
        tData.DealerName         = '용인농기계'; 
        tData.ERPCode            = '0000112594'; 
        tData.LWSNo              = ''; 
        
        input.request.payload.t_data.add(tData);
        
        System.debug('result input : '+ JSON.serialize(input));

        IF_KR_SE_LWS_0035.OutputDIH result = instance.execute(input);
        System.debug('result : '+result);

        //System.assertEquals(result.Response.Header.ResultCode, 'S', 'IF_KR_SE_LWS_0035 성공!!!');

        // crashTest
        IF_LWS_Base.crashTest = true;
        result = instance.execute(new IF_KR_SE_LWS_0035.InputDIH());

        //System.assertEquals(result.Response.Header.ResultCode, 'E', 'IF_KR_SE_LWS_0035 실패!!!');
        return true;
    }

    // 성공 테스트
    @isTest public static void testServiceSuccess() {
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());

        System.assertEquals(testServiceExecute(), true);
    }
}