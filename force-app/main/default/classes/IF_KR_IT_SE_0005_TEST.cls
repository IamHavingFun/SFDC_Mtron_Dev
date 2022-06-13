/****************************************************************************************
  * File Name   : IF_KR_IT_SE_0005_TEST
  * Description : IF_KR_IT_SE_0005_TEST Class 
  * Author      : danbi.lee
  * copyright   : Copyright © I2max. All Rights Reserved.
  * Modification Log
  * ===============================================================
  * Ver   Date         Author       Modification
  * ===============================================================
    1.0   2021-05-31      danbi.lee    Create
***************************************************************************************/
@isTest
public class IF_KR_IT_SE_0005_TEST {
    // 입력 객체 생성
    private static IF_KR_IT_SE_0005.InputDIH newInputParameter() {          // 정상 일반고객 고장
        String req = '{"request":{"header":{"ifTrackingId":"TestSample","ifSenderGp":"LSMTRON","ifSender":"iTractor","ifReceiverGp":"LSMTRON","ifReceiver":"SE","ifId":"IF_KR_IT_SE_0005","ifDateTime":"20211014034311"},"payload":{"t_data":[{"tractor_id":"1234567890","code_type":"00","code":"T123", "customer_use_yn":"Y", "office_use_yn":"Y", "agency_use_yn":"Y", "nonghyup_use_yn":"Y"}]}}}';

        IF_KR_IT_SE_0005.InputDIH input = new IF_KR_IT_SE_0005.InputDIH();
        input = (IF_KR_IT_SE_0005.InputDIH)JSON.deserialize(req, IF_KR_IT_SE_0005.InputDIH.class);

        return input;
    }
    private static IF_KR_IT_SE_0005.InputDIH newInputParameter2() {         // 정상 농협고객 경고
        String req = '{"request":{"header":{"ifTrackingId":"TestSample","ifSenderGp":"LSMTRON","ifSender":"iTractor","ifReceiverGp":"LSMTRON","ifReceiver":"SE","ifId":"IF_KR_IT_SE_0005","ifDateTime":"20211014034311"},"payload":{"t_data":[{"tractor_id":"123123123","code_type":"01","code":"T111", "customer_use_yn":"Y", "office_use_yn":"Y", "agency_use_yn":"Y", "nonghyup_use_yn":"Y"}]}}}';

        IF_KR_IT_SE_0005.InputDIH input = new IF_KR_IT_SE_0005.InputDIH();
        input = (IF_KR_IT_SE_0005.InputDIH)JSON.deserialize(req, IF_KR_IT_SE_0005.InputDIH.class);

        return input;
    }
    private static IF_KR_IT_SE_0005.InputDIH newInputParameter3() {         // 정상 일반고객 경고
        String req = '{"request":{"header":{"ifTrackingId":"TestSample","ifSenderGp":"LSMTRON","ifSender":"iTractor","ifReceiverGp":"LSMTRON","ifReceiver":"SE","ifId":"IF_KR_IT_SE_0005","ifDateTime":"20211014034311"},"payload":{"t_data":[{"tractor_id":"1234567890","code_type":"01","code":"T111", "customer_use_yn":"Y", "office_use_yn":"Y", "agency_use_yn":"Y", "nonghyup_use_yn":"Y"}]}}}';

        IF_KR_IT_SE_0005.InputDIH input = new IF_KR_IT_SE_0005.InputDIH();
        input = (IF_KR_IT_SE_0005.InputDIH)JSON.deserialize(req, IF_KR_IT_SE_0005.InputDIH.class);

        return input;
    }
    private static IF_KR_IT_SE_0005.InputDIH newInputParameter4() {         // 정상 농협고객 고장
        String req = '{"request":{"header":{"ifTrackingId":"TestSample","ifSenderGp":"LSMTRON","ifSender":"iTractor","ifReceiverGp":"LSMTRON","ifReceiver":"SE","ifId":"IF_KR_IT_SE_0005","ifDateTime":"20211014034311"},"payload":{"t_data":[{"tractor_id":"123123123","code_type":"00","code":"T123", "customer_use_yn":"Y", "office_use_yn":"Y", "agency_use_yn":"Y", "nonghyup_use_yn":"Y"}]}}}';

        IF_KR_IT_SE_0005.InputDIH input = new IF_KR_IT_SE_0005.InputDIH();
        input = (IF_KR_IT_SE_0005.InputDIH)JSON.deserialize(req, IF_KR_IT_SE_0005.InputDIH.class);

        return input;
    }
    private static IF_KR_IT_SE_0005.InputDIH newInputParameter5() {
        String req = '{"request":{"header":{"ifTrackingId":"TestSample","ifSenderGp":"LSMTRON","ifSender":"iTractor","ifReceiverGp":"LSMTRON","ifReceiver":"SE","ifId":"IF_KR_IT_SE_0005","ifDateTime":"20211014034311"},"payload":{"t_data":[{"tractor_id":"123123123","code_type":"00","code":"T123", "customer_use_yn":"N", "office_use_yn":"N", "agency_use_yn":"N", "nonghyup_use_yn":"N"}]}}}';

        IF_KR_IT_SE_0005.InputDIH input = new IF_KR_IT_SE_0005.InputDIH();
        input = (IF_KR_IT_SE_0005.InputDIH)JSON.deserialize(req, IF_KR_IT_SE_0005.InputDIH.class);

        return input;
    }
    private static IF_KR_IT_SE_0005.InputDIH newInputParameter6() {
        String req = '{"request":{"header":{"ifTrackingId":"TestSample","ifSenderGp":"LSMTRON","ifSender":"iTractor","ifReceiverGp":"LSMTRON","ifReceiver":"SE","ifId":"IF_KR_IT_SE_0005","ifDateTime":"20211014034311"},"payload":{"t_data":[{"tractor_id":"123123123","code_type":"00","code":"T12345", "customer_use_yn":"N", "office_use_yn":"N", "agency_use_yn":"N", "nonghyup_use_yn":"N"}]}}}';

        IF_KR_IT_SE_0005.InputDIH input = new IF_KR_IT_SE_0005.InputDIH();
        input = (IF_KR_IT_SE_0005.InputDIH)JSON.deserialize(req, IF_KR_IT_SE_0005.InputDIH.class);

        return input;
    }
    private static IF_KR_IT_SE_0005.InputDIH newInputParameter7() {
        String req = '{"request":{"header":{"ifTrackingId":"TestSample","ifSenderGp":"LSMTRON","ifSender":"iTractor","ifReceiverGp":"LSMTRON","ifReceiver":"SE","ifId":"IF_KR_IT_SE_0005","ifDateTime":"20211014034311"},"payload":{"t_data":[{"tractor_id":"101010","code_type":"01","code":"T123", "customer_use_yn":"Y", "office_use_yn":"Y", "agency_use_yn":"Y", "nonghyup_use_yn":"Y"}]}}}';

        IF_KR_IT_SE_0005.InputDIH input = new IF_KR_IT_SE_0005.InputDIH();
        input = (IF_KR_IT_SE_0005.InputDIH)JSON.deserialize(req, IF_KR_IT_SE_0005.InputDIH.class);

        return input;
    }
    private static IF_KR_IT_SE_0005.InputDIH newInputParameter8() {
        String req = '{"request":{"header":{"ifTrackingId":"TestSample","ifSenderGp":"LSMTRON","ifSender":"iTractor","ifReceiverGp":"LSMTRON","ifReceiver":"SE","ifId":"IF_KR_IT_SE_0005","ifDateTime":"20211014034311"},"payload":{"t_data":[{}]}}}';

        IF_KR_IT_SE_0005.InputDIH input = new IF_KR_IT_SE_0005.InputDIH();
        input = (IF_KR_IT_SE_0005.InputDIH)JSON.deserialize(req, IF_KR_IT_SE_0005.InputDIH.class);

        return input;
    }
    private static IF_KR_IT_SE_0005.InputDIH newInputParameter9() {
        String req = '{"request":{"header":{"ifTrackingId":"TestSample","ifSenderGp":"LSMTRON","ifSender":"iTractor","ifReceiverGp":"LSMTRON","ifReceiver":"SE","ifId":"IF_KR_IT_SE_0005","ifDateTime":"20211014034311"},"payload":{"t_data":[{"tractor_id":"123123123","code_type":"00","code":"E111", "customer_use_yn":"Y", "office_use_yn":"Y", "agency_use_yn":"Y", "nonghyup_use_yn":"Y"}]}}}';

        IF_KR_IT_SE_0005.InputDIH input = new IF_KR_IT_SE_0005.InputDIH();
        input = (IF_KR_IT_SE_0005.InputDIH)JSON.deserialize(req, IF_KR_IT_SE_0005.InputDIH.class);

        return input;
    }
    private static IF_KR_IT_SE_0005.InputDIH newInputParameter10() {
        String req = '{"request":{"header":{"ifTrackingId":"TestSample","ifSenderGp":"LSMTRON","ifSender":"iTractor","ifReceiverGp":"LSMTRON","ifReceiver":"SE","ifId":"IF_KR_IT_SE_0005","ifDateTime":"20211014034311"},"payload":{"t_data":[{"tractor_id":"10101011","code_type":"01","code":"T123", "customer_use_yn":"Y", "office_use_yn":"Y", "agency_use_yn":"Y", "nonghyup_use_yn":"Y"}]}}}';

        IF_KR_IT_SE_0005.InputDIH input = new IF_KR_IT_SE_0005.InputDIH();
        input = (IF_KR_IT_SE_0005.InputDIH)JSON.deserialize(req, IF_KR_IT_SE_0005.InputDIH.class);

        return input;
    }
    private static IF_KR_IT_SE_0005.InputDIH newInputParameter11() {
        String req = '{"request":{"header":{"ifTrackingId":"TestSample","ifSenderGp":"LSMTRON","ifSender":"iTractor","ifReceiverGp":"LSMTRON","ifReceiver":"SE","ifId":"IF_KR_IT_SE_0005","ifDateTime":"20211014034311"},"payload":{"t_data":[{"tractor_id":"123123123","code_type":"01","code":"E222", "customer_use_yn":"Y", "office_use_yn":"Y", "agency_use_yn":"Y", "nonghyup_use_yn":"Y"}]}}}';

        IF_KR_IT_SE_0005.InputDIH input = new IF_KR_IT_SE_0005.InputDIH();
        input = (IF_KR_IT_SE_0005.InputDIH)JSON.deserialize(req, IF_KR_IT_SE_0005.InputDIH.class);

        return input;
    }
    private static IF_KR_IT_SE_0005.InputDIH newInputParameter12() {
        String req = '{"request":{"header":{"ifTrackingId":"TestSample","ifSenderGp":"LSMTRON","ifSender":"iTractor","ifReceiverGp":"LSMTRON","ifReceiver":"SE","ifId":"IF_KR_IT_SE_0005","ifDateTime":"20211014034311"},"payload":{"t_data":[{"tractor_id":"1234567890","code_type":"00","code":"E111", "customer_use_yn":"Y", "office_use_yn":"Y", "agency_use_yn":"Y", "nonghyup_use_yn":"Y"}]}}}';

        IF_KR_IT_SE_0005.InputDIH input = new IF_KR_IT_SE_0005.InputDIH();
        input = (IF_KR_IT_SE_0005.InputDIH)JSON.deserialize(req, IF_KR_IT_SE_0005.InputDIH.class);

        return input;
    }
    private static IF_KR_IT_SE_0005.InputDIH newInputParameter13() {
        String req = '{"request":{"header":{"ifTrackingId":"TestSample","ifSenderGp":"LSMTRON","ifSender":"iTractor","ifReceiverGp":"LSMTRON","ifReceiver":"SE","ifId":"IF_KR_IT_SE_0005","ifDateTime":"20211014034311"},"payload":{"t_data":[{"tractor_id":"1234567890","code_type":"01","code":"E222", "customer_use_yn":"Y", "office_use_yn":"Y", "agency_use_yn":"Y", "nonghyup_use_yn":"Y"}]}}}';

        IF_KR_IT_SE_0005.InputDIH input = new IF_KR_IT_SE_0005.InputDIH();
        input = (IF_KR_IT_SE_0005.InputDIH)JSON.deserialize(req, IF_KR_IT_SE_0005.InputDIH.class);

        return input;
    }

