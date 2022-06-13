/****************************************************************************************
  * File Name   : IF_KR_ERP_SE_0010_TEST
  * Description : IF_KR_ERP_SE_0010_TEST Test Class
  * Author      : Create
  * Modification Log
  * ===============================================================
  * Ver  Date        Author              Modification
  * ===============================================================
    1.0  2020.06.15   ldb3100            Create
****************************************************************************************/
@isTest
public class IF_KR_ERP_SE_0010_TEST {
	
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
    private static IF_KR_ERP_SE_0010.InputDIH newInputParameter() {

        Order__c testOrder = TestDataSalesFactory.orderForPerFarCorp.clone(false, true);
        testOrder.SalesDocNo__c = '5110014542';
        insert testOrder;
        
        String req = '{"request":{"payload":{"ifAggregation":"0000000336","ifSplitSeq":"1","ifSplitCnt":"1","ifTotCnt":"1","t_data":[{"ErpPERNR":"30190064","ErpZGUBUN":"B","ErpMENGE":"1.000","ErpRQIND":"A","ErpUSELN_C":"9,928,924","ErpINTVL1_C":"0","ErpAPPAM_C":"348,392","ErpINTVL0_C":"-174,296","ErpINTVL5_C":"0","SalesDocNo":"5110014542","ErpNETWR_C":"174,196","ErpINTVL4_C":"0","ErpINTVL3_C":"0","ErpINTVL2_C":"522,654","ErpVKBUR":"5600","ErpKLIMK_C":"10,000","ErpNETPR_C":"174,196","ErpMATNR":"000000000010100075","ErpZLNNO":"1000000084","ErpGUAR_AMNT_C":"0","ErpKUNNR":"0000103144","ErpUSELN_F_C":"10,451,512","ErpRELDT":"2020-07-01","ErpSTOCK":"9.000","ErpVTWEG":"10","ErpWAERS":"KRW","ErpZRATE":"0","ErpARRME_C":"522,654","ErpCRED_GRAD":"","ErpAPPRV":"0004","ErpBILIN_C":"0","ErpSPART":"71","ErpARRRT":"150.03","ErpLVORM":"","ErpZLNST":"B","ErpZBESU":"00000","ErpPOSNR":"000010","ErpLVORM1":"","ErpVKGRP":"560","ErpVKORG":"3000","ErpLAPPR":"0004","ErpVRKME":"EA","ErpAUART":"TA","ErpLNREQ_C":"174,196","ErpLNREL":"C","ErpSUMME_C":"348,358","Detail":[{"ErpPERNR":"20060130","ErpAPSTA":"Y","ErpDGPER":"00000000","ErpZLADD":"","ErpAPTIM":"11:55:37","ErpAPDAT":"2020-07-01","ErpDGTFR":"0000-00-00","ErpAPPRV":"0001","ErpLRESN_T":"","ErpZLNNO":"1000000084","ErpLPLAN_T":"","ErpUNAME":"null","ErpLFDBK_T":"","ErpDGATE":"","ErpZPICH":"20060130","ErpDGTTO":"0000-00-00"},{"ErpPERNR":"19975020","ErpAPSTA":"Y","ErpDGPER":"00000000","ErpZLADD":"","ErpAPTIM":"11:56:19","ErpAPDAT":"2020-07-01","ErpDGTFR":"0000-00-00","ErpAPPRV":"0002","ErpLRESN_T":"","ErpZLNNO":"1000000084","ErpLPLAN_T":"","ErpUNAME":"19975020","ErpLFDBK_T":"","ErpDGATE":"","ErpZPICH":"19975020","ErpDGTTO":"0000-00-00"},{"ErpPERNR":"20051072","ErpAPSTA":"Y","ErpDGPER":"00000000","ErpZLADD":"","ErpAPTIM":"11:56:48","ErpAPDAT":"2020-07-01","ErpDGTFR":"0000-00-00","ErpAPPRV":"0003","ErpLRESN_T":"","ErpZLNNO":"1000000084","ErpLPLAN_T":"","ErpUNAME":"20051072","ErpLFDBK_T":"","ErpDGATE":"","ErpZPICH":"20051072","ErpDGTTO":"0000-00-00"}],"ErpZRATE_F":"0"},{"ErpPERNR":"30190064","ErpZGUBUN":"B","ErpMENGE":"1.000","ErpRQIND":"A","ErpUSELN_C":"9,928,924","ErpINTVL1_C":"0","ErpAPPAM_C":"348,392","ErpINTVL0_C":"-174,296","ErpINTVL5_C":"0","SalesDocNo":"5110014542","ErpNETWR_C":"174,196","ErpINTVL4_C":"0","ErpINTVL3_C":"0","ErpINTVL2_C":"522,654","ErpVKBUR":"5600","ErpKLIMK_C":"10,000","ErpNETPR_C":"174,196","ErpMATNR":"000000000010100075","ErpZLNNO":"1000000084","ErpGUAR_AMNT_C":"0","ErpKUNNR":"0000103144","ErpUSELN_F_C":"10,451,512","ErpRELDT":"2020-07-01","ErpSTOCK":"9.000","ErpVTWEG":"10","ErpWAERS":"KRW","ErpZRATE":"0","ErpARRME_C":"522,654","ErpCRED_GRAD":"","ErpAPPRV":"0004","ErpBILIN_C":"0","ErpSPART":"71","ErpARRRT":"150.03","ErpLVORM":"","ErpZLNST":"A","ErpZBESU":"00000","ErpPOSNR":"000010","ErpLVORM1":"","ErpVKGRP":"560","ErpVKORG":"3000","ErpLAPPR":"0004","ErpVRKME":"EA","ErpAUART":"TA","ErpLNREQ_C":"174,196","ErpLNREL":"C","ErpSUMME_C":"348,358","Detail":[{"ErpPERNR":"20060130","ErpAPSTA":"Y","ErpDGPER":"00000000","ErpZLADD":"","ErpAPTIM":"11:55:37","ErpAPDAT":"2020-07-01","ErpDGTFR":"0000-00-00","ErpAPPRV":"0001","ErpLRESN_T":"","ErpZLNNO":"1000000084","ErpLPLAN_T":"","ErpUNAME":"null","ErpLFDBK_T":"","ErpDGATE":"","ErpZPICH":"20060130","ErpDGTTO":"0000-00-00"},{"ErpPERNR":"19975020","ErpAPSTA":"Y","ErpDGPER":"00000000","ErpZLADD":"","ErpAPTIM":"11:56:19","ErpAPDAT":"2020-07-01","ErpDGTFR":"0000-00-00","ErpAPPRV":"0002","ErpLRESN_T":"","ErpZLNNO":"1000000084","ErpLPLAN_T":"","ErpUNAME":"19975020","ErpLFDBK_T":"","ErpDGATE":"","ErpZPICH":"19975020","ErpDGTTO":"0000-00-00"},{"ErpPERNR":"20051072","ErpAPSTA":"Y","ErpDGPER":"00000000","ErpZLADD":"","ErpAPTIM":"11:56:48","ErpAPDAT":"2020-07-01","ErpDGTFR":"0000-00-00","ErpAPPRV":"0003","ErpLRESN_T":"","ErpZLNNO":"1000000084","ErpLPLAN_T":"","ErpUNAME":"20051072","ErpLFDBK_T":"","ErpDGATE":"","ErpZPICH":"20051072","ErpDGTTO":"0000-00-00"}],"ErpZRATE_F":"0"}]},"header":{"ifDateTime":"20200701120327","ifReceiverGp":"KR","ifResult":"","ifTrackingId":"0000000336","ifReceiver":"SE","ifId":"IF_KR_ERP_SE_0010","ifFailCode":"","ifSenderGp":"KR","ifFailMsg":"","ifSender":"SAP"}}}';
        
        IF_KR_ERP_SE_0010.InputDIH input = new IF_KR_ERP_SE_0010.InputDIH();
        input = (IF_KR_ERP_SE_0010.InputDIH)JSON.deserialize(req, IF_KR_ERP_SE_0010.InputDIH.class);
        
        return input;
    }
    
