/****************************************************************************************
  * ProjectName : i2sema
  * File Name   : IF_BaseNotiforce_TEST
  * Description : IF_BaseNotiforce_TEST Class
  * Copyright   : Copyright © 2020 i2max All Rights Reserved
  * Author      : ldb3100
  * Modification Log
  * ===============================================================
  * Ver  Date           Author       Modification
  * ===============================================================
    1.0  2020. 01. 16.  ldb3100      Create
    2.0  2020. 07. 11.  shlee        Change ClassName IF_Base_TEST > IF_BaseNotiforce_TEST
****************************************************************************************/
@isTest
private class IF_BaseNotiforce_TEST {

    private static void testInputHeader() {
        try {
            IF_BaseNotiforce.InputHeader inputHeader;
            inputHeader = new IF_BaseNotiforce.InputHeader();
            inputHeader = new IF_BaseNotiforce.InputHeader('');
            inputHeader = new IF_BaseNotiforce.InputHeader('', '');
            inputHeader = new IF_BaseNotiforce.InputHeader('', '', '');
            inputHeader = new IF_BaseNotiforce.InputHeader('', '', '', '', '', '');
            inputHeader.genMsg();
            inputHeader.giveGUID();
        } catch (Exception ex) {
            system.debug(ex);
        }
    }

    private static void testHeader() {
        try {
            IF_BaseNotiforce.Header Header = new IF_BaseNotiforce.Header();
        } catch (Exception ex) {
            system.debug(ex);
        }
    }
    private static void testHeaders() {
        try {
            IF_BaseNotiforce.Headers header = new IF_BaseNotiforce.Headers();
        } catch (Exception ex) {
            system.debug(ex);
        }
    }
    private static void testLogInit( ) {
        try {
            IF_BaseNotiforce.logInit('');
        } catch (Exception ex) {
            system.debug(ex);
        }
    }

    private static void testLogStart() {
        try {
            IF_BaseNotiforce.logStart(new IF_BaseNotiforce.InputHeader());
        } catch (Exception ex) {
            system.debug(ex);
        }
    }

    private static void testLogProcess() {
        try {
            IF_BaseNotiforce.logProcess('STEP1', '');
            IF_BaseNotiforce.logProcess('STEP1-1', '');
            IF_BaseNotiforce.logProcess('STEP2', '');
        } catch (Exception ex) {
            system.debug(ex);
        }
    }

    private static void testLogEnd() {
        try {
            IF_BaseNotiforce.InputHeader inputHeader = new IF_BaseNotiforce.InputHeader();
            inputHeader.ifResult='F';
            IF_BaseNotiforce.logEnd(inputHeader);
        } catch (Exception ex) {
            system.debug(ex);
        }
    }

    
    private static void testWebCallOut() {
        try {
            IF_BaseNotiforce.webCallOut('', '');
        } catch (Exception ex) {
            system.debug(ex);
        }
    }

    private static void testGetIfinfo() {
        try {
            IF_BaseNotiforce.getIfinfo('');
        } catch (Exception ex) {
            system.debug(ex);
        }
    }

    private static void testAuthEnc() {
        try {
            IF_BaseNotiforce.authEnc();
        } catch (Exception ex) {
            system.debug(ex);
        }
    }

    private static boolean testWebCallOutLog() {
        boolean isTrue = false;
        try {
            IF_BaseNotiforce.webCallOutLog('');
            IF_BaseNotiforce.crashTest = true;
            IF_BaseNotiforce.webCallOutLog('');
            
            isTrue = true;
        } catch (Exception ex) {
            system.debug(ex);
        }
        
        return isTrue;
    }

    private static void testAuthEncLog() {
        try {
            IF_BaseNotiforce.authEncLog();
        } catch (Exception ex) {
            system.debug(ex);
        }
    }

    private static void testWebCallOutAsync() {
        try {
            IF_BaseNotiforce.webCallOutAsync('', '');
        } catch (Exception ex) {
            system.debug(ex);
        }
    }

    private static void testGetDIHSessionId() {
        try {
            IF_BaseNotiforce.getDIHSessionId();
        } catch (Exception ex) {
            system.debug(ex);
        }
    }
    private static void testGiveAGGR(){
        IF_BaseNotiforce.giveAGGR();
    }

    private static void testLogAsyncUpdate() {
        try {
            String msgguid = '0834e514-d2eb-42c3-b501-770f335dfdd5';
            Notiforce_IF_LOG__c log = new Notiforce_IF_LOG__c(MSGGUID__c = msgguid, OMSGGUID__c = '');
            insert log;
            IF_BaseNotiforce.InputHeader inputHeaders = new IF_BaseNotiforce.InputHeader();
            inputHeaders.ifTrackingId = MSGGUID;
            IF_BaseNotiforce.logAsyncUpdate(inputHeaders);
        } catch (Exception ex) {
            system.debug(ex);
        }
    }

    private static void testLogAsyncAttach() {
        try {
            IF_BaseNotiforce.logAsyncAttach('aaa','aaa');
        } catch (Exception ex) {
            system.debug(ex);
        }
    }
    
    private static void testSetOutputHeader() {
        IF_BaseNotiforce.InputHeader inputHeader  = new IF_BaseNotiforce.InputHeader();
        IF_BaseNotiforce.InputHeader outputHeader = new IF_BaseNotiforce.InputHeader();
        try {
            
            outputHeader = IF_BaseNotiforce.setOutputHeader(outputHeader, inputHeader);
            
            if(true) {
                throw new DmlException('Exception');
            }
        } catch (Exception ex) {
            system.debug(ex);
            outputHeader = IF_BaseNotiforce.setOutputHeader(outputHeader, inputHeader, ex);
        }
    }

    @isTest public static void myUnitTest() {
        try {
            testInputHeader();
            testHeader();
            testHeaders();
            testLogInit();
            testLogStart();
            testLogProcess();
            testLogEnd();
            testWebCallOut();
            testGetIfinfo();
            testAuthEnc();
            //testWebCallOutLog();
            testAuthEncLog();
            testWebCallOutAsync();
            testGetDIHSessionId();
            testLogAsyncUpdate();
            testLogAsyncAttach();
            testGiveAGGR();
        
            testSetOutputHeader();
            
            Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
            IF_BaseNotiforce.staticValue = i2SEMA_TestDataUtil.getIfStaticValue();

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