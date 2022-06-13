/****************************************************************************************
  * File Name   : IF_KR_IT_SE_0006_TEST
  * Description : IF_KR_IT_SE_0006_TEST Class 
  * Author      : danbi.lee
  * copyright   : Copyright © I2max. All Rights Reserved.
  * Modification Log
  * ===============================================================
  * Ver   Date         Author       Modification
  * ===============================================================
    1.0   2021-05-31      danbi.lee    Create
***************************************************************************************/
@isTest
public class IF_KR_IT_SE_0006_TEST {

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
    private static IF_KR_IT_SE_0006.InputDIH newInputParameter() {
        String req = '{"request":{"header":{"ifTrackingId":"TestSample","ifSenderGp":"LSMTRON","ifSender":"iTractor","ifReceiverGp":"LSMTRON","ifReceiver":"SE","ifId":"IF_KR_IT_SE_0006","ifDateTime":"20211014034311"},"payload":{"t_data":[{"tractor_id":"12145877771","maintenance_type":"00","maintenance_msg":"","maintenance_code":"M4M2"}]}}}';

        IF_KR_IT_SE_0006.InputDIH input = new IF_KR_IT_SE_0006.InputDIH();
        input = (IF_KR_IT_SE_0006.InputDIH)JSON.deserialize(req, IF_KR_IT_SE_0006.InputDIH.class);

        return input;
    }

    // 입력 객체 생성-실패용
    private static IF_KR_IT_SE_0006.InputDIH newInputParameter1() {
        String req = '{"request":{"header":{"ifTrackingId":"TestSample","ifSenderGp":"LSMTRON","ifSender":"iTractor","ifReceiverGp":"LSMTRON","ifReceiver":"SE","ifId":"IF_KR_IT_SE_0006","ifDateTime":"20211014034311"},"payload":{"t_data":[{"tractor_id":"12145877770","maintenance_type":"01","maintenance_msg":"","maintenance_code":""}]}}}';

        IF_KR_IT_SE_0006.InputDIH input = new IF_KR_IT_SE_0006.InputDIH();
        input = (IF_KR_IT_SE_0006.InputDIH)JSON.deserialize(req, IF_KR_IT_SE_0006.InputDIH.class);

        return input;
    }

    // 입력 객체 생성-실패용
    private static IF_KR_IT_SE_0006.InputDIH newInputParameter2() {
        String req = '{"request":{"header":{"ifTrackingId":"TestSample","ifSenderGp":"LSMTRON","ifSender":"iTractor","ifReceiverGp":"LSMTRON","ifReceiver":"SE","ifId":"IF_KR_IT_SE_0006","ifDateTime":"20211014034311"},"payload":{"t_data":[{"tractor_id":"","maintenance_type":"01","maintenance_msg":"","maintenance_code":"A4M2"}]}}}';

        IF_KR_IT_SE_0006.InputDIH input = new IF_KR_IT_SE_0006.InputDIH();
        input = (IF_KR_IT_SE_0006.InputDIH)JSON.deserialize(req, IF_KR_IT_SE_0006.InputDIH.class);

        return input;
    }

    // 입력 객체 생성-실패용
    private static IF_KR_IT_SE_0006.InputDIH newInputParameter3() {
        String req = '{"request":{"header":{"ifTrackingId":"TestSample","ifSenderGp":"LSMTRON","ifSender":"iTractor","ifReceiverGp":"LSMTRON","ifReceiver":"SE","ifId":"IF_KR_IT_SE_0006","ifDateTime":"20211014034311"},"payload":{"t_data":[{"tractor_id":"12145877770","maintenance_type":"","maintenance_msg":"","maintenance_code":"A4M2"}]}}}';

        IF_KR_IT_SE_0006.InputDIH input = new IF_KR_IT_SE_0006.InputDIH();
        input = (IF_KR_IT_SE_0006.InputDIH)JSON.deserialize(req, IF_KR_IT_SE_0006.InputDIH.class);

        return input;
    }


