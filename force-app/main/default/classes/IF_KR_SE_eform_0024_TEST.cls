/****************************************************************************************
  * File Name   : IF_KR_SE_eform_0024_TEST
  * Description : IF_KR_SE_eform_0024_TEST Test Class
  * Author      : ldb3100
  * Modification Log
  * ===============================================================
  * Ver  Date           Author     Modification
  * ===============================================================
    1.0  2020. 03. 09.  ldb3100    Create
****************************************************************************************/
@isTest
private class IF_KR_SE_eform_0024_TEST {
     // 입력 객체 생성
    private static IF_KR_SE_eform_0024.InputDIH newInputParameter() {
        IF_KR_SE_eform_0024.InputBody payload = new IF_KR_SE_eform_0024.InputBody();

        IF_KR_SE_eform_0024.InputDIH input = new IF_KR_SE_eform_0024.InputDIH();

        IF_KR_SE_eform_0024.Input inputObj = input.Request;

        inputObj.Header = new IF_Base.InputHeader('a6bba321-2183-5fb4-ff75-4d024e39a98e', 'IF_KR_SE_eform_0024', '20161110021630', 'S', '', '');
        inputObj.Payload = payload;
        return input;
    }

    // HTTPResponse 객체 생성
    private static HTTPResponse newResponse(Integer statusCode) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(statusCode);
        res.setBody('{"response":{"payload":{"ifAggregation":"Test Request","ifSplitSeq":"","ifSplitCnt":"","ifTotCnt":"","t_data":[{"API_URL":"https://kr-api.eformsign.com","ACCESS_TOKEN":"eyJhbGciOiJSUzI1NiJ9.eyJpc3MiOiJlZm9ybXNpZ24uaWFtIiwiY29udGV4dCI6eyJjbGllbnRJZCI6IjY4MDk0ZWVhMjVhZjRhNjI5ZTI4ZGU5Y2ZlYzRlYmZjIiwiY2xpZW50S2V5IjoiZTNiM2IzZTUtMGEzMS00NTE1LWE5NzEtN2M4Y2FlNDI4NzZmIiwibWFuYWdlbWVudElkIjoiMzRhYWI4MDBjMmEwNDQwNThmZDRlZjc5OGFlY2RlY2EiLCJzY29wZXMiOiJzbWFydF9lZm9ybV9zY29wZSIsInR5cGUiOiJ1c2VyIiwidXNlck5hbWUiOiI3YmY4NTQ5MS03N2Q1LTRlMTEtYTdlMS1lNjRjMDY4ZjQxOWMiLCJ1c2VySWQiOiJkZGVkYzU5NDI5MmM0OTQwOWJlNjZmMGUzM2M1NjIxNiIsInJlZnJlc2hUb2tlbiI6ImI5MDIzZDE4LTAyYjctNDA5Yi04ZjJlLWU3M2MwY2MxMTM5YyJ9LCJjbGFpbSI6eyJjb21wYW55X2lkIjoiMzI4NTgzY2FmYWU2NDZlNWEzZTZiZjliMjUwNDFkMzIiLCJhY2Nlc3Nfa2V5IjoiN2JmODU0OTEtNzdkNS00ZTExLWE3ZTEtZTY0YzA2OGY0MTljIn0sImV4cCI6MTU5NDA4Nzk2OCwiaWF0IjoxNTk0MDg0MzY4fQ.BjIp0KGIw48ejQcenVDk9t0wEYHOBfxTBOmZFX0-Drk33IHmdYsEd9Ywvt7PArlKDt9vaQXtjQID7Inj6GcFHriPNobPVcsJs7b2Z4aaVpTLy4IrFng4gnzji4ZveVv9TaFx421HUqtCBdbPo5JCq7xHfsuQHKS7pYTk7gP_ybE","REFRESH_TOKEN":"b9023d18-02b7-409b-8f2e-e73c0cc1139c"}]},"header":{"ifDateTime":"20200609034311","ifReceiverGp":"LSMTRON","ifResult":"S","ifTrackingId":"","ifReceiver":"SE","ifId":"IF_KR_SE_eform_0024","ifFailCode":"","ifSenderGp":"LSMTRON","ifFailMsg":"","ifSender":"eform"}}}');
        IF_KR_SE_eform_0024.OutputDIH temp = (IF_KR_SE_eform_0024.OutputDIH)JSON.deserialize(res.getBody(), IF_KR_SE_eform_0024.OutputDIH.class);
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

        req.requestURI = '/services/apexrest/IF_KR_SE_eform_0024';  //Request URL
        req.httpMethod = 'POST';  //HTTP Request Type
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response = res;

        System.debug('time : ' + String.valueOf(system.now()));

        IF_KR_SE_eform_0024 instance = IF_KR_SE_eform_0024.getInstance();
        // 서비스 실행
        IF_KR_SE_eform_0024.InputDIH input = new IF_KR_SE_eform_0024.InputDIH();
        IF_KR_SE_eform_0024.INPUT_T_DATA tData = new IF_KR_SE_eform_0024.INPUT_T_DATA();
        
        tData.PRIVATE_KEY   = '3041020100301306072a8648ce3d020106082a8648ce3d030107042730250201010420ca8ae8b087f64c393c0c17ae030cc0e1aa0a0cb308b20e59e368ffe9920b204f';
        tData.API_KEY       = '7bf85491-77d5-4e11-a7e1-e64c068f419c';
        tData.USER_NAME     = '';
                              
        input.request.payload.t_data.add(tData);
        
        System.debug('result input : '+ JSON.serialize(input));

        IF_KR_SE_eform_0024.OutputDIH result = instance.execute(input);
        System.debug('result : '+result);

        //System.assertEquals(result.Response.Header.ResultCode, 'S', 'IF_KR_SE_eform_0024 성공!!!');

        // crashTest
        IF_Base.crashTest = true;
        result = instance.execute(new IF_KR_SE_eform_0024.InputDIH());

        //System.assertEquals(result.Response.Header.ResultCode, 'E', 'IF_KR_SE_eform_0024 실패!!!');
        return true;
    }

    // 성공 테스트
    @isTest public static void testServiceSuccess() {
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());

        System.assertEquals(testServiceExecute(), true);
    }
}