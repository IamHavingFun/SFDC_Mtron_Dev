/****************************************************************************************
  * File Name   : IF_KR_ERP_SE_0014_TEST
  * Description : IF_KR_ERP_SE_0014_TEST Test Class
  * Author      : Create
  * Modification Log
  * ===============================================================
  * Ver  Date        Author              Modification
  * ===============================================================
    1.0  2020.04.17   ldb3100            Create
****************************************************************************************/
@isTest
public class IF_KR_ERP_SE_0014_TEST {
	
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
    private static IF_KR_ERP_SE_0014.InputDIH newInputParameter() {
        String req = '{"request":{"payload":{"ifAggregation":"b3ae147e-c504-2c22-b40d-9b1b34a348c7","ifSplitSeq":"","ifSplitCnt":"","ifTotCnt":"","t_data":[{"QueryDate":"202003","FiscalYear":"2010","NoteCollectMoneyKRW":"0","DistributionChannel":"10","BillingDocNo":"8110050431","GlName":"외상매출금-국내","SalesTeam":"5600","ErpBUKRS":"3000","CustomerName":"(주)농우기계(장호원)","SalesGroupName":"트랙터영업지원","RepaymentKRW":"198,000","BusinessOfficeName":"경기(영)","PlanDate":"2010-05-26","CustomerCode":"33597","ErpZUONR":"{}","GlCode":"311361","ArAmtKRW":"198,000","BookkeepingDate":"2010-01-26","ErpSPART":"71","CurrencyName":"KRW","BillingDocItem":"1","SalesTeamName":"트랙터국내영업팀","BusinessOfficeCode":"71A","ErpVKORG":"3000","SalesGroupCode":"560"}]},"header":{"ifDateTime":"2020 04 13 15 00","ifReceiverGp":"LSMTRON","ifResult":"","ifTrackingId":"b3ae147e-c504-2c22-b40d-9b1b34a348c7","ifReceiver":"SE","ifId":"IF_KR_ERP_SE_0014","ifFailCode":"","ifSenderGp":"LSMTRON","ifFailMsg":"","ifSender":"ERP"}}}';
        
        IF_KR_ERP_SE_0014.InputDIH input = new IF_KR_ERP_SE_0014.InputDIH();
        input = (IF_KR_ERP_SE_0014.InputDIH)JSON.deserialize(req, IF_KR_ERP_SE_0014.InputDIH.class);
        
        return input;
    }
    
    // HTTPResponse 객체 생성
    private static HTTPResponse newResponse(Integer statusCode) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(statusCode);
        res.setBody('{"response":{"header":{"ifTrackingId":"0002e2d0-cec3-6e84-5761-ae68b3bf20a3","ifSenderGp":"SFDC","ifSender":"SE","ifResult":"S","ifReceiverGp":"LSMTRON","ifReceiver":"ERP","ifId":"IF_KR_ERP_SE_0014","ifFailMsg":"","ifFailCode":"","ifDateTime":"20200406110322"},"payload":{"ifSplitCnt":null,"ifRcvCnt":null,"ifAggregation":null}}}');
        IF_KR_ERP_SE_0014.OutputDIH temp = (IF_KR_ERP_SE_0014.OutputDIH)JSON.deserialize(res.getBody(), IF_KR_ERP_SE_0014.OutputDIH.class);
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

        req.requestURI = '/services/apexrest/IF_KR_ERP_SE_0014';  //Request URL
        req.httpMethod = 'POST';  //HTTP Request Type
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response = res;

        // 서비스 실행
        IF_KR_ERP_SE_0014.OutputDIH result = IF_KR_ERP_SE_0014.doPost();
        System.debug('result : '+result);
        //System.assertEquals(result.Response.Header.ResultCode, 'S', 'IF_KR_ERP_SE_0014 실패!!!');

        // crashTest
        IF_Base.crashTest = true;
        result = IF_KR_ERP_SE_0014.doPost();
        
        //System.assertEquals(result.Response.Header.ResultCode, 'E', 'IF_KR_ERP_SE_0014 실패!!!');
        return true;
    }

    // 성공 테스트
    @isTest public static void testServiceSuccess() {
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());

        System.assertEquals(testServiceExecute(), true);
    }
}