    // HTTPResponse 객체 생성
    private static HTTPResponse newResponse(Integer statusCode) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(statusCode);
        res.setBody('{"response":{"header":{"ifTrackingId":"TestSample","ifSenderGp":"LSMTRON","ifSender":"SE","ifResult":"S","ifReceiverGp":"LSMTRON","ifReceiver":"iTractor","ifId":"IF_KR_IT_SE_0005","ifFailMsg":"","ifFailCode":"","ifDateTime":"20211029053524"},"payload":{"t_data":[{"message_result_desc":"해당 기대번호 정보에 대리점 대표 휴대폰 정보가 없습니다.","message_result":"E"}]}}}');
        IF_KR_IT_SE_0005.OutputDIH temp = (IF_KR_IT_SE_0005.OutputDIH)JSON.deserialize(res.getBody(), IF_KR_IT_SE_0005.OutputDIH.class);
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
    private static Boolean testServiceExecute(IF_KR_IT_SE_0005.InputDIH input) {
        String jsonMsg = JSON.serialize(input);

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/IF_KR_IT_SE_0005';  //Request URL
        req.httpMethod = 'POST';  //HTTP Request Type
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response = res;

        // 서비스 실행
        IF_KR_IT_SE_0005.OutputDIH result = IF_KR_IT_SE_0005.doPost();
        System.debug('result : '+result);
        //System.assertEquals(result.Response.Header.ResultCode, 'S', 'IF_KR_IT_SE_0005 실패!!!');

        // crashTest
        IF_Base.crashTest = true;
        result = IF_KR_IT_SE_0005.doPost();

        //System.assertEquals(result.Response.Header.ResultCode, 'E', 'IF_KR_IT_SE_0005 실패!!!');
        return true;
    }

