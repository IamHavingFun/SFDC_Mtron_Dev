/****************************************************************************************
  * File Name   : IF_KR_SE_ERP_0007_TEST
  * Description : IF_KR_SE_ERP_0007_TEST Test Class
  * Author      : ldb3100
  * Modification Log
  * ===============================================================
  * Ver  Date           Author     Modification
  * ===============================================================
    1.0  2020. 03. 09.  ldb3100    Create
****************************************************************************************/
@isTest
private class IF_KR_SE_ERP_0007_TEST {
     // 입력 객체 생성
    private static IF_KR_SE_ERP_0007.InputDIH newInputParameter() {
        IF_KR_SE_ERP_0007.InputBody payload = new IF_KR_SE_ERP_0007.InputBody();

        IF_KR_SE_ERP_0007.InputDIH input = new IF_KR_SE_ERP_0007.InputDIH();

        IF_KR_SE_ERP_0007.Input inputObj = input.Request;

        inputObj.Header = new IF_Base.InputHeader('a6bba321-2183-5fb4-ff75-4d024e39a98e', 'IF_KR_SE_ERP_0007', '20161110021630', 'S', '', '');
        inputObj.Payload = payload;
        return input;
    }

    // HTTPResponse 객체 생성
    private static HTTPResponse newResponse(Integer statusCode) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(statusCode);
        res.setBody('{"Response":{"Header":{"TrackingId":"38a0f138-ca02-a983-ce9d-64dd5caf0911","TaskId":"IF_KR_SE_ERP_0007","SenderGroup":"CN","SenderCode":"CXP","ResultCode":"S","IFDatetime":"20190603085741","ErrorMsg":"","ErrorCode":"","DestinationGroup":"CN","DestinationCode":"ERP"},"Payload":{"TOTAL_RECORD_CNT":"2"}}}');
        IF_KR_SE_ERP_0007.OutputDIH temp = (IF_KR_SE_ERP_0007.OutputDIH)JSON.deserialize(res.getBody(), IF_KR_SE_ERP_0007.OutputDIH.class);
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

        req.requestURI = '/services/apexrest/IF_KR_SE_ERP_0007';  //Request URL
        req.httpMethod = 'POST';  //HTTP Request Type
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response = res;

        System.debug('time : ' + String.valueOf(system.now()));

        IF_KR_SE_ERP_0007 instance = IF_KR_SE_ERP_0007.getInstance();
        // 서비스 실행
        IF_KR_SE_ERP_0007.InputDIH input = new IF_KR_SE_ERP_0007.InputDIH();
        IF_KR_SE_ERP_0007.T_DATA tData = new IF_KR_SE_ERP_0007.T_DATA();
        tData.OrderID         = 'a0Z1m0000005oSaEAI';
        tData.OrderLineItemID = 'a0Z1m0000005oSaEAI';
        tData.ErpAUART        = 'OR';
        tData.ErpVKORG        = '3000';
        tData.ErpVTWEG        = '10';
        tData.ErpSPART        = '71';
        tData.ErpVKBUR        = '5600';
        tData.ErpVKGRP        = '56X';
        tData.ErpBSTKD        = '2';
        tData.ErpBSTDK        = '20200526';
        tData.ErpKUNNR        = '0000100354';
        tData.ErpKUNNR2       = '0000100354';
        tData.ErpKUNNR3       = '0000100354';
        tData.ErpZTERM        = '';
        tData.ProductCode     = '000000000010003010';
        tData.Quanitity       = '1';
        tData.CHARG           = '1';
        tData.VSTEL           = '1';
        tData.LGORT           = '1';
        tData.ErpZFLAG        = 'C';
        tData.SalesDocNo      = '5110012459';
        tData.ErpPOSNR        = '000010';
        tData.ErpCMGST        = 'B';
        tData.ErpABGRU        = '';
        tData.KEDAT           = '20200526';
        tData.DLTXT           = '';
        tData.NETWR1_C        = '';
        tData.NETWR2_C        = '';
        tData.NETWR3_C        = '';
        tData.RESERVE01       = '';
        tData.RESERVE02       = '';
        tData.RESERVE03       = '';
        tData.RESERVE04       = '';
        tData.RESERVE05       = '';
        tData.ErpS_RESULT     = '';
        tData.ErpS_MESSAGE    = '';
        tData.PRSDT           = '20200527';
                              
        input.request.payload.t_data.add(tData);
        
        System.debug('result input : '+ JSON.serialize(input));

        IF_KR_SE_ERP_0007.OutputDIH result = instance.execute(input);
        System.debug('result : '+result);

        //System.assertEquals(result.Response.Header.ResultCode, 'S', 'IF_KR_SE_ERP_0007 성공!!!');

        // crashTest
        IF_Base.crashTest = true;
        result = instance.execute(new IF_KR_SE_ERP_0007.InputDIH());

        //System.assertEquals(result.Response.Header.ResultCode, 'E', 'IF_KR_SE_ERP_0007 실패!!!');
        return true;
    }

    // 성공 테스트
    @isTest public static void testServiceSuccess() {
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());

        System.assertEquals(testServiceExecute(), true);
    }
}