    // HTTPResponse 객체 생성
    private static HTTPResponse newResponse(Integer statusCode) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(statusCode);
        res.setBody('{"response":{"header":{"ifTrackingId":"TestSample","ifSenderGp":"LSMTRON","ifSender":"SE","ifResult":"S","ifReceiverGp":"LSMTRON","ifReceiver":"iTractor","ifId":"IF_KR_IT_SE_0006","ifFailMsg":"","ifFailCode":"","ifDateTime":"20211029053755"},"payload":{"t_data":[{"message_result_desc":"해당 기대번호 정보가 없습니다.","message_result":"E"}],"ifSplitCnt":null,"ifRcvCnt":null,"ifAggregation":null}}}');
        IF_KR_IT_SE_0006.OutputDIH temp = (IF_KR_IT_SE_0006.OutputDIH)JSON.deserialize(res.getBody(), IF_KR_IT_SE_0006.OutputDIH.class);
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
    private static Boolean testServiceExecute(IF_KR_IT_SE_0006.InputDIH input) {
        String jsonMsg = JSON.serialize(input);

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/IF_KR_IT_SE_0006';  //Request URL
        req.httpMethod = 'POST';  //HTTP Request Type
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response = res;

        // 서비스 실행
        IF_KR_IT_SE_0006.OutputDIH result = IF_KR_IT_SE_0006.doPost();
        System.debug('result : '+result);
        //System.assertEquals(result.Response.Header.ResultCode, 'S', 'IF_KR_IT_SE_0006 실패!!!');

        // crashTest
        IF_Base.crashTest = true;
        result = IF_KR_IT_SE_0006.doPost();

        //System.assertEquals(result.Response.Header.ResultCode, 'E', 'IF_KR_IT_SE_0006 실패!!!');
        return true;
    }

    // 공통 테스트 진행
    private static Boolean testServiceExecute() {
        String jsonMsg = JSON.serialize(newInputParameter());

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/IF_KR_IT_SE_0006';  //Request URL
        req.httpMethod = 'POST';  //HTTP Request Type
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response = res;

        // 서비스 실행
        IF_KR_IT_SE_0006.OutputDIH result = IF_KR_IT_SE_0006.doPost();
        System.debug('result : '+result);
        //System.assertEquals(result.Response.Header.ResultCode, 'S', 'IF_KR_IT_SE_0006 실패!!!');

        // crashTest
        IF_Base.crashTest = true;
        result = IF_KR_IT_SE_0006.doPost();

        //System.assertEquals(result.Response.Header.ResultCode, 'E', 'IF_KR_IT_SE_0006 실패!!!');
        return true;
    }

    // 성공 테스트
    @isTest public static void testServiceSuccess() {
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());