    @isTest public static void testService1() {
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
        System.assertEquals(testServiceExecute(newInputParameter()), true);
        System.assertEquals(testServiceExecute(newInputParameter9()), true);
    }

    @isTest public static void testService2() {
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
        System.assertEquals(testServiceExecute(newInputParameter2()), true);
    }

    @isTest public static void testService3() {
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
        System.assertEquals(testServiceExecute(newInputParameter3()), true);
    }

    @isTest public static void testService4() {
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
        System.assertEquals(testServiceExecute(newInputParameter4()), true);
    }

    @isTest public static void testService5() {
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
        System.assertEquals(testServiceExecute(newInputParameter5()), true);
        System.assertEquals(testServiceExecute(newInputParameter11()), true);
    }

    @isTest public static void testService6() {
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
        System.assertEquals(testServiceExecute(newInputParameter6()), true);
        System.assertEquals(testServiceExecute(newInputParameter12()), true);
    }

    @isTest public static void testService7() {
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
        System.assertEquals(testServiceExecute(newInputParameter7()), true);
        System.assertEquals(testServiceExecute(newInputParameter13()), true);
    }

    @isTest public static void testService8() {
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
        System.assertEquals(testServiceExecute(newInputParameter8()), true);
        System.assertEquals(testServiceExecute(newInputParameter10()), true);
    }

