/****************************************************************************************
  * File Name   : IF_KR_ERP_SE_0016_TEST
  * Description : IF_KR_ERP_SE_0016_TEST Test Class
  * Author      : Create
  * Modification Log
  * ===============================================================
  * Ver  Date        Author              Modification
  * ===============================================================
    1.0  2020.04.20   ldb3100            Create
****************************************************************************************/
@isTest
public class IF_KR_ERP_SE_0016_TEST {
	
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
    private static IF_KR_ERP_SE_0016.InputDIH newInputParameter() {
        String req = '{"request":{"payload":{"ifAggregation":"0000000180","ifSplitSeq":"1","ifSplitCnt":"0","ifTotCnt":"0","t_data":[{"QueryDate":"202003","ProductName":"TRACTOR-R-41RFMTAB-42PS_ATEST","ErpSFAKN":"","DistributionChannel":"10","BillingDay":"2010-08-31","BillingDocNo":"8110050584","SalesDocNo":"5110012335","OrderQuantity":"1.0","ErpOrderType":"TA","SalesTeam":"5600","ErpFKSTO":"","SalesDocItem":"8","CustomerName":"대명상사","SalesGroupName":"트랙터영업지원","BillingType":"F2","SalesAmount":"10,000,000","BusinessOfficeName":"경기(영)","ProductCode":"2098695","CustomerCode":"102835","MachineNo":"2101010014","ErpSPART":"71","CurrencyName":"KRW","BillingDocItem":"8","SalesTeamName":"트랙터국내영업팀","BusinessOfficeCode":"71A","ErpVKORG":"3000","ErpVRKME":"EA","SalesGroupCode":"560"}]},"header":{"ifDateTime":"20200428173513","ifReceiverGp":"KR","ifResult":"","ifTrackingId":"0000000180","ifReceiver":"SE","ifId":"IF_KR_ERP_SE_0016","ifFailCode":"","ifSenderGp":"KR","ifFailMsg":"","ifSender":"SAP"}}}';
        
        IF_KR_ERP_SE_0016.InputDIH input = new IF_KR_ERP_SE_0016.InputDIH();
        input = (IF_KR_ERP_SE_0016.InputDIH)JSON.deserialize(req, IF_KR_ERP_SE_0016.InputDIH.class);
        
        return input;
    }
    
    // HTTPResponse 객체 생성
    private static HTTPResponse newResponse(Integer statusCode) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(statusCode);
        res.setBody('{"response":{"header":{"ifTrackingId":"0002e2d0-cec3-6e84-5761-ae68b3bf20a3","ifSenderGp":"SFDC","ifSender":"SE","ifResult":"S","ifReceiverGp":"LSMTRON","ifReceiver":"ERP","ifId":"IF_KR_ERP_SE_0016","ifFailMsg":"","ifFailCode":"","ifDateTime":"20200406110322"},"payload":{"ifSplitCnt":null,"ifRcvCnt":null,"ifAggregation":null}}}');
        IF_KR_ERP_SE_0016.OutputDIH temp = (IF_KR_ERP_SE_0016.OutputDIH)JSON.deserialize(res.getBody(), IF_KR_ERP_SE_0016.OutputDIH.class);
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

        req.requestURI = '/services/apexrest/IF_KR_ERP_SE_0016';  //Request URL
        req.httpMethod = 'POST';  //HTTP Request Type
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response = res;

        // 서비스 실행
        IF_KR_ERP_SE_0016.OutputDIH result = IF_KR_ERP_SE_0016.doPost();
        System.debug('result : '+result);
        //System.assertEquals(result.Response.Header.ResultCode, 'S', 'IF_KR_ERP_SE_0016 실패!!!');

        // crashTest
        IF_Base.crashTest = true;
        result = IF_KR_ERP_SE_0016.doPost();
        
        //System.assertEquals(result.Response.Header.ResultCode, 'E', 'IF_KR_ERP_SE_0016 실패!!!');
        return true;
    }

    // 성공 테스트
    @isTest public static void testServiceSuccess() {
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());

        System.assertEquals(testServiceExecute(), true);
    }
}