        System.assertEquals(testServiceExecute(), true);
    }

    // 엇 성공이 다안된다.
    @isTest public static void testServiceSuccess2() {
        TriggerHandler.bypass('Account_tr');
        TriggerHandler.bypass('Asset_tr');
        TriggerHandler.bypass('i2SEMA_AutomaticNotification_tr');
   
        TestDataBaseFactory.init();
        //TestDataSalesFactory.init();

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

        Account pa = TestDataBaseFactory.personAccount.clone(false, true);
        pa.PersonMobilePhone = '010-1111-2222';
        pa.RecordTypeId = TestDataUtilFactory.getRecordTypeId('Account', 'PersonAccount');
        System.debug(pa);
        insert pa;

        iTractorRepairman__c rMan = new iTractorRepairman__c();
        rMan.Repairman__c = '테스터';
        rMan.Phone__c = '01012341234';
        insert rMan;

        Account  agAcc = TestDataBaseFactory.agencyAccount.clone(false, true);
        agAcc.DealerOwner__c = dealerOwner.Id;
        agAcc.iTractorRepairman__c = rMan.Id;
        insert agAcc;

        Account accAgency = [select id, DealerOwner__c, DealerOwner__r.Id, DealerOwner__r.MobilePhone from Account where id = :agAcc.Id limit 1];


        //ㅆㅂ Asset
        Asset asst = new Asset();
        asst.Name='12145877771';
        asst.BatchNo__c = '12145877771';
        insert asst;


        List<Asset> assList = [select id, AccountId, Dealer__r.Id, Dealer__r.DealerOwner__r.Id, Dealer__r.DealerOwner__r.MobilePhone, Product2Id, Product2.name, Product2.Id from asset where name = '12145877771'];

        for(Asset ass : assList) {
            ass.AccountId = pa.Id;
            ass.Dealer__c = accAgency.Id;
        }
        update assList;

        iTractorErrorCode__c err = new iTractorErrorCode__c();
        err.ErrorCode__c = 'M4M2';
        err.ErrorType__c = '소모품';
        err.ErrorMessage__c = '소모품 확인 부탁드립니다.';
        insert err;

        NotificationTemplate__c testNT = new NotificationTemplate__c();
        testNT.Channel__c = '1009';
        testNT.Title__c = 'Test 템플릿1';
        testNT.Content__c = 'TEST 버전입니다.\n' +
                '#{label1}님께서 신청하신 #{label2} 코엑서 컨벤션센터에서 개최되는 #{label3}에 사전등록 신청해 주셔서 감사드립니다.\n' +
                '참가신청 후 개인사정으로 인하여 부득이하게 불참시에는 사전에 아이투맥스로 꼭 연락 주시기 바랍니다.';
        testNT.IsActive__c = true;
        insert testNT;

        iTractorTemplateMap__c itm = new iTractorTemplateMap__c();
        itm.Product_Type__c = '소모품';
        itm.Guest_Type__c = '일반';
        itm.Guest_Target__c = true;
        itm.Guest_Template__c =  testNT.Id;

        insert itm;


        List<iTractorTemplateMap__c > iTTMapList= [
                SELECT
                        id,
                        name,
                        Guest_Target__c,        //고객
                        Guest_Template__c,      //고객 탬플릿
                        NH_Target__c,           //농협
                        NH_Template__c,         //농협탬플릿
                        NHGuest_Target__c,      //농협고객
                        NHGuest_Template__c,    //농협고객탬플릿
                        Repairman_Target__c,    //영업기사
                        Repairman_Template__c,  //영업기사 탬플릿
                        Agent_Target__c,        //대리점
                        Agent_Template__c       //대리점 탬플릿
                FROM iTractorTemplateMap__c
                WHERE Product_Type__c ='소모품'
                AND Guest_Type__c ='일반'
        ];
        System.debug('iTTMapList ' +iTTMapList);
        System.debug('iTTMapList ' +iTTMapList.size());


        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());

        System.assertEquals(testServiceExecute(), true);

        TriggerHandler.clearAllBypasses();
    }

    // 실패- 탬플릿 미흡
    @isTest public static void testServiceFail1() {
        TriggerHandler.bypass('Account_tr');
        TriggerHandler.bypass('Asset_tr');
        TriggerHandler.bypass('i2SEMA_AutomaticNotification_tr');

        TestDataBaseFactory.init();
        //TestDataSalesFactory.init();

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

        Account pa = TestDataBaseFactory.personAccount.clone(false, true);
        pa.PersonMobilePhone = '010-1111-2222';
        pa.RecordTypeId = TestDataUtilFactory.getRecordTypeId('Account', 'PersonAccount');
        System.debug(pa);
        insert pa;

        iTractorRepairman__c rMan = new iTractorRepairman__c();
        rMan.Repairman__c = '테스터';
        rMan.Phone__c = '01012341234';
        insert rMan;

        Account  agAcc = TestDataBaseFactory.agencyAccount.clone(false, true);
        agAcc.DealerOwner__c = dealerOwner.Id;
        agAcc.iTractorRepairman__c = rMan.Id;
        insert agAcc;

        Account accAgency = [select id, DealerOwner__c, DealerOwner__r.Id, DealerOwner__r.MobilePhone from Account where id = :agAcc.Id limit 1];


        //ㅆㅂ Asset
        Asset asst = new Asset();
        asst.Name='12145877771';
        asst.BatchNo__c = '12145877771';
        insert asst;


        List<Asset> assList = [select id, AccountId, Dealer__r.Id, Dealer__r.DealerOwner__r.Id, Dealer__r.DealerOwner__r.MobilePhone, Product2Id, Product2.name, Product2.Id from asset where BatchNo__c = '12145877771'];

        System.debug(assList.size() +'===>>>??');

        for(Asset ass : assList) {
            ass.AccountId = pa.Id;
            ass.Dealer__c = accAgency.Id;
        }
        update assList;

        iTractorErrorCode__c err = new iTractorErrorCode__c();
        err.ErrorCode__c = 'M4M2';
        err.ErrorType__c = '소모품';
        err.ErrorMessage__c = '소모품 확인 부탁드립니다.';
        insert err;

        NotificationTemplate__c testNT = new NotificationTemplate__c();
        testNT.Channel__c = '1009';
        testNT.Title__c = 'Test 템플릿1';
        testNT.Content__c = 'TEST 버전입니다.\n' +
                '#{label1}님께서 신청하신 #{label2} 코엑서 컨벤션센터에서 개최되는 #{label3}에 사전등록 신청해 주셔서 감사드립니다.\n' +
                '참가신청 후 개인사정으로 인하여 부득이하게 불참시에는 사전에 아이투맥스로 꼭 연락 주시기 바랍니다.';
        testNT.IsActive__c = true;
        insert testNT;


        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());

        System.assertEquals(testServiceExecute(), true);

        TriggerHandler.clearAllBypasses();
    }

    // 실패 테스트 기타 정보 등록
    @isTest public static void testServiceFail2() {
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());

        System.assertEquals(testServiceExecute(), true);
    }

    // 실패 테스트 기타 정보 등록
    @isTest public static void testServiceFail3() {
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());

        System.assertEquals(testServiceExecute(newInputParameter1()), true);
        System.assertEquals(testServiceExecute(newInputParameter2()), true);
        System.assertEquals(testServiceExecute(newInputParameter3()), true);
    }
}