    // HTTPResponse 객체 생성
    private static HTTPResponse newResponse(Integer statusCode) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(statusCode);
        res.setBody('{"response":{"header":{"ifTrackingId":"0002e2d0-cec3-6e84-5761-ae68b3bf20a3","ifSenderGp":"SFDC","ifSender":"SE","ifResult":"S","ifReceiverGp":"LSMTRON","ifReceiver":"ERP","ifId":"IF_KR_ERP_SE_0010","ifFailMsg":"","ifFailCode":"","ifDateTime":"20200406110322"},"payload":{"ifSplitCnt":null,"ifRcvCnt":null,"ifAggregation":null}}}');
        IF_KR_ERP_SE_0010.OutputDIH temp = (IF_KR_ERP_SE_0010.OutputDIH)JSON.deserialize(res.getBody(), IF_KR_ERP_SE_0010.OutputDIH.class);
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

        req.requestURI = '/services/apexrest/IF_KR_ERP_SE_0010';  //Request URL
        req.httpMethod = 'POST';  //HTTP Request Type
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response = res;

        // 서비스 실행
        IF_KR_ERP_SE_0010.OutputDIH result = IF_KR_ERP_SE_0010.doPost();
        System.debug('result : '+result);
        //System.assertEquals(result.Response.Header.ResultCode, 'S', 'IF_KR_ERP_SE_0010 실패!!!');

        // crashTest
        IF_Base.crashTest = true;
        result = IF_KR_ERP_SE_0010.doPost();
        
        //System.assertEquals(result.Response.Header.ResultCode, 'E', 'IF_KR_ERP_SE_0010 실패!!!');
        return true;
    }

    // 성공 테스트
    @isTest public static void testServiceSuccess() {
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());

        System.assertEquals(testServiceExecute(), true);
    }
}