    @TestSetup
    public static void testDataSet() {
        TriggerHandler.bypass('Account_tr');
        TriggerHandler.bypass('Asset_tr');
        TriggerHandler.bypass('i2SEMA_AutomaticNotification_tr');

        RecordType rType = [select id, Name from RecordType where name = 'B2C (개인고객)' and SobjectType = 'Account'];
        RecordType rType2 = [select id, Name from RecordType where name = 'B2G (기관고객)' and SobjectType = 'Account'];
        TestDataBaseFactory.init();
        TestDataSalesFactory.init();
        Account acc = [select id, RecordTypeId from account where lastname = 'PersonAccount' limit 1];
        acc.RecordTypeId = rType.Id;
        update acc;

        User dealerOwner = new User();
        dealerOwner.LastName = 'test Owner';
        dealerOwner.MobilePhone = '01012341234';
        dealerOwner.Username          = 'testowner101010@test.com';
        dealerOwner.ProfileId         = TestDataUtilFactory.getProfileId('국내영업 사용자');
        dealerOwner.TimeZoneSidKey    = 'Asia/Seoul';
        dealerOwner.Email             = 'agencyUser1@test.com';
        dealerOwner.EmailEncodingKey  = 'ks_c_5601-1987';
        dealerOwner.LanguageLocaleKey = 'ko';
        dealerOwner.Alias             = '한국 영업';
        dealerOwner.LocaleSidKey      = 'ko_KR';
        dealerOwner.DealerPasswd__c   = 'test';
        insert dealerOwner;
        dealerOwner.MobilePhone = '01012341234';
        update dealerOwner;

        iTractorRepairman__c rMan = new iTractorRepairman__c();
        rMan.Repairman__c = '테스터';
        rMan.Phone__c = '01012341234';
        insert rMan;

        Account  agAcc = TestDataBaseFactory.agencyAccount.clone(false, true);
        agAcc.DealerOwner__c = dealerOwner.Id;
        agAcc.iTractorRepairman__c = rMan.Id;
        insert agAcc;

        Account accAgency = [select id, DealerOwner__c, DealerOwner__r.Id, DealerOwner__r.MobilePhone from Account where id = :agAcc.Id limit 1];

        List<Asset> assList = [select id, AccountId, Dealer__r.Id, Dealer__r.DealerOwner__r.Id, Dealer__r.DealerOwner__r.MobilePhone, Product2Id, Product2.name, Product2.Id from asset where name = '1234567890'];
        for(Asset ass : assList) {
            ass.AccountId = acc.Id;
            ass.Dealer__c = accAgency.Id;
        }
        update assList;

        Account accNH = TestDataBaseFactory.governmentOrNHAccount.clone(false, true);
        accNH.RecordTypeId = rType2.Id;
        accNH.Mobile__c = '01012341234';
        insert accNH;

        Asset assNH = assList[0].clone(false, true);
        assNH.Name = '123123123';
        assNH.BatchNo__c = '123123123';
        assNH.AccountId = accNH.Id;
        assNH.Customer__c = acc.Id;
        assNH.Dealer__c = accAgency.Id;
        insert assNH;

        Asset assErr = TestDataSalesFactory.baseAsset.clone(false, true);
        assErr.Name = '2901111111';
        assErr.BatchNo__c = '2901111111';
        assErr.AccountId = accAgency.Id;
        assErr.Product2Id = null;
        insert assErr;

        NotificationTemplate__c testNT = new NotificationTemplate__c();
        testNT.Channel__c = '1009';
        testNT.Title__c = 'Test 템플릿1';
        testNT.Content__c = 'TEST 버전입니다.\n' +
                '#{label1}님께서 신청하신 #{label2} 코엑서 컨벤션센터에서 개최되는 #{label3}에 사전등록 신청해 주셔서 감사드립니다.\n' +
                '참가신청 후 개인사정으로 인하여 부득이하게 불참시에는 사전에 아이투맥스로 꼭 연락 주시기 바랍니다.';
        testNT.IsActive__c = true;
        insert testNT;

        iTractorTemplateMap__c testTmpMap = new iTractorTemplateMap__c();
        testTmpMap.Product_Type__c = '고장';
        testTmpMap.Guest_Type__c = '고객';
        testTmpMap.Agent_Template__c = testNT.Id;
        testTmpMap.Repairman_Template__c = testNT.Id;
        testTmpMap.Guest_Template__c = testNT.Id;
        testTmpMap.NHGuest_Template__c = testNT.Id;
        testTmpMap.NH_Template__c = testNT.Id;
        insert testTmpMap;

        iTractorTemplateMap__c testTmpMap2 = testTmpMap.clone(false, true);
        testTmpMap2.Product_Type__c = '고장';
        testTmpMap2.Guest_Type__c = '농협';
        insert testTmpMap2;

        iTractorTemplateMap__c testTmpMap3 = testTmpMap.clone(false, true);
        testTmpMap3.Product_Type__c = '경고';
        testTmpMap3.Guest_Type__c = '고객';
        insert testTmpMap3;

        iTractorTemplateMap__c testTmpMap4 = testTmpMap.clone(false, true);
        testTmpMap4.Product_Type__c = '경고';
        testTmpMap4.Guest_Type__c = '농협';
        insert testTmpMap4;

        iTractorErrorCode__c err = new iTractorErrorCode__c();
        err.ErrorCode__c = 'T123';
        err.ErrorType__c = '고장';
        err.ErrorMessage__c = '테스트 고장';
        insert err;

        iTractorErrorCode__c err2 = new iTractorErrorCode__c();
        err2.ErrorCode__c = 'T111';
        err2.ErrorType__c = '경고';
        err2.ErrorMessage__c = '테스트 고장';
        insert err2;

        iTractorErrorCode__c err3 = err.clone();
        err3.ErrorCode__c = 'E111';
        err3.ErrorMessage__c = null;
        insert err3;

        iTractorErrorCode__c err4 = err2.clone();
        err4.ErrorCode__c = 'E222';
        err4.ErrorMessage__c = null;
        insert err4;

        TriggerHandler.clearAllBypasses();
    }
}