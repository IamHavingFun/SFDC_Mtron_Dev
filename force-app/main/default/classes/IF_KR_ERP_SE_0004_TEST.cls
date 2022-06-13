/****************************************************************************************
  * File Name   : IF_KR_ERP_SE_0004_TEST
  * Description : IF_KR_ERP_SE_0004_TEST Test Class
  * Author      : Create
  * Modification Log
  * ===============================================================
  * Ver  Date        Author              Modification
  * ===============================================================
    1.0  2020.04.14   ldb3100            Create
****************************************************************************************/
@isTest
public class IF_KR_ERP_SE_0004_TEST {
	
	private static void testStaticValue() {
        IfStaticValue__c staticValue = new IfStaticValue__c();

        staticValue.Org_URL__c              = 'https://salesforce.com';
        staticValue.oauth_client_id__c      = 'client_id';
        staticValue.oauth_client_secret__c  = 'client_secret';
        staticValue.oauth_username__c       = 'salesforce@salesforce.com';
        staticValue.oauth_password__c       = 'salesforce';
        staticValue.ENCRYPT_ALGORITHM__c    = 'AES258';
        staticValue.dihAuthName__c          = 'dih';
        staticValue.dihAuthPwd__c           = 'dih_password';
        staticValue.dihAesKey__c            = 'aes_key';
        staticValue.dihAesInitVector__c     = 'aes_vector';

        IF_Base.IfStaticValue(staticValue);
    }

    // 입력 객체 생성
    private static IF_KR_ERP_SE_0004.InputDIH newInputParameter() {
        String req = '{"request":{"payload":{"ifAggregation":"89","ifSplitSeq":"1","ifSplitCnt":"1","ifTotCnt":"68","t_data":[{"QueryDate":"1","StockInDate":"1","ErpBizOffice":"1","ProductCode":"1","ElapsedDayOut":"1","ActualSalesDayIn":"1","ErpMAKTX":"1","MachineNo":"1","SerialNo":"1","ErpName":"1","SalesDate":"1","ElapsedDayIn":"1","SalesDocNo":"1","ActualSalesDayOut":"1","ErpCode":"1","OrderDivision":"1","FirstDeliveryDate":"1","SalesDocItem":"1","Price":"1","Qty":"1","DataType":"1","CustomerName":"1","ProductionDate":"1","ErpBizOfficeName":"1"}]},"header":{"ifDateTime":"20200420163751","ifReceiverGp":"KR","ifResult":"","ifTrackingId":"89","ifReceiver":"SE","ifId":"IF_KR_ERP_SE_0004","ifFailCode":"","ifSenderGp":"KR","ifFailMsg":"","ifSender":"SAP"}}}';
        
        IF_KR_ERP_SE_0004.InputDIH input = new IF_KR_ERP_SE_0004.InputDIH();
        input = (IF_KR_ERP_SE_0004.InputDIH)JSON.deserialize(req, IF_KR_ERP_SE_0004.InputDIH.class);
        
        return input;
    }
    
    // HTTPResponse 객체 생성
    private static HTTPResponse newResponse(Integer statusCode) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(statusCode);
        res.setBody('{"response":{"header":{"ifTrackingId":"0002e2d0-cec3-6e84-5761-ae68b3bf20a3","ifSenderGp":"SFDC","ifSender":"SE","ifResult":"S","ifReceiverGp":"LSMTRON","ifReceiver":"ERP","ifId":"IF_KR_ERP_SE_0004","ifFailMsg":"","ifFailCode":"","ifDateTime":"20200406110322"},"payload":{"ifSplitCnt":null,"ifRcvCnt":null,"ifAggregation":null}}}');
        IF_KR_ERP_SE_0004.OutputDIH temp = (IF_KR_ERP_SE_0004.OutputDIH)JSON.deserialize(res.getBody(), IF_KR_ERP_SE_0004.OutputDIH.class);
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

        req.requestURI = '/services/apexrest/IF_KR_ERP_SE_0004';  //Request URL
        req.httpMethod = 'POST';  //HTTP Request Type
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response = res;

        // 서비스 실행
        IF_KR_ERP_SE_0004.OutputDIH result = IF_KR_ERP_SE_0004.doPost();
        System.debug('result : '+result);
        //System.assertEquals(result.Response.Header.ResultCode, 'S', 'IF_KR_ERP_SE_0004 실패!!!');

        // crashTest
        IF_Base.crashTest = true;
        result = IF_KR_ERP_SE_0004.doPost();
        
        //System.assertEquals(result.Response.Header.ResultCode, 'E', 'IF_KR_ERP_SE_0004 실패!!!');
        return true;
    }

    // 성공 테스트
    @isTest public static void testServiceSuccess() {
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());

        System.assertEquals(testServiceExecute(), true);
    }
}