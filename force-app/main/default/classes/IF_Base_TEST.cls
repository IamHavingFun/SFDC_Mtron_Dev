/****************************************************************************************
  * File Name   : IF_Base_TEST
  * Description : IF_Base_TEST Class
  * Author      : ldb3100
  * Modification Log
  * ===============================================================
  * Ver  Date        Author             Modification
  * ===============================================================
    1.0  2020.03.09  ldb3100            Create
****************************************************************************************/
@isTest
private class IF_Base_TEST {

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
	
    private static void testInputHeader() {
        try {
            IF_Base.InputHeader inputHeader;
            inputHeader = new IF_Base.InputHeader();
            inputHeader = new IF_Base.InputHeader('');
            inputHeader = new IF_Base.InputHeader('', '');
            inputHeader = new IF_Base.InputHeader('', '', '');
            inputHeader = new IF_Base.InputHeader('', '', '', '', '', '');
            inputHeader.genMsg();
            inputHeader.giveGUID();
        } catch (Exception ex) {
            system.debug(ex);
        }
    }

    private static void testHeader() {
        try {
            IF_Base.Header Header = new IF_Base.Header();
        } catch (Exception ex) {
            system.debug(ex);
        }
    }
    private static void testHeaders() {
        try {
            IF_Base.Headers header = new IF_Base.Headers();
        } catch (Exception ex) {
            system.debug(ex);
        }
    }
    private static void testLogInit( ) {
        try {
            IF_Base.logInit('');
        } catch (Exception ex) {
            system.debug(ex);
        }
    }

    private static void testLogStart() {
        try {
            IF_Base.logStart(new IF_Base.InputHeader());
        } catch (Exception ex) {
            system.debug(ex);
        }
    }

    private static void testLogProcess() {
        try {
            IF_Base.logProcess('STEP1', '');
            IF_Base.logProcess('STEP1-1', '');
            IF_Base.logProcess('STEP2', '');
        } catch (Exception ex) {
            system.debug(ex);
        }
    }

    private static void testLogEnd() {
        try {
            IF_Base.InputHeader inputHeader = new IF_Base.InputHeader();
            inputHeader.ifResult='F';
            IF_Base.logEnd(inputHeader);
            IF_Base.logEnd(inputHeader, '1', '1', '1', '1', '1', true);
        } catch (Exception ex) {
            system.debug(ex);
        }
    }

    
    private static void testWebCallOut() {
        try {
            IF_Base.webCallOut('', '');
        } catch (Exception ex) {
            system.debug(ex);
        }
    }

    private static void testGetIfinfo() {
        try {
            IF_Base.getIfinfo('');
        } catch (Exception ex) {
            system.debug(ex);
        }
    }

    private static void testAuthEnc() {
        try {
            IF_Base.authEnc();
        } catch (Exception ex) {
            system.debug(ex);
        }
    }

    private static boolean testWebCallOutLog() {
        boolean isTrue = false;
        try {
            IF_Base.webCallOutLog('');
            IF_Base.crashTest = true;
            IF_Base.webCallOutLog('');
            
            isTrue = true;
        } catch (Exception ex) {
            system.debug(ex);
        }
        
        return isTrue;
    }

    private static void testAuthEncLog() {
        try {
            IF_Base.authEncLog();
        } catch (Exception ex) {
            system.debug(ex);
        }
    }

    private static void testWebCallOutAsync() {
        try {
            IF_Base.webCallOutAsync('', '');
        } catch (Exception ex) {
            system.debug(ex);
        }
    }

    private static void testGetDIHSessionId() {
        try {
            IF_Base.getDIHSessionId();
        } catch (Exception ex) {
            system.debug(ex);
        }
    }

    private static void testLogAsyncUpdate() {
        try {
            String msgguid = '0834e514-d2eb-42c3-b501-770f335dfdd5';
            IF_LOG__c log = new IF_LOG__c(MSGGUID__c = msgguid, OMSGGUID__c = '');
            insert log;
            IF_Base.InputHeader inputHeaders = new IF_Base.InputHeader();
            inputHeaders.ifTrackingId = MSGGUID;
            IF_Base.logAsyncUpdate(inputHeaders);
        } catch (Exception ex) {
            system.debug(ex);
        }
    }

    private static void testLogAsyncAttach() {
        try {
            IF_Base.logAsyncAttach('aaa','aaa');
        } catch (Exception ex) {
            system.debug(ex);
        }
    }
    
    private static void testSetOutputHeader() {
        IF_Base.InputHeader inputHeader  = new IF_Base.InputHeader();
        IF_Base.InputHeader outputHeader = new IF_Base.InputHeader();
        try {
            
            outputHeader = IF_Base.setOutputHeader(outputHeader, inputHeader);
            
            if(true) {
                throw new DmlException('Exception');
            }
        } catch (Exception ex) {
            system.debug(ex);
            outputHeader = IF_Base.setOutputHeader(outputHeader, inputHeader, ex);
        }
    }

    @isTest public static void myUnitTest() {
        try {
        	testStaticValue();
            testInputHeader();
            testHeader();
            testHeaders();
            testLogInit();
            testLogStart();
            testLogProcess();
            testLogEnd();
            // testWebCallOut();
            testGetIfinfo();
            testAuthEnc();
            //testWebCallOutLog();
            testAuthEncLog();
            testWebCallOutAsync();
            testGetDIHSessionId();
            testLogAsyncUpdate();
            testLogAsyncAttach();
        
            testSetOutputHeader();
            
            Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());

            System.assertEquals(testWebCallOutLog(), true);
        
        } catch (Exception ex) {
            system.debug(ex);
        }
    }
    
    // HTTPResponse 객체 생성
    private static HTTPResponse newResponse(Integer statusCode) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(statusCode);
        res.setBody('');
        return res;
    }

    // StatusCode=200 Mock
    public class HttpCalloutSuccessMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = newResponse(200);
            return res;
        }
    }
}